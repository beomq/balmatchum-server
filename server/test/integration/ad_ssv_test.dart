import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:balmatchum_client/balmatchum_client.dart' as api;
import 'package:balmatchum_server/src/ads/ad_config.dart';
import 'package:balmatchum_server/src/ads/ad_service.dart';
import 'package:balmatchum_server/src/ads/ad_setup.dart';
import 'package:balmatchum_server/src/ads/ad_verifier.dart';
import 'package:balmatchum_server/src/ads/ads_endpoint.dart';
import 'package:balmatchum_server/src/ads/raw_query_server.dart';
import 'package:balmatchum_server/src/account/account_endpoint.dart';
import 'package:balmatchum_server/src/auth/auth_setup.dart';
import 'package:balmatchum_server/src/generated/protocol.dart';
import 'package:balmatchum_server/src/generated/serverpod.dart' as generated;
import 'package:clock/clock.dart';
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

void main() {
  late Directory directory;
  late Serverpod pod;
  late Session admin;
  late RawQueryServer listener;
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

  // A raw socket is essential: HttpClient/Uri would normalize signed escapes.
  Future<int> send(
    String query, {
    String path = '/admob/ssv',
    String method = 'GET',
  }) async {
    final socket = await Socket.connect('127.0.0.1', listener.port);
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
    '&reward_amount=$amount&reward_item=a%2fb%20%63'
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
    listener = (await configureAdMob(
      pod,
      config: AdConfig({
        'dailyReward': const AdPlacement('unit', 'a/b c', '7'),
        'extraQuiz': const AdPlacement('quiz', 'a/b c', '7'),
      }, 0),
      verifier: AdVerifier(loadKeys: () async => adKeys(), clock: clock),
      clock: clock,
    ))!;
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

  test(
    'authenticated create/get binds owner and repeated target; no client verification',
    () async {
      final a = await user();
      final b = await user();
      final anonymous = api.Client('http://localhost:${pod.server.port}/');
      clients.add(anonymous);
      await expectLater(
        anonymous.ads.createIntent('dailyReward', '2026-10-19', 1),
        throwsA(isA<api.ServerpodClientUnauthorized>()),
      );
      final intents = await Future.wait(
        List.generate(
          3,
          (_) => a.client.ads.createIntent('dailyReward', '2026-10-19', 1),
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
    'real wired HTTP verifies raw crypto, rejects changed query/key/unit/owner/amount',
    () async {
      final a = await user();
      final i = await a.client.ads.createIntent('dailyReward', '2026-10-19', 2);
      final query = event(i, tx: '1001');
      expect(await send(query.replaceFirst('%2f', '%2F')), 400);
      expect(await send(query.replaceFirst('%63', 'c')), 400);
      expect(await send(event(i, keyId: 999)), 400);
      expect(await send(event(i, unit: 'other')), 409);
      expect(await send(event(i, owner: 'other')), 409);
      expect(await send(event(i, amount: '9999')), 409);
      expect(await send(query, path: '/wrong'), 404);
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
      final i = await a.client.ads.createIntent('dailyReward', '2026-10-19', 3);
      final j = await b.client.ads.createIntent('dailyReward', '2026-10-19', 3);
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
      final i = await a.client.ads.createIntent('dailyReward', '2026-10-19', 4);
      final query = event(i, tx: '3001');
      now = now.add(const Duration(days: 2));
      expect(await send(query), 200);
      now = now.add(const Duration(days: 10));
      expect(await send(query), 200);
      final b = await user();
      now = DateTime.utc(2026, 10, 19);
      final j = await b.client.ads.createIntent('extraQuiz', '2026-10-19', 0);
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
        (await b.client.ads.createIntent('extraQuiz', '2026-10-19', 0)).id,
        j.id,
      );
    },
  );

  test(
    'consumption binding, rollback, exactly once and account purge',
    () async {
      final a = await user();
      final i = await a.client.ads.createIntent('dailyReward', '2026-10-19', 5);
      final service = AdService.instances[pod]!;
      Future<void> consume({bool rollback = false, int revision = 5}) =>
          admin.db.transaction((tx) async {
            await service.consume(
              admin,
              tx,
              owner: a.owner,
              intentId: i.id,
              purpose: 'dailyReward',
              targetDate: '2026-10-19',
              targetRevision: revision,
            );
            if (rollback) throw StateError('grant failed');
          });
      await expectLater(consume(), throwsA(isA<AdException>()));
      final query = event(i, tx: '4001');
      expect(await send(query), 200);
      await expectLater(consume(revision: 6), throwsA(isA<AdException>()));
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
        AdsEndpoint().createIntent(a.session, 'dailyReward', '2026-10-19', 6),
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
      final i = await a.client.ads.createIntent('dailyReward', '2026-10-19', 7);
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
        AdsEndpoint().createIntent(a.session, 'dailyReward', '2026-10-19', 8),
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
}
