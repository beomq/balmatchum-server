# 네이버 OIDC 인증 백엔드

## 범위와 생성 계약

Serverpod/CLI 4.0.3, Dart 3.13.4. 앱은 브라우저에서 받은 code를 서버로 전달하고,
서버만 client secret으로 교환합니다. 프로필 API의 access token이나 앱이 전달한
사용자 ID를 audience 검증의 대용으로 사용하지 않습니다.

```dart
Future<bool> client.naver.isConfigured();
Future<NaverLoginChallenge> client.naver.beginLogin({
  required String codeChallenge,
});
Future<AuthSuccess> client.naver.completeLogin({
  required UuidValue attemptId,
  required String code,
  required String state,
  required String codeVerifier,
});
```

`NaverLoginChallenge`: `UuidValue attemptId`, `String authorizationUrl`,
`String state`, `String redirectUri`, `DateTime expiresAt`.
`AuthSuccess.token`은 기존 서버 세션 토큰이며 OAuth access token이 아닙니다.

앱은 안전한 난수 32바이트를 padding 없는 base64url로 인코딩한 verifier를 만들고,
`BASE64URL(SHA256(ASCII(verifier)))`를 begin에 전달합니다. verifier는 브라우저 URL에
넣지 않고 해당 로그인 시도 동안 앱 메모리에만 보관합니다. 반환 URL을 열기 전에
공식 authorize origin/path와 앱 flavor의 고정 callback을 확인해야 합니다.
callback의 전체 URI와 state를 비교하고 중복 query/오류/없는 code를 거부한 뒤
complete를 호출합니다. client secret은 앱으로 내려가지 않습니다.

`isConfigured`는 서버 로컬 설정과 session pepper 활성 여부만 뜻합니다.
네이버 콘솔의 callback 승인, 실제 자격증명 유효성, 실제 기기 복귀 성공을
증명하지 않습니다.

## 검증과 일회성 소비

`naver_provider.dart`는 5분 시도에 state/nonce의 SHA-256, S256 challenge,
client ID와 고정 redirect를 저장합니다. 원문 state/nonce/verifier/code/ID token은
저장하지 않습니다. `completeLogin`은 ID, state digest, verifier challenge,
client ID, redirect, 만료, 미소비 조건을 하나의 DB UPDATE로 검증·소비합니다.
**소비를 먼저 commit한 후** 코드를 교환하므로 동시 complete 중 하나만 외부
교환에 도달합니다. 외부 timeout·잘못된 ID token·후속 DB 실패도 소비를 되돌리지 않습니다.
실패 또는 응답 유실 후에는 새 begin으로 다시 로그인해야 합니다.

공식 discovery의 `/oauth2/authorize`, `/oauth2/token`, `/oauth2/jwks`,
`/oauth2/revoke`만 호출합니다. OAuth-only `/oauth2.0/*`와 섞지 않습니다.
요청에는 `scope=openid`, state, nonce, S256을 항상 포함합니다.
서버 교환은 POST `client_secret_post` 및 동일 redirect/verifier를 사용합니다.
외부 요청은 각각 10초 제한이며 HTTP redirect를 따라가지 않습니다.
ID token 헤더의 `jku`, `x5u` 같은 URL을 가져오지 않습니다.

기존 Kakao 검증기를 `OidcTokenVerifier`로 공유하고 Kakao는 고정 issuer wrapper를
유지했습니다. 검증은 기존 `dart_jsonwebtoken` RSA/JWK 구현을 사용합니다.
RS256, kid, 공개 RSA key, 서명, issuer `https://nid.naver.com`,
audience, azp, exp/iat/nbf, 비어 있지 않은 sub, 시도 nonce digest를 검사합니다.
시간 허용 오차 60초, JWKS 1시간 cache 및 unknown-kid 단일 갱신/분당 제한은
기존 계약과 같습니다. 시도 5분 만료에는 시간 오차를 추가하지 않습니다.
사용 가능한 cache가 없는 JWKS 장애는 인증 실패입니다.

오류 코드는 `configurationMissing`, `invalidAttempt`, `invalidToken`,
`temporarilyUnavailable`, `naverRevocationFailed`입니다. 공급자 응답 본문이나
토큰을 오류에 포함하지 않습니다. nonce·서명 검증 실패 시 계정/세션을 만들지 않습니다.

## 제공자 분리와 세션

계정 키는 `(naver, https://nid.naver.com, clientId, oidc, sub)`입니다.
이메일·이름·프로필을 요청/저장하지 않으며 다른 제공자 또는 같은 이메일의
다른 sub와 연결하지 않습니다. Kakao/Google/Apple/Naver는 별도 사용자입니다.
unique identity 경합만 재시도하며 이미 교환한 코드를 다시 교환하지 않습니다.

기존 서버 세션의 비활동 90일, 절대 만료 없음, commit 후
`removeOlderSessions`를 그대로 사용합니다. 정리 실패는 비밀값 없는 경고 후 로그인
성공을 유지하고 다음 로그인에서 재시도합니다. commit과 정리 사이의 이중 유효 구간,
정리 실패 시 기존 세션 잔존이라는 기존 한계가 있습니다.

`deleteStaleLoginAttempts`는 Kakao와 Naver의 만료 후 1일을 초과한 시도를 함께
삭제합니다. 운영 scheduler는 기존처럼 아직 등록하지 않았습니다.

## 탈퇴와 최소 추가 저장

네이버 문서는 탈퇴/연동 해제 시 token revocation을 안내하며 refresh token을
철회하면 연결된 access token도 폐기한다고 명시합니다. **모든 과거 grant까지
철회한다는 보장은 아니므로** 성공한 로그인마다 `NaverGrant`에 client ID와
refresh token을 보관합니다. ID/access token, 이메일, 프로필은 보관하지 않습니다.
refresh token이 없는 교환 응답도 받아들이지 않습니다.

`NaverGrant`는 serverOnly 모델이며 생성 앱 client에 포함되지 않습니다.
기존 Apple 저장 방식과 같이 DB가 읽을 수 있는 credential입니다. 이 증분은 별도
KMS나 앱 수준 암호화를 도입하지 않습니다. DB/백업 접근 통제·암호화·파기 정책은
배포 전 운영 조건입니다. token은 로그인 갱신에 사용하지 않고 탈퇴 철회에만 씁니다.
성공한 grant는 탈퇴까지 보관하므로 로그인 횟수에 따라 행이 증가합니다.
로그인 저장 경로는 기존 결제 코드와 같은 `enableLogging: false` 내부 DB 세션을
사용합니다. 느린/실패 쿼리 로깅을 켜도 refresh token 바인딩 값을 기록하지 않으며,
실패 행을 포함할 수 있는 DB 예외는 `temporarilyUnavailable`로 치환합니다.

`deleteAccount`는 기존 AuthUser → ProductAccount 잠금 뒤 모든 Naver grant를
`/oauth2/revoke`로 철회합니다. `token_type_hint=refresh_token`과 서버 secret을
보내며 공식 규격에 따라 HTTP 200(이미 폐기된/없는 token 포함)을 성공으로 봅니다.
실패·redirect·timeout은 로컬 삭제를 rollback하여 재시도 credential을 남깁니다.
client ID가 저장 grant와 달라진 경우도 삭제를 fail closed합니다.

성공하면 기존 identity 삭제와 AuthUser 삭제에 의해 grant/세션이 cascade됩니다.
로그인도 AuthUser 잠금을 획득한 뒤 grant 저장/세션 발급을 하므로 삭제와 직렬화합니다.
외부 철회는 DB rollback으로 취소할 수 없습니다. 중간 철회 성공 후 DB 실패 또는
프로세스 종료 시 로컬 grant가 남고, 같은 삭제 요청으로 idempotent 철회를 재시도합니다.
자동 재시도 작업은 없습니다. 외부 호출 중 해당 사용자 요청이 잠금을 기다릴 수 있습니다.

코드 교환 직후 프로세스가 종료되거나 검증/DB 저장이 실패하면 외부에서 발급된
credential이 로컬에 저장되지 않을 수 있습니다. 외부 토큰 발급과 DB commit의
분산 원자성을 보장하지 않으며 이런 실패에서 로컬 계정/세션 발급을 성공 처리하지 않습니다.

## 설정 및 외부 차단 조건

`pod.getPassword`의 필수 묶음:

- `naverClientId`
- `naverClientSecret`
- `naverRedirectUri`
- 공통 `serverSideSessionKeyHashPepper`

환경변수는 `SERVERPOD_PASSWORD_` 접두어를 사용합니다. `.env` 자동 로드는 없습니다.
Naver 세 값이 모두 없으면 provider 비활성, 일부 누락/빈 값/잘못된 redirect이면
값 없는 `StateError`로 기동을 실패시킵니다. pepper가 없어도 부분 설정을 무시하지 않습니다.

서버마다 redirect는 하나입니다. 허용하는 URI는 query/fragment/userinfo 없는 고정
HTTPS callback 또는 아래 **정확한 두 URI 중 하나**입니다. endpoint에서 redirect를
입력받거나 임의 scheme/host/path를 허용하지 않습니다.

- 개발: `com.beomq.balmatchum.dev://naver/callback`
- 운영: `com.beomq.balmatchum://naver/callback`

**위 custom scheme을 네이버 콘솔이 실제로 등록·승인하는지는 미검증입니다.**
공식 OIDC 명세는 등록 callback과 같은 URI를 요구하고 scheme 허용 목록은 제시하지
않습니다. 이 코드의 allowlist와 provider의 등록 수락을 같은 의미로 취급하면 안 됩니다.
등록이 거부되면 고정 HTTPS app link 또는 별도 안전한 HTTPS bridge 설계가 필요합니다.
현재 서버는 callback bridge를 제공하지 않으며 앱의 HTTPS app-link 설정도 별도입니다.

실제 Naver 애플리케이션/OIDC 활성화·동의·등록 URI·client ID/secret 및 iOS/Android
브라우저 복귀/철회는 콘솔과 자격증명 없이 검증하지 않았습니다. 네이버 OIDC 코드
교환·RS256 검증을 fixture로 검증한 것이 운영 OAuth 성공의 증거는 아닙니다.
실 OAuth, 콘솔 변경, push 또는 배포를 수행하지 않았습니다.

## 검증과 장애 확인

`test/unit/naver_config_test.dart`와 `test/integration/naver_auth_test.dart`는 실제
생성 client HTTP, 서버 인증, 격리 PostgreSQL 및 CLI migration을 실행합니다.
외부 HTTP만 fixture이며 실제 RSA 서명/JWKS 검증기를 실행합니다. 오류 입력,
위조/누락 claim, issuer/audience/nonce/만료, PKCE/state, 재생/동시 소비,
같은 identity 경합, 네 제공자 분리, 90일 세션, 정리, 철회/rollback을 검증합니다.

직접 재현: 고정 Dart 환경에서 서버 패키지의
`SERVERPOD_PASSWORD_database=local-disposable-test-only dart test test/unit/naver_config_test.dart test/integration/naver_auth_test.dart`.
실패 시 `isConfigured` → password 묶음/pepper → 등록 callback과 앱 flavor →
state/verifier 시도 수명 → 코드 교환/JWKS → 세션 정리 → 철회/DB rollback 순으로 확인합니다.
코드/token/secret을 로그에 추가해 진단하지 않습니다.

## 2026-10-21 실행 근거

- 시작 상태는 `feat/full-features`, HEAD
  `4487b88ced56307527b7f951bd1916cc724b7cc6`, worktree clean.
- 각 명령에 독립 `mktemp -d /tmp/bm-naver.XXXXXX`의 `RUN_TMP`,
  `TMPDIR=$RUN_TMP/tmp`, `XDG_CACHE_HOME=$RUN_TMP/cache`를 사용했습니다.
  Dart 3.13.4/Serverpod CLI 4.0.3, 양 패키지 `pub get --enforce-lockfile` exit 0.
- CLI `generate`와 `create-migration` exit 0.
  `20261021025533591`은 `naver_grant`, `naver_login_attempt` 추가와 FK/index만
  포함하며 기존 데이터를 삭제/변경하지 않습니다. 격리 PostgreSQL 테스트에서 실제
  적용했습니다. 개발/운영 DB에는 적용하지 않았습니다.
- 초기 신규 테스트의 짧은 test pepper와 비정규 base64 padding 오류 전달을 수정한 뒤
  신규 테스트 47개 통과. 이후 credential SQL 오류의 비로깅/비밀값 제거 회귀를 추가해
  Kakao/OIDC/Google/Apple/Naver/계정 삭제 관련 **177개 모두 통과**, exit 0.
  마지막 관련 테스트 로그에서 credential marker, secret, access token fixture 원문
  일치가 없음을 확인했습니다. 외부 네이버 호출은 fixture입니다.
- 양 패키지 `analyze --fatal-infos` 결과 `No issues found!`.
  최신 소스 서버 분석도 동일. 최종 format 검사 160개 파일, 변경 0.
  일부 LSP 응답 timeout은 CLI 분석으로 확인했으며 YAML LSP는 설치되어 있지 않습니다.
- 생성 파일을 index 기준으로 고정한 뒤 재생성하여 `git diff --exit-code` 및
  미추적 생성 파일 검사 통과 (`DRIFT_CLEAN`). 생성 파일은 직접 수정하지 않았습니다.
  최신 소스의 `dart build cli --target bin/main.dart --output build` exit 0.
- 첫 전체 회귀는 **330개 통과 / 기존 퀴즈 테스트 1개 실패**였습니다.
  `quiz_engine_test.dart:216`의 HTTP getToday는 실제 2026-10-21을 사용하지만
  광고 fixture 시계는 2026-10-19여서 `AdException(invalidTarget)`이 발생했습니다.
  해당 퀴즈/광고 소스는 이 인증 변경에서 수정하지 않았습니다.
  부모 작업자가 시계 주입 회귀 수정과 별도 커밋을 담당합니다.
  credential 보호 변경 후 최종 전체 회귀도 **331개 통과 / 같은 퀴즈 테스트 1개 실패**,
  exit 1이었습니다. 전체 green으로 보고하지 않으며 인증 관련 177개는 별도로 통과했습니다.

## 공식 근거 (2026-10-21 직접 조회)

- https://developers.naver.com/docs/login/devguide/devguide.md
  - 3.5.1~3.5.7: OIDC 전용 경로, PKCE, nonce, code 교환과 claim 검증.
  - 4.3: refresh/access token 쌍 철회, 상태 코드와 idempotent 성공.
- https://nid.naver.com/.well-known/openid-configuration
  - issuer `https://nid.naver.com`, response `code`, S256, RS256, pairwise.
  - token/revocation auth `client_secret_post` 또는 `none`; 서버는 전자를 사용.
  - revocation endpoint `/oauth2/revoke`; 일반 guide의 `/oauth2.0/revoke`와 구분.
