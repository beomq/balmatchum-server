# 계정 삭제 API

생성 클라이언트 계약은 `Future<void> client.account.deleteAccount()`입니다.
인자는 없으며 인증된 사용자 자신만 삭제합니다. 기존 profile/product/records 계약은
그대로 유지됩니다. 성공 응답 후 앱은 저장된 서버 토큰과 로컬 사용자 데이터를 지워야 합니다.
삭제된 토큰으로 재호출하면 성공 재생이 아니라 HTTP 401입니다.

## 원자성과 잠금

`lockProductAccount`는 같은 트랜잭션 안에서 먼저 SDK `AuthUser`를
`FOR UPDATE`로 잠그고 존재를 확인한 뒤 `ProductAccount`를 생성·잠급니다.
profile, product, GPS 읽기·쓰기는 모두 이 경계를 통과합니다.
`AccountEndpoint.deleteAccount`도 같은 순서로 잠근 뒤 아래 데이터를 지웁니다.

- `dog_profile`, `gps_record` (삭제 표식과 실제 payload 모두 포함)
- `step_revision`, `product_day`, `point_entry`, `quiz_state`, `theme_ownership`
- `product_request` (과거 프로필 응답 포함), `product_account`
- `external_identity`를 먼저 삭제하고 SDK `AuthUsers.delete(transaction: tx)` 호출

마지막 SDK 삭제는 `serverpod_auth_core_user`와 FK CASCADE로 연결된 서버 세션,
SDK 프로필·이미지 메타데이터, refresh token 및 설치된 IDP 계정 행을 같은 트랜잭션에서
삭제합니다. 애플리케이션 `ExternalIdentity`는 RESTRICT이므로 반드시 먼저 삭제합니다.
로컬 삭제 실패는 전체 롤백됩니다. Apple 계정은 로컬 삭제 전 저장된 refresh token을
SDK 공개 API로 철회하고 폐기를 확인합니다. 외부 철회는 DB와 함께 롤백할 수 없으며,
실패 시 로컬 토큰을 보존해 삭제를 재시도합니다. 자세한 실패 의미와 SDK 재연결 제한은
[Google/Apple 인증 문서](SOCIAL_AUTH_API.md)를 따릅니다.
Naver는 저장된 모든 grant의 refresh token을 로컬 삭제 전에 철회하고 실패 시
rollback합니다. 성공 시 grant는 AuthUser cascade로 삭제됩니다. 외부 철회와
DB commit 사이의 비원자성 및 재시도는 [Naver 인증](NAVER_AUTH_API.md)을 따릅니다.
commit 후에만 `RevokedAuthenticationUser`를 통지합니다.
HTTP 토큰 거부는 알림 전달 여부가 아니라 삭제된 서버 세션 행에 의해 보장됩니다.

인증 핸들러가 이미 끝난 요청도 쓰기 시 인증 행 잠금을 다시 획득해야 합니다.
변경이 먼저 잠그면 변경 commit 후 삭제가 그 결과까지 제거합니다. 삭제가 먼저 잠그면
대기 요청의 `SELECT FOR UPDATE`는 삭제 commit 후 행을 찾지 못하고 401을 반환하며,
`ProductAccount`조차 다시 만들지 못합니다. B의 인증 행과 소유 데이터는 건드리지 않습니다.
별도 tombstone이나 범용 잠금 프레임워크를 두지 않습니다. 새 소유자 쓰기 경로도 반드시
이 잠금 경계를 이용해야 하며, 관리자 직접 SQL은 이 API의 동시성 보장 범위가 아닙니다.

## 실제 스키마와 외부 삭제의 경계

`20261017054642164/definition.sql` 전체를 기준으로 확인했습니다. 저장 모델 변경은
없으므로 새 migration은 없습니다. `login_attempt`는 owner/identity FK 없는 로그인 전
nonce 기록이라 사용자별 삭제 대상이 아니며 기존 만료 정리 정책을 따릅니다.
SDK의 전역 rate-limit/challenge/가입 전 요청, 서버 운영 로그·통계·migration·future call·
cloud storage 테이블 역시 사용자 데이터 FK가 없습니다. 운영 로그/백업의 보존·파기 정책과
외부 저장소 파일 삭제는 별도 운영 조건입니다. 현재 앱은 SDK 프로필 이미지 업로드나
cloud storage를 구성하지 않았습니다. DB 이미지 메타데이터 cascade를 외부 파일 삭제로
해석하면 안 됩니다.

현재 Kakao 구현은 nonce 검증 OIDC ID token을 받아 로컬 identity와 서버 세션을 발급합니다.
Kakao access/refresh token을 저장하지 않고 unlink/revoke API를 호출하지 않습니다.
따라서 이 API는 **발맞춤 로컬 계정 삭제**이며 Kakao 연결 해제를 완료했다고 표시하면
안 됩니다. Kakao의 유효한 새 로그인으로 다시 가입하면 새로운 AuthUser가 생성됩니다.
동시 로그인에서 이전 identity를 읽은 요청은 FK/인증 사용자 조회에 의해 실패하거나 삭제 전
발급된 세션이 cascade됩니다. 외부 연결 해제가 필요하면 Kakao unlink 권한·호출 방식,
유효한 사용자 access token 또는 서버 관리자 자격증명, 실패 재처리 및 사용자 표시를
별도 결정·구현·실검증해야 합니다. 이번 변경은 그 자격증명을 요청하거나 외부 revoke를
시도하지 않습니다.

## 직접 검증과 장애 확인

고정 Dart 3.13.4/Serverpod 4.0.3 환경에서 서버 패키지의
`SERVERPOD_PASSWORD_database=local-disposable-test-only dart test test/integration/account_endpoint_test.dart`
를 실행합니다. 실제 생성 client와 서버 토큰으로 A 삭제 후 401, 모든 A 행 0,
B 보존, 익명 거부, 이미 인증된 변경과 삭제 양쪽 순서, 마지막 인증 삭제 실패의 전체
롤백을 확인합니다. 기존 인증 override 테스트는 이제 실제 AuthUser 행도 생성합니다.

실패 시 인증 환경/토큰 → 공통 AuthUser 잠금 경계 → 실패한 SQL/FK와 트랜잭션 롤백 →
commit 후 알림 순서로 확인합니다. 네트워크 응답 유실 후 401만으로 클라이언트가 외부
Kakao unlink까지 완료됐다고 추정하면 안 됩니다. 사용자 직접 확인과 외부 Kakao 검증은
자동 QA 통과와 별개입니다.

소스 근거: Serverpod auth core 4.0.3 `AuthUsers.delete`,
`ServerSideSessions.authenticationHandler`와 `createSession`,
현재 `kakao_provider.dart`, `auth_setup.dart`, 최신 `definition.sql`.

## 2026-10-17 실행 근거

- 앱 FVM의 Dart 3.13.4, Serverpod/CLI 4.0.3, 양쪽 `pub get --enforce-lockfile` 성공.
- 서버 전체 테스트: `+149: All tests passed!`, exit 0. profile/product/dev/Kakao/GPS 포함.
- 추가 NOWAIT 잠금 증거와 이미지 메타데이터 보존 검사를 반영한 계정 테스트:
  `+4: All tests passed!`, exit 0. 고정 sleep 없이 Completer와 DB 잠금 오류 `55P03` 사용.
- 양쪽 `analyze --fatal-infos`: `No issues found!`; 최종 서버 분석도 동일.
- 양쪽 format: 87 files, 0 changed. `dart build cli` 네이티브 bundle 생성 성공.
- 첫 실행의 긴 TMPDIR 소켓 제한과 테스트 fixture SQL의 UUID/text 타입 충돌은
  짧은 작업 전용 RUN_TMP 및 명시적 SQL cast로 수정 후 위 검증을 통과했습니다.
- 실제 외부 Kakao unlink, 운영 배포, 사용자 직접 검증은 수행하지 않았습니다.
