# Google / Apple 서버 인증 증분

Serverpod 및 auth/CLI **4.0.3**, Dart **3.13.4** 고정입니다. SDK 제공자의
검증·계정 생성·프로필 생성·세션 발급을 그대로 사용합니다. 자체 JWT 검증기나
이메일 기반 계정 연결은 추가하지 않았습니다. 기존 Kakao·제품·프로필 계약은 유지합니다.

## 생성 client 계약

```dart
Future<bool> client.googleIdp.isConfigured();
Future<AuthSuccess> client.googleIdp.login({
  required String idToken,
  required String? accessToken,
});
Future<AuthSuccess> client.googleIdp.loginWithCode({
  required String code,
  required String codeVerifier,
  required String redirectUri,
});
Future<bool> client.googleIdp.hasAccount();

Future<bool> client.appleIdp.isConfigured();
Future<AuthSuccess> client.appleIdp.login({
  required String identityToken,
  required String authorizationCode,
  required bool isNativeApplePlatformSignIn,
  String? firstName,
  String? lastName,
});
Future<bool> client.appleIdp.hasAccount();

Future<void> client.account.deleteAccount();
```

`AuthSuccess`는 `serverpod_auth_core_client` 타입이며 반환 `token`은
기존 서버 세션 토큰입니다. JWT access/refresh pair로 취급하지 않습니다.
`isConfigured`는 로컬 설정과 session pepper 활성 여부만 알려줍니다.
콘솔 설정·네트워크·자격증명 유효성 또는 배포 준비 완료를 뜻하지 않습니다.
제공자 누락 시 로그인 세 경로와 `hasAccount`는
`LoginException(code: 'configurationMissing')`으로 거부합니다.
설정된 제공자의 토큰 검증 오류는 SDK 계약을 유지합니다. Google은
`GoogleIdTokenVerificationException`, Apple 4.0.3의 비직렬화 검증 예외는
HTTP 500으로 전달됩니다. 어느 경우에도 계정이나 세션을 만들지 않습니다.

## 선택적 설정

모든 값은 기존 `pod.getPassword`를 통해 읽습니다. 환경변수는 키 앞에
`SERVERPOD_PASSWORD_`를 붙입니다. `.env`는 자동 로드하지 않습니다.

- 공통: `serverSideSessionKeyHashPepper`. 누락 시 기존처럼 기동은 허용하되 인증은 비활성입니다.
- Google: `googleClientSecret`에 OAuth **web client** JSON 전체를 넣습니다.
  `web.client_id`, `web.client_secret`, 비어 있지 않은 `web.redirect_uris`가 필요합니다.
  앱의 Google ID token audience는 이 web client ID여야 합니다.
- Apple 필수 묶음: `appleServiceIdentifier`, `appleBundleIdentifier`,
  `appleRedirectUri`(HTTPS), `appleTeamId`, `appleKeyId`, `appleKey`(P-256 PEM).
- Apple 선택 값: `appleAndroidPackageIdentifier`, `appleWebRedirectUri`.
  선택 값만 제공한 것도 잘못된 부분 설정입니다.

제공자 설정이 전혀 없으면 해당 제공자만 비활성이고 dev harness와 Kakao는 계속
사용할 수 있습니다. 일부만 제공하거나 빈 값·잘못된 JSON/URI/키를 제공하면
비밀값 없는 `StateError`로 시작을 실패시킵니다. pepper가 없어도 잘못된 제공자
설정을 조용히 무시하지 않습니다. 이 구문 검사는 실제 콘솔 자격증명 검증을 대신하지 않습니다.

Google 기본 `validateGoogleAccountDetails`는 given name/full name/verified email을
요구합니다. 앱의 계정 식별에 이들이 필요하지 않으므로 공식 확장 지점
`googleAccountDetailsValidation`에서 비어 있지 않은 검증된 `sub`만 요구합니다.
서명·issuer·audience·exp·iat는 SDK가 먼저 검증합니다. **4.0.3 SDK parser 자체는
email claim이 없으면 거부**합니다. 앱 정책으로 email을 식별자로 쓰는 것은 아니지만,
이 버전에서는 완전한 email-claim 없는 Google 로그인까지 지원하지 않습니다.
같은 email을 가진 다른 subject도 별도 AuthUser이며 Kakao/Apple과 자동 연결하지 않습니다.

## 세션 정리와 경쟁 조건

`GoogleIdpEndpoint.login`/`loginWithCode` 및 `AppleIdpEndpoint.login`은
SDK 호출이 반환한 **커밋 이후** 기존 `removeOlderSessions`를 호출합니다.
new-account callback은 세션 발급 이전에 실행되며 재로그인에는 실행되지 않으므로
정리 지점으로 사용하지 않았습니다. SDK token issuer 안에서 정리하는 방식도
아직 커밋되지 않은 세션/알림 문제가 있어 사용하지 않았습니다.

같은 AuthUser의 모든 로그인 방법을 대상으로 `(createdAt, id)`가 가장 큰
커밋된 세션을 남깁니다. 늦게 끝난 과거 로그인 응답이 최신 세션을 삭제하지 않습니다.
비활동 만료 90일, 절대 만료 없음도 유지합니다. 이 정책은 **엄격한 원자적 단일
세션 보장이 아닙니다**. 발급 commit과 정리 사이 이중 유효 구간이 있고 정리 실패
시 이전 세션이 다음 로그인까지 남을 수 있습니다. 정리 실패는 비밀값 없는 경고로
기록하고 이미 commit된 로그인 성공을 반환합니다. 동시 로그인 응답 중 하나는 이미
폐기된 토큰일 수 있으므로 응답 순서를 세션 최신 순서로 해석하면 안 됩니다.

## Apple 계정 삭제

설치 SDK의 `AppleAccount`에는 refresh token과 최초 발급 시 bundle/service ID
선택 플래그가 저장됩니다. `AuthUsers.delete`의 cascade만 사용하면 이 토큰까지
사라져 외부 철회를 재시도할 수 없으므로, 기존 AuthUser → ProductAccount 잠금
획득 후 로컬 삭제 전에 `SignInWithApple.revokeAuthorization`을 호출합니다.
이 API는 기존 전이 의존성 `sign_in_with_apple_server 1.0.0`의 공개 API이며,
버전을 바꾸지 않고 직접 의존성으로 선언했습니다.

- SDK 문서상 revoke HTTP 200만으로 잘못된 client ID까지 구별할 수 없으므로
  `validateRefreshToken`이 `RevokedTokenException`을 반환하는지도 확인합니다.
- 요청별 10초 timeout. 외부 오류·timeout·아직 유효한 토큰은
  `LoginException(code: 'appleRevocationFailed')`로 반환하고 로컬 삭제를 롤백합니다.
  Apple 응답 body/토큰은 오류에 포함하지 않습니다. 설정이 없으면 `configurationMissing`입니다.
- 외부 철회 성공 후 DB 실패는 **외부 철회까지 롤백할 수 없습니다**. 로컬 사용자,
  세션, 저장 refresh token은 남아 같은 삭제 요청으로 idempotent revoke를 재시도합니다.
  timeout도 외부에서 이미 성공했을 수 있으므로 실패를 철회 미수행의 증거로 쓰지 않습니다.
- 프로세스가 철회 후 종료되어도 DB 롤백으로 토큰은 보존됩니다. 자동 재시도 작업은
  없으며 사용자가 삭제를 다시 요청해야 합니다. 외부 호출 동안 사용자 잠금을 유지하므로
  같은 사용자의 제품/프로필 요청은 대기합니다. 다른 사용자는 잠그지 않습니다.
- 비 Apple 계정은 외부 호출 없이 기존 로컬 삭제를 수행합니다. Google/Kakao 외부
  연결 해제까지 수행했다고 표시하면 안 됩니다.

## 남은 운영 조건

실제 Google OAuth client와 Apple App/Service ID·Sign in with Apple capability·키·
redirect 등록 및 실제 기기 로그인/삭제는 자격증명 없이 수행하지 않았습니다.
현재 서버는 web server를 구성하지 않아 Apple callback/notification route를 mount하지
않습니다. Apple Android/web callback 및 서버 알림 처리는 별도 web server/HTTPS/콘솔
설정과 검증이 필요합니다. 직접 반환 토큰을 받는 native API와 구분해야 합니다.

SDK 4.0.3 Apple 구현은 `nonce: null`을 전달하며 기존 계정 로그인에서는 code를
재교환하지 않습니다. 재연결 사용자의 refresh token 갱신은 upstream issue #4105 TODO입니다.
이번 증분에서 커스텀 검증기나 provider fork로 이를 바꾸지 않았습니다. 기존 저장 토큰이
폐기된 뒤 Apple에 재연결된 계정의 최신 외부 grant 철회는 이 버전으로 보장할 수 없습니다.
이 제한과 실제 credential 검증 미완료 때문에 **Apple provider full-ready가 아닙니다**.

장애 확인 순서: `isConfigured` → password 키/콘솔 client audience → SDK 검증 오류 →
실제 서버 세션/정리 경고 → 삭제 시 저장 Apple token/client 선택과 외부 철회 결과 → DB rollback.
테스트는 `test/unit/social_auth_config_test.dart`와
`test/integration/social_auth_test.dart`이며 외부 HTTP만 대체하고 SDK와 PostgreSQL,
생성 client HTTP 경로는 실제로 실행합니다. 사용자 직접 검증과 외부 로그인 검증은 별도입니다.

## 2026-10-19 실행 근거

- 앱 FVM의 `fvm exec`로 Dart 3.13.4를 사용했습니다. 모든 명령에 작업 전용
  `RUN_TMP=/tmp/bm-auth-1019`, `TMPDIR=$RUN_TMP/tmp`,
  `XDG_CACHE_HOME=$RUN_TMP/cache`를 설정했습니다.
- 양쪽 `pub get --enforce-lockfile` 성공. lockfile의 버전·해시는 그대로이며
  두 기존 전이 의존성의 direct main/dev 분류만 바뀌었습니다.
- 신규 설정/인증 테스트 32개 통과 후 전체 서버 테스트 **181개 통과**.
  기존 Kakao·제품·프로필·삭제·dev harness 사용자·GPS 회귀를 포함합니다.
- 양쪽 `analyze --fatal-infos`: `No issues found!`.
  `format --output=none --set-exit-if-changed server client`: 94개 파일, 변경 0.
- CLI 4.0.3 generate 및 재생성 drift/미추적 생성 파일 검사 성공(exit 0).
  `dart build cli --target bin/main.dart --output build` 네이티브 bundle 생성 성공(exit 0).
  저장 모델을 바꾸지 않아 migration은 추가하지 않았습니다.
- 초기 테스트의 SDK 예외 타입 기대값과 HTTP GET 대역 처리 오류를 수정했고,
  테스트 전용 직접 의존성 누락 분석 경고 및 포맷 출력의 선행 빈 줄을 수정했습니다.
  최종 전체 테스트는 재시도 없이 한 번에 통과했습니다.
- LSP는 일부 요청에서 daemon timeout이 있었으므로 최종 근거는 위 실제 Dart 분석입니다.
  실제 외부 로그인/철회, 운영 배포, 사용자 직접 검증은 수행하지 않았습니다.

## 공식 근거

- https://docs.serverpod.dev/concepts/authentication/providers/google/setup
- https://docs.serverpod.dev/concepts/authentication/providers/apple/setup
- https://developer.apple.com/documentation/signinwithapplerestapi/revoke-tokens
- https://github.com/serverpod/serverpod/issues/4105
- 설치 소스: `serverpod_auth_idp_server-4.0.3`의 `GoogleIdpConfig`,
  `GoogleIdpUtils.fetchAccountDetails`, `GoogleIdp.loginWithCode`,
  `AppleIdpUtils.authenticate`, `AppleAccount` 및
  `sign_in_with_apple_server-1.0.0`의 `revokeAuthorization`/`validateRefreshToken`.
