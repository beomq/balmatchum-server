# 서버 초기화 검증 기록

## 결과

- Serverpod/CLI 4.0.3, Dart 3.13.4.
- 서버: `balmatchum/balmatchum_server`.
- 독립 클라이언트: `balmatchum/balmatchum_client`.
- 최초 마이그레이션: `balmatchum/balmatchum_server/migrations/20260926020708431`.
- 루트 CI: `.github/workflows/ci.yml`; 루트 `README.md`, 영문 `AGENTS.md`.
- Git main 초기화, origin `https://github.com/beomq/balmatchum-server.git` 설정. 스테이징/커밋/푸시/배포 없음.

## 실행 결과

| 명령 | 종료 코드 | 결과 |
| --- | ---: | --- |
| `dart --version` / CLI `--version` | 0 | 3.13.4 / 4.0.3 |
| 비대화형 `create balmatchum --template server --database --no-redis --no-auth --no-webapp --no-website --ide none` | 1 | 파일 생성 후 내부 `flutter pub get` 실패. 독립 Dart 패키지로 정리해 해결 |
| 양쪽 패키지 `dart pub get --enforce-lockfile` | 0 | 서버·클라이언트 lockfile 검증 |
| CLI `generate` / `create-migration` | 0 | 서버·클라이언트·테스트 헬퍼·마이그레이션 생성 |
| CLI `generate` 재실행 | 0 | up to date, 생성 파일 10개 해시 변경 없음 |
| 양쪽 패키지 `dart format --output=none --set-exit-if-changed .` | 0 | 변경 없음 |
| 양쪽 패키지 `dart analyze --fatal-infos` | 0 | No issues found |
| 비밀번호 없이 `dart test` / 실제 서버 실행 | 1 | 실제 서버에서 Missing password for database 확인 |
| `SERVERPOD_PASSWORD_database=local-disposable-test-only dart test --reporter expanded` | 0 | PostgreSQL SELECT 1 및 greeting 테스트 2개 통과, 마이그레이션 적용 |
| `dart compile exe bin/main.dart -o build/server` | 255 | 네이티브 build hooks 미지원. 아래 명령으로 교체 |
| `dart build cli --target bin/main.dart --output build` | 0 | 네이티브 에셋 포함 bundle 생성 |
| 테스트 모드 서버에 `dart run example/smoke.dart http://localhost:56434/` | 0 | 실제 생성 클라이언트 `CLIENT_SMOKE_OK` |
| 검증용 서버 Ctrl-C 종료 | 130 | 이번 작업에서 시작한 서버만 종료 |
| 비밀번호 환경변수를 제공한 `docker compose config --quiet` | 0 | Compose 설정 유효 |
| `docker info` | 1 | Docker daemon socket 연결 실패 |
| `git init -b main` / `git remote add origin ...` | 0 | 서버 경로만 초기화 |
| `git log -1 --oneline` | 128 | 아직 커밋 없음(요청대로) |

## 남은 확인과 제한

- Docker 데몬이 내려가 있어 외부 PostgreSQL Compose 기동은 검증하지 못했습니다. 내장 PostgreSQL 통합 테스트 및 실제 API 호출은 검증했습니다.
- 원격은 비어 있으며 push하지 않았으므로 GitHub Actions의 Linux 실행은 미확인입니다. 로컬 macOS에서 대응 명령을 실행했습니다.
- YAML language server 및 디렉터리 진단이 선택한 Biome은 설치되지 않았습니다. Dart 파일 LSP와 양쪽 `dart analyze`는 통과했고 Compose는 CLI로 검증했습니다.
- serviceSecret 미설정으로 Insights가 비활성화됩니다. 운영 구성·배포·인증은 작업 범위 밖입니다.
- 생성 비밀번호를 포함했던 템플릿 CI/IDE 설정과 passwords.yaml을 제거했습니다. 비밀 파일·DB 데이터는 gitignore로 제외했고 양쪽 lockfile은 커밋 대상입니다.
- 사용자 직접 실행 및 앱의 Git commit pin은 아직 수행하지 않았습니다. 리드가 커밋 승인과 앱 pin을 조정합니다.
