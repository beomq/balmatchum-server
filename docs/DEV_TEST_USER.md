# 개발 전용 가상 사용자

사용자가 승인한 통합 테스트용 **한 명**을 로컬 격리 DB에 생성/재사용한다.
카카오 사용자나 토큰을 만들지 않는다. HTTP endpoint는 추가하지 않으며 실제 로그인과
`requireLogin`은 그대로 사용한다. 기존 `ExternalIdentity`에 provider `dev-test`,
issuer `local-development`, audience `balmatchum_dev_test`, namespace `virtual-test`,
subject `single-user`를 저장한다. 스키마 변경은 없다.

## 실행

검증 SDK는 Dart 3.13.4, Serverpod 4.0.3이다. 저장소의 `server/` 패키지에서 실행한다.
기존 공유 개발 DB `balmatchum`을 사용하지 말고 **별도 일회용 로컬 PostgreSQL DB**
`balmatchum_dev_test`를 먼저 준비한다. 아래 변수는 bootstrap과 API 서버 양쪽 터미널에
동일하게 주입한다. 비밀번호와 pepper는 신뢰할 수 있는 로컬 비밀값 주입 방식으로
공급하며 셸 이력이나 파일에 붙여넣지 않는다. `.env`는 자동 로드하지 않는다.

```sh
cd server
export SERVERPOD_DATABASE_HOST=127.0.0.1
export SERVERPOD_DATABASE_PORT=8090
export SERVERPOD_DATABASE_NAME=balmatchum_dev_test
export SERVERPOD_DATABASE_USER=postgres
export SERVERPOD_RUN_MODE=development
: "${SERVERPOD_PASSWORD_database:?격리 DB 비밀번호 필요}"
: "${SERVERPOD_PASSWORD_serverSideSessionKeyHashPepper:?세션 pepper 필요}"
```

새 격리 DB에는 기존 migrations를 먼저 적용한다. 이 명령은 **격리 DB 환경변수 확인 후**
실행한다. bootstrap 자체는 migration을 적용하지 않는다.

```sh
dart run bin/main.dart --mode=development --apply-migrations
```

서버를 유지한 상태에서 동일한 환경을 가진 별도 터미널에서:

```sh
dart run bin/dev_test_user.dart --mode=development
```

도구는 `.dart_tool/dev-test-user-<임의값>/session.json` 경로만 출력한다.
디렉터리는 0700, 파일은 비밀값 쓰기 **전** 0600으로 설정하고 Git ignore 여부를 확인한다.
POSIX(macOS/Linux)와 Git checkout에서만 실행 가능하다. JSON은 SDK `AuthSuccess.toJson()`
형식이며 `token`, `authUserId`, `authStrategy` 등을 포함한다. 내용을 터미널로 출력하거나
도구 응답, 로그, 스크린샷, versioned 파일, `--dart-define`에 복사하지 않는다.
새 실행마다 같은 사용자로 세션을 교체한다. 이전 파일의 토큰은 무효다.
토큰은 기존 인증 설정대로 비활동 90일 만료이며 절대 만료는 없다. 테스트 종료 시
파일을 삭제하고 격리 DB의 수명을 종료한다. 파일 삭제만으로 세션이 폐기되지는 않는다.

도구는 `--mode=development` 한 인자만 허용하며 다른 모드/추가 옵션을 거부한다.
환경 `SERVERPOD_RUN_MODE`가 development와 충돌해도 거부한다. 유효 설정의 DB가
loopback 주소(localhost/127.0.0.1/::1)와 정확한 전용 이름이 아니면 DB 접근 전에 거부한다.
loopback으로 터널링한 운영 DB를 연결해서는 안 된다. 이름과 주소 검사는 DB의 출처를
증명할 수 없으므로 전용 DB 준비는 실행자의 책임이다.

## 앱 통합 접점

앱 담당자는 **개발 전용 로컬 테스트 harness**에서 보호된 파일을 안전한 경로로 읽고,
SDK 생성 client의 `Client.authKeyProvider`에 `ClientAuthKeyProvider`를 연결한다.
`get authHeaderValue`는 `Bearer <JSON token>`을 반환해야 한다. SDK 서버 세션 토큰을
카카오 ID token 입력이나 `loginKakao`에 전달하지 않는다. 앱의 실제 로그인 flow,
배포 설정, client pin 변경은 이 작업에 포함하지 않았다. 모바일 전달은 앱 담당자가
기기 로컬 보호 저장소로 수행하며 공유 파일/저장소/로그에 토큰을 넣지 않는다.

정상 확인은 같은 격리 DB/pepper의 API 서버에 연결한 뒤 `records.saveConfirmed(input)`과
`records.getMine(receipt.recordId)`를 호출한다. 무토큰 또는 교체 전 토큰은 401이어야 한다.
앱 직접 검증은 별도이며 서버 테스트 성공을 앱 검증으로 기록하지 않는다.

## 검증과 장애 확인

```sh
SERVERPOD_PASSWORD_database=local-disposable-test-only dart test --reporter expanded
dart analyze --fatal-infos
dart build cli --target bin/dev_test_user.dart --output build/dev_test_user
```

`test/integration/dev_test_user_test.dart`는 고정 지연 없이 내장 임시 PostgreSQL로 모드/DB
거부, private ignored 파일, 사용자 재사용, 세션 교체, Kakao identity 미생성,
실제 HTTP `requireLogin` 거부/통과를 검사한다. 오류 메시지는 예외나 stack trace 없이
고정 문구만 출력한다. 실패 시 모드 → DB host/name/port → 기존 migrations → DB 비밀번호
→ API와 동일한 pepper → Git ignore 및 POSIX 권한 순서로 확인한다.
출력 실패가 DB commit 이후 발생하면 다시 실행하여 세션을 교체한다.

## 4.0.3 실제 SDK 근거

설치된 아래 소스를 직접 확인했다. SDK 사용자 생성·세션 발급·검증·폐기 API를 사용한다.

- `serverpod_auth_core_server/lib/src/auth_user/business/auth_users.dart`: `AuthUsers.create`
- `serverpod_auth_core_server/lib/src/common/business/auth_services.dart`: `AuthServices`, authentication handler
- `serverpod_auth_core_server/lib/src/common/integrations/token_manager.dart`: `issueToken`, `revokeAllTokens`
- `serverpod_auth_core_server/lib/src/common/integrations/adapters/server_side_sessions_token_manager.dart`: 서버 세션 adapter
- `serverpod_database/lib/src/adapters/postgres/postgres_pool_manager.dart`: DB pool lazy start
- `serverpod/lib/src/server/serverpod.dart`: `createSession(enableLogging: false)`, `shutdown`

CLI는 `pod.start()`를 호출하지 않는다. DB pool lazy start를 사용하므로 listening server,
HTTP 응답, future calls 실행이 없다. identity 생성과 세션 교체는 한 DB transaction에서
고정 advisory lock으로 직렬화한다. 동시 실행 시 마지막 transaction의 세션만 유효하다.

### 실행 근거 (2026-10-14)

- Dart 3.13.4, Serverpod 4.0.3, 기준 develop `b938c29`.
- 양쪽 `pub get --enforce-lockfile`, server/client `analyze --fatal-infos`: exit 0.
- 포맷 44개 파일 변경 없음; 최종 전체 테스트 125개 통과: exit 0.
- 개발 사용자 CLI와 main CLI `dart build cli`: 각각 exit 0.
- 실제 bootstrap CLI를 임시 내장 DB에서 실행하고 보호 파일을 읽어 HTTP 조회 성공,
  stdout/stderr에 토큰 미포함, 사용자/세션 한 개 유지와 파일 정리까지 검증했다.
- production CLI는 exit 1로 거부했다. 생성 파일 drift와 `git diff --check` 이상 없음.
- 테스트 파일 fresh LSP 응답은 timeout이 있었으나 최종 전체 Dart analyze는 통과했다.
- 기존 Kakao 손상 토큰 테스트에서 SDK가 손상된 세션 키를 로그에 포함하는 동작을
  관찰했다. 이 도구의 정상 발급/출력에는 토큰 로그가 없지만 앱 harness는 토큰을
  변형해서 보내지 않아야 한다. SDK/실제 로그인 로그 정책 변경은 별도 범위다.
- 개발 Compose DB와 모바일 앱에서 사용자 직접 실행은 미검증이다. 실제 외부 사용자는
  생성하지 않았으며 테스트용 임시 DB와 출력 파일은 테스트에서 정리했다.
