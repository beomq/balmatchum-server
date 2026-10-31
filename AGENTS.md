# Balmatchum server

Work only inside this repository. Do not edit the app, design repository, or shared contracts. Agent instructions are English; user-facing reports are Korean.

## Scope and layout

- Serverpod and CLI are pinned to 4.0.3.
- Dart 3.13.4 is the validation SDK (Flutter 3.47.5 contains it).
- Server: `server`.
- Standalone generated client: `client`. Keep this path stable for Git dependencies pinned by the app owner.
- No Redis, authentication features, website, Flutter companion, or cloud storage integrations are configured.
- Development uses external PostgreSQL 16 via Compose. Tests use isolated embedded PostgreSQL through `config/test.yaml`, not the development database.

## Commands and generated code

Read `docs/onboarding.md`, `docs/configuration-secrets.md`, and `docs/sources-and-verification.md` before changing setup or configuration. These are the Korean team guides; keep commands portable and verify version-specific claims against Serverpod 4.0.3 source. Never assume `.env` is automatically loaded. Preserve `SETUP_REPORT.md` as historical evidence. Feature flags, forced-update policy, Sentry, and Fastlane remain discussion candidates, not authorized work.

Run `dart pub get --enforce-lockfile` in both packages. From the server package use `dart pub global run serverpod_cli:serverpod_cli --no-interactive --no-analytics generate`.

Never hand-edit `lib/src/generated/`, client `lib/src/`, or `test/integration/test_tools/`. Edit endpoint/model source, then regenerate with CLI 4.0.3. Create migrations with the CLI when stored models change. Commit generated code and lockfiles with the source change after explicit commit approval.

Check both packages with `dart format --output=none --set-exit-if-changed .` and `dart analyze --fatal-infos`; run `SERVERPOD_PASSWORD_database=local-disposable-test-only dart test` in the server. Build with `dart build cli --target bin/main.dart --output build`: `dart compile exe` cannot run the native dependency build hooks. Check regeneration for drift with `git diff --exit-code` and untracked-file detection on the generated directories. The root CI runs these checks. Servers/tests may be started for authorized local verification; clean up only processes you started.

## Secrets and release control

Create short-lived task branches from `develop`, then use pull requests and passing CI to integrate into `develop`. Never merge broken or unverified features into `develop`. Reserve `main` for release pull requests and version tags only; preserve its existing initial commit. Use `release/*` only when release stabilization overlaps subsequent work. The lead coordinates branch creation, commits, pushes, pull requests, merges, releases, remote protection changes, and deployment; do not perform these actions without explicit assignment. CI runs on pushes to `develop` and `main`, and on pull requests.

Supply `SERVERPOD_PASSWORD_database` through the environment. Never commit real passwords, `.env` files, `config/passwords.yaml`, PostgreSQL data, or credentials. The CI password is a public disposable test-only value for its private ephemeral database.

No commit, push, deployment, or app client pin changes without the lead/user's explicit assignment. Report command exit codes, test results, and blockers. Production/staging deployment is not configured.
