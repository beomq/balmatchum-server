import 'dart:async';
import 'dart:io';

import 'package:balmatchum_client/balmatchum_client.dart' as api;
import 'package:balmatchum_server/src/auth/auth_setup.dart';
import 'package:balmatchum_server/src/generated/protocol.dart';
import 'package:balmatchum_server/src/generated/serverpod.dart' as generated;
import 'package:balmatchum_server/src/product/product_service.dart';
import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

ProfileInput input() => ProfileInput(
  breedId: 'jindo',
  name: '  발맞춤  ',
  sex: 'male',
  dailyGoal: 7000,
);
Matcher profileError(String code) => throwsA(
  isA<ProfileException>().having((e) => e.code, 'code', code),
);

class _Token implements api.ClientAuthKeyProvider {
  _Token(this.value);
  final String value;
  @override
  Future<String?> get authHeaderValue async => 'Bearer $value';
}

void main() {
  withServerpod('Profile read path', (builder, endpoints) {
    test(
      'getProfile completes while another session holds the account lock',
      () async {
        final a = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            const Uuid().v4(),
            {},
          ),
        );
        final session = a.build();
        await AuthUser.db.insertRow(
          session,
          AuthUser(
            id: UuidValue.fromString(session.authenticated!.userIdentifier),
            scopeNames: {},
          ),
        );
        final locked = Completer<void>();
        final release = Completer<void>();
        final write = ProductService.run(session, (s) async {
          locked.complete();
          await release.future.timeout(const Duration(seconds: 10));
        });
        try {
          await locked.future.timeout(const Duration(seconds: 10));
          expect(
            await endpoints.profile
                .getProfile(a)
                .timeout(const Duration(seconds: 5)),
            isNull,
          );
        } finally {
          release.complete();
          await write;
        }
      },
    );
  }, rollbackDatabase: RollbackDatabase.disabled);

  withServerpod('Owner scoped dog profile', (builder, endpoints) {
    final a = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        const Uuid().v4(),
        {},
      ),
    );
    final b = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        const Uuid().v4(),
        {},
      ),
    );

    setUp(() async {
      for (final owner in [a, b]) {
        final session = owner.build();
        await AuthUser.db.insertRow(
          session,
          AuthUser(
            id: UuidValue.fromString(session.authenticated!.userIdentifier),
            scopeNames: {},
          ),
        );
      }
    });

    test('all methods reject anonymous requests', () async {
      await Future.wait(
        [
          endpoints.profile.getProfile(builder),
          endpoints.profile.createProfile(builder, input(), 'create'),
          endpoints.profile.renameDog(builder, '멍멍', 'rename', 1),
          endpoints.profile.updateGoal(builder, 8000, 'goal', 1),
        ].map(
          (call) => expectLater(
            call,
            throwsA(isA<ServerpodUnauthenticatedException>()),
          ),
        ),
      );
    });

    test('create replay stores once and owners remain isolated', () async {
      expect(await endpoints.profile.getProfile(a), isNull);
      final first = await endpoints.profile.createProfile(a, input(), 'create');
      final replay = await endpoints.profile.createProfile(
        a,
        input(),
        'create',
      );
      expect(first.name, '발맞춤');
      expect(first.revision, 1);
      expect(replay.toJson(), first.toJson());
      expect(await DogProfile.db.count(a.build()), 1);
      expect(await endpoints.profile.getProfile(b), isNull);
      await expectLater(
        endpoints.profile.renameDog(b, '다른개', 'rename', 1),
        profileError('notFound'),
      );
      await expectLater(
        endpoints.profile.updateGoal(b, 1, 'goal', 1),
        profileError('notFound'),
      );
      await expectLater(
        endpoints.profile.createProfile(
          a,
          input().copyWith(dailyGoal: 8000),
          'create',
        ),
        profileError('idempotencyConflict'),
      );
      await expectLater(
        endpoints.profile.createProfile(a, input(), 'second'),
        profileError('alreadyExists'),
      );
      final other = await endpoints.profile.createProfile(
        b,
        input().copyWith(sex: 'female'),
        'create',
      );
      expect(other.sex, 'female');
      expect((await endpoints.profile.getProfile(a))!.sex, 'male');
    });

    test('invalid inputs do not write profile or request receipts', () async {
      for (final (value, code) in [
        (input().copyWith(name: '   '), 'invalidName'),
        (input().copyWith(name: 'a' * 13), 'invalidName'),
        (input().copyWith(name: '강아지🐶'), 'invalidName'),
        (input().copyWith(name: '강\n아지'), 'invalidName'),
        (input().copyWith(name: 'é'), 'invalidName'),
        (input().copyWith(breedId: 'unknown'), 'invalidBreed'),
        (input().copyWith(sex: 'other'), 'invalidSex'),
        (input().copyWith(dailyGoal: 0), 'invalidGoal'),
        (input().copyWith(dailyGoal: -1), 'invalidGoal'),
      ]) {
        await expectLater(
          endpoints.profile.createProfile(a, value, 'invalid'),
          profileError(code),
        );
      }
      for (final id in ['', 'a' * 129]) {
        await expectLater(
          endpoints.profile.createProfile(a, input(), id),
          profileError('invalidRequestId'),
        );
      }
      expect(await DogProfile.db.count(a.build()), 0);
      expect(await ProductRequest.db.count(a.build()), 0);
      // Decomposed Hangul is one grapheme, matching the app, not rune count.
      final name = '가' * 12;
      final created = await endpoints.profile.createProfile(
        a,
        input().copyWith(name: name),
        'create',
      );
      expect(created.name, name);
      await expectLater(
        endpoints.profile.renameDog(a, '!', 'bad-name', 1),
        profileError('invalidName'),
      );
      await expectLater(
        endpoints.profile.updateGoal(a, 0, 'bad-goal', 1),
        profileError('invalidGoal'),
      );
      expect((await endpoints.profile.getProfile(a))!.revision, 1);
    });

    test('CAS and replay preserve firstMetAt and original response', () async {
      final firstMet = DateTime.utc(2026, 10, 17, 1);
      final created = await withClock(
        Clock.fixed(firstMet),
        () => endpoints.profile.createProfile(a, input(), 'create'),
      );
      expect(created.firstMetAt, firstMet);
      final renamed = await withClock(
        Clock.fixed(firstMet.add(const Duration(days: 10))),
        () => endpoints.profile.renameDog(a, '  새 이름 A1  ', 'rename', 1),
      );
      expect(renamed.name, '새 이름 A1');
      expect(renamed.revision, 2);
      await expectLater(
        endpoints.profile.renameDog(a, '오래된', 'stale', 1),
        profileError('staleRevision'),
      );
      await expectLater(
        endpoints.profile.updateGoal(a, 9000, 'stale-goal', 1),
        profileError('staleRevision'),
      );
      final goal = await endpoints.profile.updateGoal(a, 9000, 'goal', 2);
      expect(goal.revision, 3);
      expect(goal.dailyGoal, 9000);
      expect(goal.firstMetAt, firstMet);
      expect(
        (await endpoints.profile.renameDog(
          a,
          '  새 이름 A1  ',
          'rename',
          1,
        )).toJson(),
        renamed.toJson(),
      );
      expect(
        (await endpoints.profile.updateGoal(a, 9000, 'goal', 2)).toJson(),
        goal.toJson(),
      );
      expect(
        (await endpoints.profile.createProfile(a, input(), 'create')).toJson(),
        created.toJson(),
      );
      await expectLater(
        endpoints.profile.renameDog(a, '다른', 'rename', 1),
        profileError('idempotencyConflict'),
      );
      await expectLater(
        endpoints.profile.updateGoal(a, 9001, 'goal', 2),
        profileError('idempotencyConflict'),
      );
      await expectLater(
        endpoints.profile.updateGoal(a, 9000, 'create', 3),
        profileError('idempotencyConflict'),
      );
      expect((await endpoints.profile.getProfile(a))!.toJson(), goal.toJson());
    });
  });

  group('Profile generated client over HTTP and real transactions', () {
    late Directory directory;
    late Serverpod pod;
    late Session admin;
    final clients = <api.Client>[];

    Future<api.Client> client({bool authenticated = true}) async {
      final c = api.Client('http://localhost:${pod.server.port}/');
      clients.add(c);
      if (authenticated) {
        final user = await AuthServices.instance.authUsers.create(admin);
        final token = await AuthServices.instance.tokenManager.issueToken(
          admin,
          authUserId: user.id,
          method: 'profile-test',
        );
        c.authKeyProvider = _Token(token.token);
      }
      return c;
    }

    setUpAll(() async {
      directory = await Directory.systemTemp.createTemp('profile-http-');
      pod = generated.Serverpod(
        ['--mode=test', '--apply-migrations'],
        configOverride: (config) => config.copyWith(
          database: PostgresDatabaseConfig(
            host: '127.0.0.1',
            port: 0,
            user: 'postgres',
            password: 'local-disposable-test-only',
            dataPath: '${directory.path}/pgdata',
            name: 'profile_test',
          ),
        ),
      );
      configureAuth(pod, sessionPepper: 'public-profile-test-only');
      try {
        await pod.start(runInGuardedZone: false);
        admin = await pod.createSession(enableLogging: false);
      } catch (_) {
        await pod.shutdown(exitProcess: false);
        await directory.delete(recursive: true);
        rethrow;
      }
    });
    tearDown(() {
      for (final c in clients) {
        c.close();
      }
      clients.clear();
    });
    tearDownAll(() async {
      await admin.close();
      await pod.shutdown(exitProcess: false);
      await directory.delete(recursive: true);
    });

    api.ProfileInput httpInput() => api.ProfileInput(
      breedId: 'toy-poodle',
      name: '친구',
      sex: 'female',
      dailyGoal: 5000,
    );
    Future<Object> outcome(Future<api.ProfileView> call) async {
      try {
        return await call;
      } on api.ProfileException catch (error) {
        return error.code;
      }
    }

    test(
      'anonymous rejection and owner isolation use generated transport',
      () async {
        final anonymous = await client(authenticated: false);
        await Future.wait(
          [
            anonymous.profile.getProfile(),
            anonymous.profile.createProfile(httpInput(), 'create'),
            anonymous.profile.renameDog('이름', 'rename', 1),
            anonymous.profile.updateGoal(1, 'goal', 1),
          ].map(
            (call) => expectLater(
              call,
              throwsA(isA<api.ServerpodClientUnauthorized>()),
            ),
          ),
        );
        final a = await client();
        final b = await client();
        final created = await a.profile.createProfile(httpInput(), 'create');
        expect(
          (await a.profile.createProfile(httpInput(), 'create')).toJson(),
          created.toJson(),
        );
        expect(await b.profile.getProfile(), isNull);
        final renamed = await a.profile.renameDog('새 친구', 'rename', 1);
        final goal = await a.profile.updateGoal(6000, 'goal', renamed.revision);
        expect(goal.firstMetAt, created.firstMetAt);
        expect((await a.profile.getProfile())!.dailyGoal, 6000);
        await expectLater(
          b.profile.updateGoal(9000, 'goal', 1),
          throwsA(
            isA<api.ProfileException>().having(
              (e) => e.code,
              'code',
              'notFound',
            ),
          ),
        );
      },
    );

    test('concurrent creates and CAS edits serialize per owner', () async {
      final a = await client();
      final countBefore = await DogProfile.db.count(admin);
      final results = await Future.wait([
        outcome(a.profile.createProfile(httpInput(), 'create-a')),
        outcome(a.profile.createProfile(httpInput(), 'create-b')),
      ]);
      expect(results.whereType<api.ProfileView>().length, 1);
      expect(results.whereType<String>(), ['alreadyExists']);
      expect(await DogProfile.db.count(admin), countBefore + 1);
      final edits = await Future.wait([
        outcome(a.profile.renameDog('이름 A', 'rename-a', 1)),
        outcome(a.profile.renameDog('이름 B', 'rename-b', 1)),
      ]);
      expect(edits.whereType<api.ProfileView>().single.revision, 2);
      expect(edits.whereType<String>(), ['staleRevision']);
      expect(
        (await a.profile.getProfile())!.firstMetAt,
        results.whereType<api.ProfileView>().single.firstMetAt,
      );

      final b = await client();
      final replays = await Future.wait([
        b.profile.createProfile(httpInput(), 'same'),
        b.profile.createProfile(httpInput(), 'same'),
      ]);
      expect(replays[0].toJson(), replays[1].toJson());
      expect(await DogProfile.db.count(admin), countBefore + 2);
    });
  });
}
