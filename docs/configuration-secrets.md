# 설정과 비밀값 관리

## 실행 모드와 파일

서버 패키지에서 실행하며 기본 모드는 `development`입니다. `--mode=test`처럼 명시하면 `config/test.yaml`을 선택합니다. `SERVERPOD_RUN_MODE`도 지원하지만 팀 안내에서는 모드를 명시해 오접속을 줄입니다.

| 모드 | 현재 파일/DB | 용도 |
| --- | --- | --- |
| development | `server/config/development.yaml`, localhost:8090, `balmatchum` | Compose PostgreSQL 16, 볼륨 유지 |
| test | `server/config/test.yaml`, `dataPath: .serverpod/test/pgdata` | 내장 PostgreSQL, 테스트 그룹별 임시 DB |
| staging / production | 아직 없음 | 배포 설계·승인 전. 모드만 바꿔 실행하지 않음 |

API 개발 포트는 8080, 테스트 API 포트는 0(동적 배정)입니다. Redis·웹·인증 provider는 설정하지 않았습니다. `serviceSecret`이 없어 Insights는 경고와 함께 비활성화되며 API는 정상 실행됩니다.

일반 설정은 YAML보다 대응 `SERVERPOD_*` 환경변수가 우선합니다. 예: `SERVERPOD_DATABASE_HOST`, `SERVERPOD_DATABASE_PORT`. Dart `config`/`configOverride`를 전달하는 별도 코드도 가능하지만 현재 진입점은 사용하지 않습니다. 프로세스에 남아 있는 DB 환경변수가 파일 값을 덮을 수 있으므로 실행 모드와 함께 점검합니다.

## 비밀번호 우선순위: 4.0.3 소스로 확인

같은 키는 아래에서 **나중 값이 우선**합니다.

1. `config/passwords.yaml`의 `shared`
2. 해당 모드(`development`, `test` 등)의 값
3. 전용 환경변수: `SERVERPOD_DATABASE_PASSWORD`, `SERVERPOD_REDIS_PASSWORD`, `SERVERPOD_SERVICE_SECRET`
4. `SERVERPOD_PASSWORD_` 접두어 환경변수. 예: `SERVERPOD_PASSWORD_database`

접두어 뒤 키 이름/대소문자를 그대로 사용합니다. 따라서 `SERVERPOD_PASSWORD_database`와 `SERVERPOD_DATABASE_PASSWORD`가 동시에 있으면 전자가 우선합니다. 팀 기본은 `SERVERPOD_PASSWORD_database` 하나입니다. 값은 문자열로 취급하며 YAML 숫자처럼 해석되지 않도록 따옴표를 씁니다.

`passwords.yaml`이 없어도 환경변수로 실행할 수 있습니다. 파일과 환경변수 어디에도 필수 database 값이 없으면 초기화가 실패합니다. 파일 대안의 **형식 설명용 예시**는 다음과 같습니다. 아래 문자열은 실제 비밀번호가 아니며 그대로 사용하지 않습니다.

```yaml
# server/config/passwords.yaml — 커밋 금지
shared: {}
development:
  database: 'REPLACE_WITH_LOCAL_DEVELOPMENT_SECRET'
test:
  database: 'local-disposable-test-only'
```

Compose는 이 YAML을 읽지 않습니다. 파일 대안을 쓰더라도 개발 Compose에 같은 database 비밀번호를 환경변수로 공급해야 합니다. 이중 관리 실수를 줄이기 위해 개발 기본은 환경변수 방식입니다.

## .env와 로컬 관리

**현재 `dart run bin/main.dart` 경로는 `.env`를 자동 로드하지 않습니다.** 앱 진입점에는 dotenv 로더가 없고 4.0.3 `PasswordManager`는 `passwords.yaml`과 `Platform.environment`만 읽습니다. `.env`를 만들었다는 사실만으로 서버에 주입됐다고 판단하지 않습니다. Docker Compose의 `.env` 치환은 별개이며, Compose가 읽은 값이 부모 셸의 Dart 프로세스로 되돌아오지 않습니다.

개발자는 비밀번호 관리자 또는 자신이 관리하는 신뢰 가능한 셸 환경 주입 방식을 사용합니다. 이 작업에서는 dotenv 패키지·로더·배포 secret manager를 추가하지 않습니다. 비밀값을 명령 이력·로그·스크린샷·PR에 출력하지 않습니다. 필요 시 로컬 파일 권한을 소유자 전용으로 제한합니다.

무시 대상: `**/config/passwords.yaml`, `**/.env`, `**/.env.*`, `.dart_tool/`, `build/`, 서버 `.serverpod/`. 예시를 `.env.example`로 추가하면 현재 규칙상 무시되므로 비밀값 없는 예시는 이 Markdown 안에서 관리합니다. `.gitignore`는 이미 추적되거나 유출된 비밀값을 회수하지 않습니다. 노출 시 리드와 원본 자격증명을 폐기·교체하고 별도로 기록/이력 영향을 처리합니다.

## DB 비밀번호 재사용

개발 DB 최초 생성 때 정한 비밀번호를 해당 볼륨의 수명 동안 안전하게 보관하고 재사용합니다. 매 실행마다 새 난수를 export하면 기존 DB 계정 비밀번호와 불일치합니다. `POSTGRES_PASSWORD` 환경변수 변경만으로 이미 초기화된 볼륨의 계정 비밀번호가 바뀌지 않습니다. 비밀번호 변경은 DB 계정과 소비자 설정을 함께 조정하는 별도 작업입니다. 데이터 삭제로 인증 오류를 덮지 않습니다.

현재 Compose 프로젝트 기본 이름은 디렉터리 이름 `server`에서 정해집니다. 예전 `balmatchum_server` 경로에서 생성한 개발 볼륨이 있다면 다른 Compose 프로젝트로 보일 수 있습니다. 기존 볼륨을 찾지 못했다고 새 DB를 운영 데이터로 오인하지 말고 기존 프로젝트 이름/볼륨을 확인합니다. 기존 프로젝트 이름이 확인됐다면 `docker compose -p <기존이름> ...`로 일관되게 지정할 수 있습니다. 이 환경에서는 Docker 데몬 중지로 실제 기존 볼륨은 확인하지 못했습니다.

## CI와 미래 배포

CI의 `ci-disposable-postgres-only`는 격리된 일회성 테스트 DB 전용 공개 값입니다. 실제 개발/운영 비밀번호가 아니며 운영으로 복사하지 않습니다. 테스트의 `local-disposable-test-only`도 같은 원칙입니다.

향후 staging/production은 별도 계정·DB·비밀값과 배포 시스템의 secret 주입을 설계해야 합니다. 저장소 YAML·워크플로에 실제 비밀값을 넣지 않고, 환경별 값·접근 권한·회전 책임을 합의합니다. 현재 배포 환경이나 cloud secret은 만들지 않았습니다. 공개 GitHub 저장소라는 점을 전제로 리뷰합니다.

근거와 실제 검증 범위는 [출처·검증 기록](sources-and-verification.md)에 있습니다.
