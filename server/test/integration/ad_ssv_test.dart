import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:balmatchum_client/balmatchum_client.dart' as api;
import 'package:balmatchum_server/src/ads/ad_config.dart';
import 'package:balmatchum_server/src/ads/ad_service.dart';
import 'package:balmatchum_server/src/ads/ad_setup.dart';
import 'package:balmatchum_server/src/ads/ad_verifier.dart';
import 'package:balmatchum_server/src/ads/ads_endpoint.dart';
import 'package:balmatchum_server/src/account/account_endpoint.dart';
import 'package:balmatchum_server/src/auth/auth_setup.dart';
import 'package:balmatchum_server/src/generated/protocol.dart';
import 'package:balmatchum_server/src/generated/serverpod.dart' as generated;
import 'package:clock/clock.dart';
import 'package:balmatchum_server/src/product/product_endpoint.dart';
import 'package:balmatchum_server/src/product/product_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';
import '../test_utils/ad_test_keys.dart';

class _Token implements api.ClientAuthKeyProvider {
  _Token(this.token);
  final String token;
  @override
  Future<String?> get authHeaderValue async => 'Bearer $token';
}

const iosDaily = 'ca-app-pub-0000000000000001/1000000001';
const androidDaily = 'ca-app-pub-0000000000000001/1000000002';
const iosQuiz = 'ca-app-pub-0000000000000001/2000000001';
const androidQuiz = 'ca-app-pub-0000000000000001/2000000002';

void main() {
  late Directory directory;
  late Serverpod pod;
  late Session admin;
  var now = DateTime.utc(2026, 10, 19);
  final clients = <api.Client>[];
  final sessions = <Session>[];
  Future<({api.Client client, Session session, String owner})> user() async {
    final auth = AuthServices.instance;
    final u = await auth.authUsers.create(admin);
    final token = await auth.tokenManager.issueToken(
      admin,
      authUserId: u.id,
      method: 'ssv-test',
    );
    final client = api.Client('http://localhost:${pod.server.port}/')
      ..authKeyProvider = _Token(token.token);
    clients.add(client);
    final session = await pod.createSession(enableLogging: false);
    session.updateAuthenticated(
      await auth.authenticationHandler(session, token.token),
    );
    sessions.add(session);
    return (client: client, session: session, owner: u.id.uuid);
  }

  Future<api.AdIntent> intent(
    ({api.Client client, Session session, String owner}) u,
    int revision, {
    api.AdPlatform platform = api.AdPlatform.ios,
  }) async {
    await ProductEndpoint().registerStepStream(u.session, 'register', 0);
    for (var r = 1; r <= revision; r++) {
      await withClock(
        Clock.fixed(DateTime.utc(2026, 10, 19)),
        () => ProductEndpoint().submitSteps(
          u.session,
          DailyStepInput(
            date: '2026-10-19',
            streamGeneration: 1,
            revision: r,
            windowStart: dayStart('2026-10-19'),
            windowEnd: dayStart('2026-10-20'),
            observedAt: DateTime.utc(2026, 10, 19),
            total: 7000,
            availability: 'confirmed',
          ),
        ),
      );
    }
    return u.client.ads.createIntent(
      'dailyReward',
      '2026-10-19',
      revision,
      platform,
    );
  }

  // Raw socket: send the exact request line to the public API server port.
  Future<int> send(
    String query, {
    String path = '/admob/ssv',
    String method = 'GET',
  }) async {
    final socket = await Socket.connect('localhost', pod.server.port);
    final response = socket.cast<List<int>>().transform(utf8.decoder).join();
    socket.write(
      '$method $path?$query HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n',
    );
    await socket.flush();
    final text = await response.timeout(const Duration(seconds: 15));
    socket.destroy();
    return int.parse(text.split(' ')[1]);
  }

  String event(
    api.AdIntent i, {
    String tx = 'abcdef',
    String? owner,
    String? unit,
    String amount = '7',
    DateTime? at,
    int keyId = 1,
  }) => signAd(
    'ad_network=123&ad_unit=${unit ?? i.adUnit}&custom_data=${i.customData}'
    '&reward_amount=$amount&reward_item=a%2Fb%20c'
    '&timestamp=${(at ?? now).millisecondsSinceEpoch}&transaction_id=$tx'
    '&user_id=${owner ?? i.userId}',
    keyId: keyId,
  );

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('ad-');
    pod = generated.Serverpod(
      ['--mode=test', '--apply-migrations'],
      configOverride: (c) => c.copyWith(
        database: PostgresDatabaseConfig(
          host: '127.0.0.1',
          port: 0,
          user: 'postgres',
          password: 'local-disposable-test-only',
          dataPath: '${directory.path}/pgdata',
          name: 'ad_test',
        ),
      ),
    );
    configureAuth(pod, sessionPepper: 'public-ad-test');
    await pod.start(runInGuardedZone: false);
    admin = await pod.createSession(enableLogging: false);
    expect(await configureAdMob(pod), isNull);
    final clock = Clock(() => now);
    expect(
      await configureAdMob(
        pod,
        config: AdConfig({
          'dailyReward': const AdPlacement(
            (
              ios: iosDaily,
              android: androidDaily,
            ),
            'a/b c',
            '7',
          ),
          'extraQuiz': const AdPlacement(
            (
              ios: iosQuiz,
              android: androidQuiz,
            ),
            'a/b c',
            '7',
          ),
        }),
        verifier: AdVerifier(loadKeys: () async => adKeys(), clock: clock),
        clock: clock,
      ),
      isNotNull,
    );
  });
  setUp(() {
    now = DateTime.utc(2026, 10, 19);
  });
  tearDownAll(() async {
    for (final c in clients) {
      c.close();
    }
    for (final s in sessions) {
      await s.close();
    }
    await admin.close();
    await pod.shutdown(exitProcess: false);
    await directory.delete(recursive: true);
  });

  Future<int> claimWithAd(Session session, String intentId) async {
    try {
      final grant = await withClock(
        Clock(() => now),
        () => ProductEndpoint().claimDayWithAd(
          session,
          '2026-10-19',
          'claim-$intentId',
          1,
          intentId,
        ),
      );
      return grant.amount;
    } on AdException {
      return 0;
    }
  }

  for (final (platform, unit, otherPlatformUnit) in [
    (api.AdPlatform.ios, iosDaily, androidDaily),
    (api.AdPlatform.android, androidDaily, iosDaily),
  ]) {
    test('${platform.name} unit SSV rewards exactly once; other purpose, '
        'other platform and unknown units are rejected', () async {
      final a = await user();
      final i = await intent(a, 1, platform: platform);
      expect(i.adUnit, unit);
      final rejected = [
        event(i, tx: '${platform.index}a1', unit: otherPlatformUnit),
        event(
          i,
          tx: '${platform.index}a2',
          unit: otherPlatformUnit.split('/').last,
        ),
        event(i, tx: '${platform.index}a3', unit: iosQuiz),
        event(i, tx: '${platform.index}a4', unit: androidQuiz.split('/').last),
        event(
          i,
          tx: '${platform.index}a5',
          unit: 'ca-app-pub-0000000000000001/9999999999',
        ),
      ];
      for (final query in rejected) {
        expect(await send(query), 409);
      }
      expect((await a.client.ads.getIntent(i.id)).status, 'pending');
      expect(await claimWithAd(a.session, i.id), 0);
      // Google's SSV ad_unit is the numeric unit ID after the slash.
      final accepted = event(
        i,
        tx: '${platform.index}b1',
        unit: unit.split('/').last,
      );
      expect(await send(accepted), 200);
      expect(await send(accepted), 200);
      expect(await send(event(i, tx: '${platform.index}b2')), 409);
      expect(await claimWithAd(a.session, i.id), 140);
      expect(await claimWithAd(a.session, i.id), 140);
      expect((await a.client.product.getWallet()).balance, 140);
      expect((await a.client.ads.getIntent(i.id)).status, 'consumed');
    });
  }

  test('switching platform rebinds a pending intent to that unit', () async {
    final a = await user();
    final i = await intent(a, 1);
    expect(i.adUnit, iosDaily);
    final j = await intent(a, 1, platform: api.AdPlatform.android);
    expect(j.id, i.id);
    expect(j.adUnit, androidDaily);
    expect(await send(event(i, tx: 'c1', unit: iosDaily)), 409);
    expect(await send(event(j, tx: 'c2')), 200);
    final k = await intent(a, 1);
    expect(k.adUnit, androidDaily);
    expect(k.status, 'verified');
  });

  test(
    'authenticated create/get binds owner and repeated target; no client verification',
    () async {
      final a = await user();
      final b = await user();
      final anonymous = api.Client('http://localhost:${pod.server.port}/');
      clients.add(anonymous);
      await expectLater(
        anonymous.ads.createIntent(
          'dailyReward',
          '2026-10-19',
          1,
          api.AdPlatform.ios,
        ),
        throwsA(isA<api.ServerpodClientUnauthorized>()),
      );
      final intents = await Future.wait(
        List.generate(
          3,
          (_) => intent(a, 1),
        ),
      );
      expect(intents.map((i) => i.id).toSet(), hasLength(1));
      final i = intents.first;
      expect(i.status, 'pending');
      expect(i.customData.length, 43);
      expect(i.userId, a.owner);
      expect(i.targetRevision, 1);
      await expectLater(
        b.client.ads.getIntent(i.id),
        throwsA(isA<api.AdException>()),
      );
      expect((await a.client.ads.getIntent(i.id)).status, 'pending');
    },
  );

  test(
    'public API route verifies crypto, rejects changed query/signature/key/unit/owner/amount',
    () async {
      final a = await user();
      final i = await intent(a, 2);
      final query = event(i, tx: '1001');
      final signature = RegExp(r'signature=([^&]+)').firstMatch(query)!;
      final tampered = query.replaceFirst(
        signature.group(0)!,
        'signature=${signature.group(1)!.substring(0, 20)}'
        '${signature.group(1)![20] == 'A' ? 'B' : 'A'}'
        '${signature.group(1)!.substring(21)}',
      );
      expect(await send(tampered), 400);
      expect(await send(query.replaceFirst('%2F', '%2E')), 400);
      expect(await send(query.replaceFirst('%20c', '%20d')), 400);
      expect(await send(event(i, keyId: 999)), 400);
      expect(await send(event(i, unit: 'other')), 409);
      expect(await send(event(i, owner: 'other')), 409);
      expect(await send(event(i, amount: '9999')), 409);
      // Other paths belong to Serverpod's endpoint dispatcher, not the callback.
      expect(await send(query, path: '/wrong'), isNot(200));
      expect(await send(query, method: 'POST'), 405);
      expect((await a.client.ads.getIntent(i.id)).status, 'pending');
      expect(await send(query), 200);
      expect((await a.client.ads.getIntent(i.id)).status, 'verified');
      expect(
        await PointEntry.db.count(admin, where: (t) => t.owner.equals(a.owner)),
        0,
      );
    },
  );

  test(
    'concurrent duplicate callbacks and cross-owner transaction replay',
    () async {
      final a = await user();
      final b = await user();
      final i = await intent(a, 3);
      final j = await intent(b, 3);
      final results = await Future.wait([
        send(event(i, tx: '2001')),
        send(event(j, tx: '2001')),
      ]);
      expect(results..sort(), [200, 409]);
      final verified = (await a.client.ads.getIntent(i.id)).status == 'verified'
          ? i
          : j;
      expect(
        await Future.wait(
          List.generate(4, (_) => send(event(verified, tx: '2001'))),
        ),
        everyElement(200),
      );
      expect(await send(event(verified, tx: '2002')), 409);
    },
  );

  test(
    'signed event window allows delayed delivery and exact retries past deadline',
    () async {
      final a = await user();
      final i = await intent(a, 4);
      final query = event(i, tx: '3001');
      now = now.add(const Duration(days: 2));
      expect(await send(query), 200);
      now = now.add(const Duration(days: 10));
      expect(await send(query), 200);
      final b = await user();
      now = DateTime.utc(2026, 10, 19);
      final j = await intent(b, 1);
      expect(
        await send(
          event(
            j,
            tx: '3002',
            at: now.subtract(const Duration(milliseconds: 1)),
          ),
        ),
        409,
      );
      expect(
        await send(
          event(j, tx: '3002', at: now.add(const Duration(minutes: 6))),
        ),
        409,
      );
      now = j.acceptUntil;
      expect(await send(event(j, tx: '3002', at: j.createdAt)), 409);
      expect((await b.client.ads.getIntent(j.id)).status, 'expired');
      expect(
        (await b.client.ads.createIntent(
          'dailyReward',
          '2026-10-19',
          1,
          api.AdPlatform.ios,
        )).id,
        j.id,
      );
    },
  );

  test(
    'consumption binding, rollback, exactly once and account purge',
    () async {
      final a = await user();
      final i = await intent(a, 5);
      final service = AdService.instances[pod]!;
      Future<void> consume({
        bool rollback = false,
        int revision = 5,
        String purpose = 'dailyReward',
        String date = '2026-10-19',
      }) => admin.db.transaction((tx) async {
        await service.consume(
          admin,
          tx,
          owner: a.owner,
          intentId: i.id,
          purpose: purpose,
          targetDate: date,
          targetRevision: revision,
        );
        if (rollback) throw StateError('grant failed');
      });
      await expectLater(consume(), throwsA(isA<AdException>()));
      final query = event(i, tx: '4001');
      expect(await send(query), 200);
      await expectLater(consume(revision: 6), throwsA(isA<AdException>()));
      await expectLater(
        consume(purpose: 'extraQuiz'),
        throwsA(isA<AdException>()),
      );
      await expectLater(
        consume(date: '2026-10-18'),
        throwsA(isA<AdException>()),
      );
      await expectLater(consume(rollback: true), throwsStateError);
      expect((await a.client.ads.getIntent(i.id)).status, 'verified');
      await consume();
      await expectLater(consume(), throwsA(isA<AdException>()));
      expect((await a.client.ads.getIntent(i.id)).status, 'consumed');
      expect(await send(query), 200);
      await a.client.account.deleteAccount();
      expect(
        await StoredAdIntent.db.count(
          admin,
          where: (t) => t.owner.equals(a.owner),
        ),
        0,
      );
      expect(await send(query), 409);
      await expectLater(
        AdsEndpoint().createIntent(
          a.session,
          'dailyReward',
          '2026-10-19',
          6,
          AdPlatform.ios,
        ),
        throwsA(isA<NotAuthorizedException>()),
      );
      expect(
        await ProductAccount.db.count(
          admin,
          where: (t) => t.owner.equals(a.owner),
        ),
        0,
      );
    },
  );

  test(
    'owner deletion lock wins over callback and stale authenticated create',
    () async {
      final a = await user();
      final i = await intent(a, 7);
      final purged = Completer<void>();
      final release = Completer<void>();
      final deletion = admin.db.transaction((tx) async {
        await deleteAccountData(admin, a.owner, tx);
        purged.complete();
        await release.future.timeout(const Duration(seconds: 10));
      });
      await purged.future.timeout(const Duration(seconds: 10));
      await expectLater(
        admin.db.transaction(
          (tx) => admin.db.unsafeQuery(
            'SELECT id FROM serverpod_auth_core_user '
            'WHERE id = CAST(@owner AS uuid) FOR UPDATE NOWAIT',
            parameters: QueryParameters.named({'owner': a.owner}),
            transaction: tx,
          ),
        ),
        throwsA(
          isA<DatabaseQueryException>().having((e) => e.code, 'code', '55P03'),
        ),
      );
      final callback = send(event(i, tx: '5001'));
      final stale = expectLater(
        AdsEndpoint().createIntent(
          a.session,
          'dailyReward',
          '2026-10-19',
          8,
          AdPlatform.ios,
        ),
        throwsA(isA<NotAuthorizedException>()),
      );
      release.complete();
      await deletion;
      await stale;
      expect(await callback, anyOf(409, 410));
      expect(
        await StoredAdIntent.db.count(
          admin,
          where: (t) => t.owner.equals(a.owner),
        ),
        0,
      );
      expect(
        await ProductAccount.db.count(
          admin,
          where: (t) => t.owner.equals(a.owner),
        ),
        0,
      );
    },
  );

  test(
    'actual ad claim rolls back ledger units and consumption together',
    () async {
      final a = await user();
      final i = await intent(a, 1);
      expect(await send(event(i, tx: '6001')), 200);
      await expectLater(
        withClock(
          Clock(() => now),
          () => ProductService.run(a.session, (s) async {
            await s.claim('2026-10-19', 'claim', 1, intentId: i.id);
            throw StateError('response transaction failed');
          }),
        ),
        throwsStateError,
      );
      expect((await a.client.ads.getIntent(i.id)).status, 'verified');
      expect((await a.client.product.getWallet()).balance, 0);
      expect(
        await ProductRequest.db.count(
          admin,
          where: (t) => t.owner.equals(a.owner) & t.requestId.equals('claim'),
        ),
        0,
      );
      final grant = await withClock(
        Clock(() => now),
        () => ProductEndpoint().claimDayWithAd(
          a.session,
          '2026-10-19',
          'claim',
          1,
          i.id,
        ),
      );
      expect(grant.amount, 140);
      expect(grant.basePoints, 70);
      expect(grant.multiplier, 2);
      expect(grant.fixtureLabel, isNull);
      expect((await a.client.ads.getIntent(i.id)).status, 'consumed');
      expect((await a.client.product.getWallet()).balance, 140);
      final replay = await a.client.product.claimDayWithAd(
        '2026-10-19',
        'claim',
        1,
        i.id,
      );
      expect(replay.ledgerId, grant.ledgerId);
      expect(await send(event(i, tx: '6001')), 200);
      await expectLater(
        a.client.product.claimDayWithAd('2026-10-19', 'claim', 1, 'other'),
        throwsA(
          isA<api.ProductException>().having(
            (e) => e.code,
            'code',
            'idempotencyConflict',
          ),
        ),
      );
      await a.client.product.deleteDay('2026-10-19', 'delete');
      expect(
        (await a.client.product.claimDayWithAd(
          '2026-10-19',
          'claim',
          1,
          i.id,
        )).ledgerId,
        grant.ledgerId,
      );
      expect((await a.client.product.getWallet()).balance, 140);
    },
  );

  test('intent eligibility, owner binding and free then ad conflict', () async {
    final a = await user();
    final b = await user();
    await expectLater(
      a.client.ads.createIntent(
        'dailyReward',
        '2026-10-19',
        1,
        api.AdPlatform.ios,
      ),
      throwsA(
        isA<api.ProductException>().having(
          (e) => e.code,
          'code',
          'staleProjection',
        ),
      ),
    );
    await expectLater(
      a.client.ads.createIntent(
        'extraQuiz',
        '2026-10-19',
        0,
        api.AdPlatform.ios,
      ),
      throwsA(
        isA<api.ProductException>().having(
          (e) => e.code,
          'code',
          'freeRequired',
        ),
      ),
    );
    await expectLater(
      a.client.ads.createIntent(
        'dailyReward',
        '2026-10-20',
        1,
        api.AdPlatform.ios,
      ),
      throwsA(
        isA<api.AdException>().having((e) => e.code, 'code', 'invalidTarget'),
      ),
    );
    final i = await intent(a, 1);
    final j = await intent(b, 1);
    expect(await send(event(i, tx: '6002')), 200);
    final endpoint = ProductEndpoint();
    await expectLater(
      withClock(
        Clock(() => now),
        () => endpoint.claimDayWithAd(
          b.session,
          '2026-10-19',
          'other-owner',
          1,
          i.id,
        ),
      ),
      throwsA(
        isA<AdException>().having((e) => e.code, 'code', 'intentNotFound'),
      ),
    );
    await expectLater(
      withClock(
        Clock(() => now),
        () => endpoint.claimDayWithAd(
          b.session,
          '2026-10-19',
          'unverified',
          1,
          j.id,
        ),
      ),
      throwsA(
        isA<AdException>().having((e) => e.code, 'code', 'intentNotVerified'),
      ),
    );
    await withClock(
      Clock(() => now),
      () => endpoint.claimDay(a.session, '2026-10-19', 'free', 1),
    );
    await expectLater(
      withClock(
        Clock(() => now),
        () => endpoint.claimDayWithAd(
          a.session,
          '2026-10-19',
          'ad-after-free',
          1,
          i.id,
        ),
      ),
      throwsA(
        isA<ProductException>().having(
          (e) => e.code,
          'code',
          'staleProjection',
        ),
      ),
    );
    expect((await a.client.ads.getIntent(i.id)).status, 'verified');
    expect(
      (await a.client.ads.createIntent(
        'dailyReward',
        '2026-10-19',
        1,
        api.AdPlatform.ios,
      )).id,
      i.id,
    );
    await expectLater(
      a.client.ads.createIntent(
        'dailyReward',
        '2026-10-19',
        2,
        api.AdPlatform.ios,
      ),
      throwsA(
        isA<api.ProductException>().having(
          (e) => e.code,
          'code',
          'nothingToClaim',
        ),
      ),
    );
    await b.client.product.deleteDay('2026-10-19', 'delete');
    await expectLater(
      withClock(
        Clock(() => now),
        () => endpoint.claimDayWithAd(
          b.session,
          '2026-10-19',
          'deleted',
          2,
          j.id,
        ),
      ),
      throwsA(
        isA<ProductException>().having((e) => e.code, 'code', 'dayDeleted'),
      ),
    );
  });

  test('concurrent free and verified ad claims grant one range only', () async {
    final a = await user();
    final i = await intent(a, 1);
    expect(await send(event(i, tx: '6003')), 200);
    final endpoint = ProductEndpoint();
    final outcomes = await withClock(
      Clock(() => now),
      () => Future.wait(
        List.generate(12, (n) async {
          try {
            return n.isEven
                ? await endpoint.claimDay(a.session, '2026-10-19', 'free-$n', 1)
                : await endpoint.claimDayWithAd(
                    a.session,
                    '2026-10-19',
                    'ad-$n',
                    1,
                    i.id,
                  );
          } on ProductException catch (e) {
            return e;
          }
        }),
      ),
    );
    final grant = outcomes.whereType<RewardGrant>().single;
    expect(grant.amount, anyOf(70, 140));
    expect(
      outcomes.whereType<ProductException>().every(
        (e) => e.code == 'staleProjection',
      ),
      isTrue,
    );
    expect((await a.client.product.getWallet()).balance, grant.amount);
    expect(
      (await a.client.ads.getIntent(i.id)).status,
      grant.amount == 140 ? 'consumed' : 'verified',
    );
  });

  test(
    'free new tranche does not destroy expired old ad entitlement',
    () async {
      final a = await user();
      await intent(a, 1);
      now = dayStart('2026-10-27');
      final endpoint = ProductEndpoint();
      await withClock(Clock(() => now), () async {
        var day = await endpoint.getDay(a.session, '2026-10-19');
        expect(day.claimablePoints, 0);
        expect(day.adClaimablePoints, 140);
        day = await endpoint.submitSteps(
          a.session,
          DailyStepInput(
            date: '2026-10-19',
            streamGeneration: 1,
            revision: 2,
            windowStart: dayStart('2026-10-19'),
            windowEnd: dayStart('2026-10-20'),
            observedAt: now,
            total: 9000,
            availability: 'confirmed',
          ),
        );
        expect(day.claimablePoints, 20);
        await endpoint.claimDay(
          a.session,
          '2026-10-19',
          'late-free',
          day.revision,
        );
        day = await endpoint.getDay(a.session, '2026-10-19');
        expect(day.adClaimablePoints, 140);
        final i = await a.client.ads.createIntent(
          'dailyReward',
          '2026-10-19',
          day.revision,
          api.AdPlatform.android,
        );
        expect(await send(event(i, tx: '6004')), 200);
        final grant = await endpoint.claimDayWithAd(
          a.session,
          '2026-10-19',
          'old-ad',
          day.revision,
          i.id,
        );
        expect(grant.amount, 140);
        expect(grant.slices!.single.fromUnits, 0);
        expect(grant.slices!.single.throughUnits, 70);
        expect((await endpoint.getWallet(a.session)).balance, 160);
        expect(
          (await endpoint.getDay(a.session, '2026-10-19')).rewardStatus,
          'settled',
        );
      });
    },
  );
}
