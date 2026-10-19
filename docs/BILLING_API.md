# 결제 영속화와 앱 계약 (2026-10-19)

저장·재조회·복원·탈퇴 삭제에 이어 유료 걸음 보상과 추가 퀴즈가 연결되었다.
정확한 혜택 계약은 [PAID_BENEFITS_API.md](PAID_BENEFITS_API.md)를 따른다.
선물, 자산, 알림 수신기에는 연결하지 않았다. 앱 수정이나 pin 변경은 없다.
스토어 자격증명·상품 설정은 [검증기 문서](BILLING_VERIFIER.md)를 따른다.

## 생성 클라이언트의 정확한 계약

모든 메서드는 인증된 세션이 필요하다. owner와 expected binding은 입력받지 않는다.

```dart
Future<PurchaseConfiguration> client.billing.getPurchaseConfiguration(String store);
Future<EntitlementView> client.billing.verifyPurchase(PurchaseInput input);
Future<EntitlementView> client.billing.restorePurchase(PurchaseInput input);
Future<EntitlementView> client.billing.getEntitlement();
```

| DTO | 정확한 필드 |
| --- | --- |
| PurchaseInput | `String store`, `String productId`, `String purchaseReference` |
| PurchaseConfiguration | `String store`, `String environment`, `String accountBinding`, `List<PurchaseProduct> products` |
| PurchaseProduct | `String productId`, `String kind` |
| EntitlementView | `bool active`, `List<PurchaseView> purchases` |
| PurchaseView | `String store`, `String productId`, `String kind`, `String state`, `bool active`, `DateTime observedAt`, `DateTime? expiresAt`, `DateTime? graceExpiresAt`, `bool acknowledgementPending` |
| BillingException | `String code` |

`store`: `apple` / `google`. `environment`: `production` / `sandbox`.
`kind`: `subscription` / `lifetime`. `state`: `active`, `grace`, `expired`,
`pending`, `onHold`, `paused`, `billingRetry`, `revoked`.
state는 스토어 관측값이며 실제 기간 판정은 `active`를 사용한다. 종료는 exclusive다.

앱은 구매 전 configuration을 조회하고, `accountBinding`을 Apple `appAccountToken`,
Google `obfuscatedAccountId`로 그대로 전달한다. 계정당 서버 생성 UUID v4이며
auth owner UUID와 다르다. 계정이 유지되는 동안 두 스토어와 여러 기기에서 동일하다.
products는 서버 allowlist뿐이며 가격 정보가 아니다. 현지 가격은 스토어에서 조회한다.
`purchaseReference` 입력은 Apple transaction ID 또는 Google purchase token이다.
원문·서명·클라이언트 premium 주장은 증거가 아니다.

restore는 동일한 검증·저장 경로다. 기기의 구매 목록을 한 건씩 **순차** 호출한다.
동일 구매 반복은 행을 늘리거나 보상을 지급하지 않고 다시 조회한다. 별도 request ID는
없다. `getEntitlement`도 저장된 모든 구매를 스토어에서 새로 조회하며 승인 실패를
재시도한다. 외부 장애 시 오래된 저장값을 성공으로 반환하지 않는다. 빈 계정은
`active: false, purchases: []`다. 구매 UUID, token, hash, owner는 응답에 없다.

오류 code: `configurationMissing`, `invalidPurchase`, `temporarilyUnavailable`,
`purchaseUnavailable`, `staleObservation`, `accountDeleted`.
인증 없음/삭제된 세션은 HTTP 401이다. 이미 인증된 조회가 탈퇴 후 완료된 경우
`accountDeleted` 또는 기존 tombstone에 대한 `purchaseUnavailable`이 된다.
`staleObservation`은 다른 요청이 나중 순번을 예약했다는 뜻이다. 자동 무한 재시도 대신
진행 중 요청을 완료한 뒤 `getEntitlement`로 새로 확인한다. `purchaseUnavailable`은
다른 계정 소유 또는 탈퇴 보존 구매이며 소유자 정보를 노출하지 않는다.

## 저장과 경합 보장

`billing_account`: owner, 불투명 binding, 계정 단위 단조 증가 sequence.
외부 호출 전 AuthUser 잠금 안에서 순번을 예약하고 commit한다. 외부 HTTP 중에는
DB 잠금을 잡지 않는다. 완료 시 같은 계정의 현재 순번과 binding을 비교한다.
타임스탬프 정렬은 네트워크 완료 순서를 증명하지 못하므로 사용하지 않는다.
계정 단위이므로 서로 다른 구매를 동시에 검증해도 이전 요청은 거부될 수 있다.
실패한 나중 요청도 이전 요청의 완료를 유효하게 되돌리지 않는다.

`billing_purchase`: 검증된 상태·유효기간·원본 조회키·승인 재시도 표시를 저장한다.
스토어+환경+canonical reference의 해시에 unique index를 두며, 해시 advisory lock은
다른 계정 사이 충돌까지 직렬화한다. Apple canonical reference는 originalTransactionId,
Google은 purchase token이다. Google linkedPurchaseToken을 자동 귀속하지 않는다.
잠금 순서는 AuthUser → 구매 해시다. 기존 삭제 잠금과 동일한 AuthUser를 사용한다.

탈퇴 트랜잭션은 바인딩·구매 원문·개인 연결을 지우고
`billing_purchase_tombstone`에 `id`(DB surrogate)와 `identityHash`만 남긴다.
owner, binding, product, store, 시간, token은 보존하지 않는다. 외부 조회 중 탈퇴가
먼저 끝난 경우도 검증 완료 후 해시만 보존하고 거부한다. 재가입 시 새 binding이며
기존 구매의 바인딩 검증을 우회하지 않는다. 외부에서 바인딩이 바뀌어도 tombstone이
재귀속을 거부한다. DB 삭제 rollback이면 구매와 바인딩도 유지된다.

결제 DB 작업은 logging-disabled 내부 세션을 사용한다. DB 오류는 값 없는
`temporarilyUnavailable`로 변환해 실패 query의 토큰 유출도 막는다. HTTP 전송에는
원문·URL 로그가 없다. 운영 PostgreSQL SQL/parameter 로깅, 프록시 request body 로깅,
외부 APM의 구매 경로 수집은 별도로 비활성/마스킹해야 한다. 백업 삭제 정책은 별도다.

## HMAC 설정과 회전

추가 비밀값 `SERVERPOD_PASSWORD_billingIdentityHmacKey`: 최소 32바이트 난수를
base64 인코딩한 안정적인 서버 전용 키. 누락 시 API `configurationMissing`,
제공됐으나 잘못된 값은 시작 오류다. store 설정도 누락 시 해당 store API를 닫는다.
임시 secret이나 auth pepper를 재사용하지 않는다.

계산식은 HMAC-SHA256(key, UTF-8(JSON array))이며 array는 정확히
`["billing-purchase-v1", store, environment, canonicalPurchaseReference]`다.
키는 DB/백업 수명 전체에서 유지해야 한다. **임의 salt/키 회전 금지**: tombstone에는
원문이 없어 새 키로 재해시할 수 없다. 회전이 필요하면 이전 키들을 안전하게 보관하고
모든 세대 해시를 조회하는 별도 마이그레이션을 먼저 설계·검증해야 한다. 현재 구현은
단일 키 계약이다. 키 유실은 타 계정 재사용 방지를 복구할 수 없게 만든다.

## Google 승인과 복구

검증기 facts에 `bool requiresAcknowledgement`만 추가했다. Google 공식
`acknowledgementState`의 pending/acknowledged를 엄격히 파싱하며 누락/미지원은 거부한다.
Apple은 false다. 활성 구매만 저장 commit 후 acknowledge한다. lifetime은 consume하지 않는다.
공식 [상품 승인](https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.products/acknowledge),
[구독 승인](https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.subscriptions/acknowledge)의
고정 HTTPS POST와 빈 body 성공 응답을 사용한다. 승인에 계정 재바인딩 값은 보내지 않는다.

실패·프로세스 종료 시 `acknowledgementPending`을 유지한다. 다음 verify/restore/getEntitlement가
신선한 스토어 관측 후 재시도한다. 승인 성공 후 DB 반영이 실패했어도 다음 조회에서
스토어 acknowledged를 확인해 정리한다. 백그라운드 스케줄러는 이 증분에 없으므로
장기간 앱이 호출하지 않는 구매의 승인 마감 보장은 운영 후속 과제다. 삭제 후 늦은
승인 완료는 행을 재생성하지 않는다.

## 직접 검증과 한계

`server/test/integration/billing_endpoint_test.dart`는 격리 PostgreSQL, 실제 인증과 HTTP,
생성 client를 사용한다. 외부 스토어 전송만 고정 응답으로 바꾸고 진짜 검증기를 통과한다.
Completer 신호로 응답 순서와 탈퇴를 제어하며 sleep은 사용하지 않는다.

```sh
# Dart 3.13.4, 저장소 루트에서
export RUN_TMP="$(mktemp -d)"
export TMPDIR="$RUN_TMP/" XDG_CACHE_HOME="$RUN_TMP/cache"
mkdir -p "$XDG_CACHE_HOME"
# PUB_CACHE는 CLI 4.0.3을 설치한 자신의 캐시 경로로 명시한다.
export PUB_CACHE="${PUB_CACHE:-$HOME/.pub-cache}"
cd server
SERVERPOD_PASSWORD_database=local-disposable-test-only dart test test/integration/billing_endpoint_test.dart test/unit/billing --reporter expanded
```

장애 확인 순서: provider+HMAC 설정 → 인증과 binding → API 오류 code → 구매 상태와
승인 marker → 스토어 API 권한/환경. 원문 토큰을 로그로 출력하며 조사하지 않는다.
실제 콘솔 상품/키, sandbox 구매·복원·환불, production 통신, 사용자 직접 확인과
운영 배포는 별도 미검증이다. 저장 관측은 스토어의 그 순간 상태이며 응답 직후 환불까지
보장하지 않는다. 후속 혜택 소비는 신선한 재조회와 실제 보상 트랜잭션에 연결했으며
구체적인 잠금·재생 보장은 PAID_BENEFITS_API.md에 기록했다.

실행 근거: Dart 3.13.4 / Serverpod CLI 4.0.3, 양 패키지 locked pub get 성공,
149개 Dart 파일 format 무변경, 양 패키지 analyze --fatal-infos 무진단,
전체 테스트 268개 통과, native CLI build 성공(모두 종료 코드 0).
새 결제 HTTP 통합 테스트 16개와 승인 단위 테스트 1개가 포함된다.
최초 분석에서 새 코드의 중괄호 스타일 진단을 수정한 뒤 전체 검증을 통과했다.
테스트의 serviceSecret 미설정 경고는 기존 Insights 비활성 설정이며 실패가 아니다.
