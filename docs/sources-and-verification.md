# 공식 근거와 검증 범위

확인 기준: 2026-09-26, 설치된 Serverpod/CLI **4.0.3**, Dart **3.13.4**. 이 문서는 현재 코드·실행 결과와 문서 설명을 구분합니다. 사용자 직접 실행·이해 확인은 아직 별도입니다.

## 공식 문서와 제작자 가이드

- 설정: https://docs.serverpod.dev/concepts/configuration
- 시작/생성: https://docs.serverpod.dev/get-started
- 모델과 migration: https://docs.serverpod.dev/get-started/working-with-the-database
- 제작자 4.0.3 설정 가이드: https://github.com/serverpod/serverpod/blob/4.0.3/packages/serverpod/skills/serverpod-configuration/SKILL.md
- 제작자 4.0.3 테스트 가이드: https://github.com/serverpod/serverpod/blob/4.0.3/packages/serverpod/skills/serverpod-testing/SKILL.md
- 비밀번호 우선순위 구현: https://github.com/serverpod/serverpod/blob/4.0.3/packages/serverpod_shared/lib/src/password_manager.dart

docs.serverpod.dev 본문은 이번 직접 fetch에서 비어 있어 Context7의 `/websites/serverpod_dev`, `/serverpod/serverpod_docs` 조회 결과로 확인했습니다. 버전 고정 제작자 가이드와 비밀번호 소스는 위 태그의 raw 원문을 직접 읽고 설치 패키지와 대조했습니다. 검색 요약을 버전 고정 API 계약으로 취급하지 않습니다.

## 버전·저장소 차이

| 문서 설명/검색 결과 | 이번 저장소에서 확인한 사실 |
| --- | --- |
| 최신 가이드의 신규 프로젝트는 내장 PostgreSQL 사용 | 개발은 의도적으로 외부 Compose PostgreSQL 16, 테스트만 `dataPath` 기반 내장 DB |
| 일반 명령 `serverpod generate` | 실제 사용 명령은 `dart pub global run serverpod_cli:serverpod_cli --no-interactive --no-analytics generate`; CLI 4.0.3 고정 |
| Context7 일부 결과에 `secrets.yaml`, `_migrations` 또는 롤백 가능성 표현 | 4.0.3 로더는 `config/passwords.yaml`, 저장소는 `server/migrations/`; 자동 역방향 롤백을 보장하지 않음 |
| 일반 문서의 환경변수 우선 설명 | 설치 `PasswordManager.loadPasswordsFromMap`의 spread 순서로 shared < 모드 < 전용 환경변수 < `SERVERPOD_PASSWORD_*` 확인 |
| `.env` 사용 관행 | 현재 Dart 진입점/비밀번호 로더에 자동 로드 없음. Compose의 치환과 구분 |
| `dart compile exe`로 단일 실행 파일 생성 | 이 의존성 구성의 native hooks 때문에 `dart build cli` 필요 |

4.0.3 `PasswordManager.loadPasswords`는 지정 서버 디렉터리의 `config/passwords.yaml`을 읽고 `Platform.environment`를 전달합니다. 현재 `server/bin/main.dart` → `server/lib/server.dart`는 dotenv를 추가하지 않습니다. CLI 소스에서도 dotenv/.env 로더를 찾지 못했지만, 이 문서의 보장은 확인한 `dart run bin/main.dart` 경로로 한정합니다.

## 이번 문서 작업에서 실행한 검증

| 명령 | 종료 코드/결과 |
| --- | --- |
| CLI `--version` | 0, 4.0.3 |
| 양쪽 `dart pub get --enforce-lockfile` | 0 |
| CLI `generate` | 0 |
| `dart format --output=none --set-exit-if-changed . ../client` (서버 패키지) | 0, 14개 파일 변경 없음 |
| 양쪽 `dart analyze --fatal-infos` | 0, No issues found |
| 테스트용 비밀번호 환경변수 + `dart test --reporter expanded` | 0, PostgreSQL 연결·greeting 2개 통과 |
| `dart build cli --target bin/main.dart --output build` | 0, 네이티브 에셋 포함 bundle 생성 |
| CLI `create-migration --help` | 0, 옵션 확인만 수행 |
| 생성 코드 `git diff --exit-code` 및 미추적 생성 파일 검사 | 0, drift 없음 |
| 비밀값 없는 환경변수로 `docker compose config --quiet` | 0, 구문·치환 검증 |
| `git check-ignore` | 0, passwords.yaml/.env/내장 DB 제외 확인 |
| `git diff --check` 및 문서 상대 링크 검사 | 0 / 끊어진 링크 없음 |
| `docker info` | 1, Docker daemon socket 연결 실패 |

불필요한 migration을 만들지 않았으며 개발 Compose 기동·실제 개발 DB migration 적용은 데몬 중지로 재검증하지 못했습니다. 기존 초기화/경로 변경 시 실제 API와 client 연결 결과는 [과거 기록](../SETUP_REPORT.md)에 남아 있습니다. 이번에는 문서 변경이므로 해당 검증 이력을 새 실행으로 표시하지 않습니다.

CLI 설치 명령 자체는 이미 설치된 4.0.3을 재설치하지 않았습니다. 문서의 설치 안내는 기존 CLI 설치 방식과 확인된 실행 버전에 근거합니다. 다른 개발자의 OS/FVM 설치 과정, GitHub Actions 원격 실행, staging/production 및 사용자 직접 확인은 검증하지 않았습니다. 기존 `sqlparser` 최신 버전 알림은 lockfile과 호환 제약에 따른 정보 메시지이며 의존성을 변경하지 않았습니다.
