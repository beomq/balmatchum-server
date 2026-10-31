import 'dart:async';
import 'dart:io';

import 'package:balmatchum_client/balmatchum_client.dart' as api;
import 'package:balmatchum_server/src/auth/auth_setup.dart';
import 'package:balmatchum_server/src/generated/protocol.dart';
import 'package:balmatchum_server/src/generated/serverpod.dart' as generated;
import 'package:balmatchum_server/src/product/product_endpoint.dart';
import 'package:balmatchum_server/src/product/product_service.dart';
import 'package:balmatchum_server/src/profile/profile_endpoint.dart';
import 'package:balmatchum_server/src/records/records_endpoint.dart';
import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

class _Token implements api.ClientAuthKeyProvider {
  _Token(this.value);
  final String value;
  @override
  Future<String?> get authHeaderValue async => 'Bearer $value';
}

const _bound = Duration(seconds: 10);
const _date = '2026-10-14';
// 12:00 KST on _date, so the server date is fixed regardless of wall time.
final _clock = Clock.fixed(DateTime.utc(2026, 10, 14, 3));

Future<T> _at<T>(Future<T> Function() body) => withClock(_clock, body);

DailyStepInput _steps(int total) => DailyStepInput(
  date: _date,
  streamGeneration: 1,
  revision: 1,
  windowStart: dayStart(_date),
  windowEnd: dayStart(_date).add(const Duration(days: 1)),
  observedAt: DateTime.utc(2026, 10, 14, 3),
  total: total,
  availability: 'confirmed',
);

String _summary(HomeSnapshot s) =>
    'date=${s.date} day.revision=${s.day.revision} '
    'day.claimable=${s.day.claimablePoints} day.granted=${s.day.grantedPoints} '
    'wallet=${s.wallet.balance} themes.balance=${s.themes.balance} '
    'cloudyOwned=${s.themes.items.singleWhere((t) => t.themeId == 'cloudy').owned} '
    'outfits.balance=${s.outfits.balance} recentDays=${s.recentDays.length} '
    'last.granted=${s.recentDays.last.grantedPoints}';

void main() {
  group('Home snapshot from one read transaction', () {
    late Directory directory;
    late Serverpod pod;
    late Session admin;
    var started = false;
    final clients = <api.Client>[];
    final sessions = <Session>[];
    final endpoint = ProductEndpoint();

    Future<Session> sessionFor(String token) async {
      final session = await pod.createSession(enableLogging: false);
      sessions.add(session);
      session.updateAuthenticated(
        await AuthServices.instance.authenticationHandler(session, token),
      );
      return session;
    }

    Future<({api.Client client, Session session, String token})> user() async {
      final auth = AuthServices.instance;
      final created = await auth.authUsers.create(admin);
      final token = await auth.tokenManager.issueToken(
        admin,
        authUserId: created.id,
        method: 'home-snapshot-test',
      );
      final client = api.Client('http://localhost:${pod.server.port}/')
        ..authKeyProvider = _Token(token.token);
      clients.add(client);
      final session = await sessionFor(token.token);
      expect(session.authenticated!.userIdentifier, created.id.uuid);
      return (client: client, session: session, token: token.token);
    }

    setUpAll(() async {
      directory = await Directory.systemTemp.createTemp('home-snapshot-');
      pod = generated.Serverpod(
        ['--mode=test', '--apply-migrations'],
        configOverride: (config) => config.copyWith(
          database: PostgresDatabaseConfig(
            host: '127.0.0.1',
            port: 0,
            user: 'postgres',
            password: 'local-disposable-test-only',
            dataPath: '${directory.path}/pgdata',
            name: 'home_snapshot_test',
          ),
        ),
      );
      configureAuth(pod, sessionPepper: 'public-home-snapshot-test-only');
      try {
        await pod.start(runInGuardedZone: false);
        admin = await pod.createSession(enableLogging: false);
        started = true;
      } catch (_) {
        await pod.shutdown(exitProcess: false);
        await directory.delete(recursive: true);
        rethrow;
      }
    });
    tearDown(() async {
      for (final client in clients) {
        client.close();
      }
      clients.clear();
      for (final session in sessions) {
        await session.close();
      }
      sessions.clear();
    });
    tearDownAll(() async {
      if (!started) return;
      await admin.close();
      await pod.shutdown(exitProcess: false);
      await directory.delete(recursive: true);
    });

    test(
      'a write committed while the snapshot is parked stays invisible',
      () async {
        final a = await user();
        final writer = await sessionFor(a.token);
        await endpoint.registerStepStream(a.session, 'register', 0);
        await _at(() => endpoint.submitSteps(a.session, _steps(700)));

        final parked = Completer<void>();
        final release = Completer<void>();
        final pending = _at(
          () => ProductService.read(
            a.session,
            (s) => homeSnapshot(
              s,
              afterWallet: () async {
                parked.complete();
                await release.future.timeout(_bound);
              },
            ),
          ),
        );
        late HomeSnapshot held;
        try {
          await parked.future.timeout(_bound);
          // Another session commits +7 and -3 while day and wallet are read
          // but themes, outfits and recentDays are not yet.
          final grant = await _at(
            () => endpoint.claimDay(writer, _date, 'claim', 1),
          );
          expect(grant.amount, 7);
          final store = await endpoint.purchaseTheme(writer, 'cloudy', 'theme');
          expect(store.balance, 4);
        } finally {
          if (!release.isCompleted) release.complete();
          held = await pending.timeout(_bound);
        }
        stdout.writeln('T15_HELD ${_summary(held)}');
        expect(held.date, _date);
        expect(held.day.revision, 1);
        expect(held.day.claimablePoints, 7);
        expect(held.day.grantedPoints, 0);
        expect(held.wallet.balance, 0);
        expect(held.themes.balance, 0);
        expect(
          held.themes.items.singleWhere((t) => t.themeId == 'cloudy').owned,
          isFalse,
        );
        expect(held.outfits.balance, 0);
        expect(held.recentDays.last.toJson(), held.day.toJson());

        final next = await _at(() => endpoint.getHomeSnapshot(a.session));
        stdout.writeln('T15_NEXT ${_summary(next)}');
        expect(next.day.revision, 2);
        expect(next.day.claimablePoints, 0);
        expect(next.day.grantedPoints, 7);
        expect(next.wallet.balance, 4);
        expect(next.themes.balance, 4);
        expect(
          next.themes.items.singleWhere((t) => t.themeId == 'cloudy').owned,
          isTrue,
        );
        expect(next.outfits.balance, 4);
        expect(next.recentDays.last.toJson(), next.day.toJson());
      },
    );

    test('empty account reads defaults without creating state', () async {
      final a = await user();
      final owner = a.session.authenticated!.userIdentifier;
      final s = await _at(() => endpoint.getHomeSnapshot(a.session));
      stdout.writeln(
        'T15_EMPTY profile=${s.profile} availability=${s.day.availability} '
        'wallet=${s.wallet.balance} '
        'owned=${s.themes.items.where((t) => t.owned).map((t) => t.themeId)} '
        'outfitsOwned=${s.outfits.items.where((o) => o.owned).length} '
        'recentDays=${s.recentDays.length} '
        'first=${s.recentDays.first.date} last=${s.recentDays.last.date}',
      );
      expect(s.profile, isNull);
      expect(s.day.date, _date);
      expect(s.day.availability, 'unknown');
      expect(s.day.steps, isNull);
      expect(s.wallet.balance, 0);
      expect(s.wallet.streamGeneration, 0);
      expect(s.themes.equippedTheme, 'sunny');
      expect(
        s.themes.items.where((t) => t.owned).map((t) => t.themeId),
        ['sunny'],
      );
      expect(s.outfits.items.where((o) => o.owned), isEmpty);
      expect(s.outfits.equippedOutfit, isNull);
      expect(s.outfits.breedId, isNull);
      expect(s.recentDays, hasLength(31));
      // Read-only: no account row is created by looking.
      expect(
        await ProductAccount.db.count(
          admin,
          where: (t) => t.authUserId.equals(authUserIdOf(owner)),
        ),
        0,
      );
    });

    test('profile equals getProfile and outfits see its breed', () async {
      final a = await user();
      await ProfileEndpoint().createProfile(
        a.session,
        ProfileInput(
          breedId: 'jindo',
          name: '친구',
          sex: 'male',
          dailyGoal: 7000,
        ),
        'profile',
      );
      final expected = await ProfileEndpoint().getProfile(a.session);
      final s = await _at(() => endpoint.getHomeSnapshot(a.session));
      stdout.writeln('T15_PROFILE ${s.profile?.toJson()}');
      expect(expected, isNotNull);
      expect(s.profile!.toJson(), expected!.toJson());
      expect(s.outfits.breedId, 'jindo');
    });

    test(
      'recentDays spans today-30..today without routes or gps reads',
      () async {
        final a = await user();
        await endpoint.registerStepStream(a.session, 'register', 0);
        await _at(() => endpoint.submitSteps(a.session, _steps(7000)));
        // 2026-10-14 09:00-09:01 KST: a stored GPS record on the same day.
        await RecordsEndpoint().saveConfirmed(
          a.session,
          GpsRecordInput(
            schemaVersion: 1,
            clientRecordId: const Uuid().v4obj(),
            startedAt: DateTime.utc(2026, 10, 14),
            endedAt: DateTime.utc(2026, 10, 14, 0, 1),
            source: 'watch',
            routePoints: [],
          ),
        );
        // Positive control: the per-day endpoint does see the route.
        expect(
          (await _at(() => endpoint.getDay(a.session, _date))).routes,
          hasLength(1),
        );

        // An ACCESS EXCLUSIVE lock blocks even plain SELECTs on gps_record,
        // so the snapshot can only finish here if it never touches that table.
        final locked = Completer<void>();
        final release = Completer<void>();
        final lock = admin.db.transaction((tx) async {
          await admin.db.unsafeExecute(
            'LOCK TABLE gps_record IN ACCESS EXCLUSIVE MODE',
            transaction: tx,
          );
          locked.complete();
          await release.future.timeout(_bound);
        });
        late HomeSnapshot s;
        try {
          await locked.future.timeout(_bound);
          s = await _at(
            () => endpoint.getHomeSnapshot(a.session),
          ).timeout(_bound);
        } finally {
          if (!release.isCompleted) release.complete();
          await lock.timeout(_bound);
        }
        final dates = s.recentDays.map((d) => d.date).toList();
        stdout.writeln(
          'T15_RANGE n=${dates.length} first=${dates.first} '
          'last=${dates.last} dayRoutes=${s.day.routes.length} '
          'routesTotal=${s.recentDays.fold(0, (n, d) => n + d.routes.length)}',
        );
        expect(dates, hasLength(31));
        expect(dates.first, '2026-09-14');
        expect(dates.last, _date);
        expect(dates.toSet(), hasLength(31));
        expect([...dates]..sort(), dates);
        expect(s.recentDays.every((d) => d.routes.isEmpty), isTrue);
        expect(s.day.routes, isEmpty);
        expect(s.day.steps, 7000);
        expect(s.recentDays.last.steps, 7000);
        // Same projection as the existing range endpoint for the window.
        final range = await _at(
          () => endpoint.listDays(a.session, dates.first, _date),
        );
        expect(
          s.recentDays.map((d) => d.toJson()).toList(),
          range.map((d) => d.toJson()).toList(),
        );
      },
    );

    test('generated client returns the snapshot over HTTP', () async {
      final a = await user();
      final s = await a.client.product.getHomeSnapshot();
      stdout.writeln(
        'T15_HTTP type=${s.runtimeType} date=${s.date} '
        'recentDays=${s.recentDays.length}',
      );
      expect(s, isA<api.HomeSnapshot>());
      expect(s.recentDays, hasLength(31));
      expect(s.recentDays.last.date, s.date);
      expect(s.day.date, s.date);
      expect(s.profile, isNull);
    });

    for (final (label, owner) in [
      ('SQL-shaped owner', "00000000-0000-0000-0000-000000000000' OR TRUE --"),
      ('plain non-UUID owner', 'not-a-uuid'),
      ('unknown UUID owner', '00000000-0000-0000-0000-000000000000'),
    ]) {
      test('rejects $label without returning another user snapshot', () async {
        final victim = await user();
        final victimId = victim.session.authenticated!.userIdentifier;
        await ProfileEndpoint().createProfile(
          victim.session,
          ProfileInput(
            breedId: 'jindo',
            name: '피해자',
            sex: 'male',
            dailyGoal: 7000,
          ),
          'profile',
        );
        await ProductService.run(
          victim.session,
          (s) => s.appendPointEntry(
            PointEntry(
              owner: victimId,
              entryKey: 'victim-credit',
              kind: 'steps',
              amount: 31337,
              policyVersion: stepPolicyVersion,
              createdAt: DateTime.utc(2026, 10, 14),
            ),
          ),
        );
        // Positive control: the victim's own snapshot does carry the data.
        final own = await _at(() => endpoint.getHomeSnapshot(victim.session));
        expect(own.wallet.balance, 31337);
        expect(own.profile!.name, '피해자');
        final accounts = await ProductAccount.db.count(admin);

        final probe = await pod.createSession(enableLogging: false);
        sessions.add(probe);
        probe.updateAuthenticated(
          AuthenticationInfo(owner, {}, authId: 'test'),
        );
        Object? outcome;
        try {
          outcome = await _at(() => endpoint.getHomeSnapshot(probe));
        } on NotAuthorizedException catch (e) {
          outcome = e;
        }
        stdout.writeln(
          'T15_PROBE label="$label" outcome=${outcome.runtimeType} '
          'reason=${outcome is NotAuthorizedException ? outcome.reason : '-'}',
        );
        expect(
          outcome,
          isA<NotAuthorizedException>().having(
            (e) => e.reason,
            'reason',
            AuthenticationFailureReason.unauthenticated,
          ),
        );
        // Read-only rejection: no account row was created for the probe.
        expect(await ProductAccount.db.count(admin), accounts);
      });
    }

    test('call after a committed deletion is not authorized', () async {
      final a = await user();
      await a.client.account.deleteAccount();
      await expectLater(
        _at(() => endpoint.getHomeSnapshot(a.session)),
        throwsA(isA<NotAuthorizedException>()),
      );
      await expectLater(
        a.client.product.getHomeSnapshot(),
        throwsA(isA<api.ServerpodClientUnauthorized>()),
      );
      stdout.writeln('T15_DELETED rejected=NotAuthorizedException+401');
    });

    test('deletion committed during the snapshot is rejected', () async {
      final a = await user();
      final parked = Completer<void>();
      final release = Completer<void>();
      final pending = _at(
        () => ProductService.read(
          a.session,
          (s) => homeSnapshot(
            s,
            afterWallet: () async {
              parked.complete();
              await release.future.timeout(_bound);
            },
          ),
        ),
      );
      try {
        await parked.future.timeout(_bound);
        await a.client.account.deleteAccount();
      } finally {
        if (!release.isCompleted) release.complete();
      }
      await expectLater(
        pending.timeout(_bound),
        throwsA(isA<NotAuthorizedException>()),
      );
    });
  });
}
