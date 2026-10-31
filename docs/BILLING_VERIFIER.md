# 스토어 직접 조회 검증기 (2026-10-19)

후속 영속화/API 계약은 [BILLING_API.md](BILLING_API.md)에 있다. 아래는 최초 검증기
증분의 범위 기록이며, 현재 facts는 `requiresAcknowledgement`(bool)도 제공한다.
Google acknowledgementState 누락/미지원은 거부한다. GoogleBillingClient.acknowledge는
검증 저장 이후에만 호출하며, Apple facts의 해당 값은 false다.

이 증분은 서버 전용 설정·HTTP 검증·불변 관측값까지만 구현한다. endpoint,
생성 client, DB 모델/저장, 탈퇴 보존, 선물 정책, 알림 수신기, 구매 승인·소비,
혜택 지급은 구현하지 않는다. 기존 앱 client pin 89200d0을 바꿀 필요가 없다.

## 정확한 인터페이스

단일 import:

```dart
import 'package:balmatchum_server/src/billing/billing_verifier.dart';

final config = BillingConfig.fromPasswords(passwordLookup);
final apple = AppleBillingClient(config.apple!);
final google = GoogleBillingClient(config.google!);

final appleFacts = await apple.verify(
  transactionId: transactionId,
  productId: configuredProductId,
  expectedAppAccountToken: serverOwnedAccountUuid,
);
final googleFacts = await google.verify(
  purchaseToken: purchaseToken,
  productId: configuredProductId,
  expectedObfuscatedAccountId: serverOwnedObfuscatedAccountId,
);
```

위 예시는 연결 위치를 설명하며 진입점에 자동 등록하지 않았다. provider 설정이
null이면 호출하지 않고 상위 계층에서 configurationMissing에 대응해야 한다.
두 생성자는 테스트용 선택 매개변수 `Clock clock`과
`http.Client Function()? clientFactory`를 받는다. factory는 서버 신뢰 경계의
테스트 seam이며 요청에서 주입하면 안 된다. 기본 구현은 직접 HTTPS,
시스템 인증서 검증, 프록시 우회이며 대체 호스트 옵션이 없다.

반환형은 `Future<BillingFacts>`이다. BillingFacts는 외부에서 생성할 수 없고
다음 읽기 전용 필드를 제공한다.

| 필드 | 타입/의미 |
| --- | --- |
| store | BillingStore.apple / google |
| environment | BillingEnvironment.production / sandbox |
| productId | 검증한 상품 ID |
| kind | BillingProductKind.subscription / lifetime |
| ownerBinding | 검증한 소유자 바인딩; Apple UUID는 소문자 정규화 |
| purchaseReference | Apple originalTransactionId 또는 Google purchase token; 로그 금지 |
| transactionId | String?; Apple 최신 transactionId / Google 최신 성공 order ID |
| state | BillingState.active, grace, expired, pending, onHold, paused, billingRetry, revoked |
| observedAt | DateTime UTC; 외부 조회를 끝낸 시각 |
| purchasedAt | DateTime? UTC; pending 응답에는 없을 수 있음 |
| expiresAt | DateTime? UTC; 스토어가 보낸 구독 만료 |
| graceExpiresAt | DateTime? UTC; Apple 유예 만료, Google grace 상태의 lineItem expiryTime |
| revokedAt | DateTime? UTC; Apple이 보낸 revocationDate, Google은 null |

`bool isActiveAt(DateTime instant)`는 관측 시각 이전과 시작 시각 이전을 거부하고,
종료 시각은 exclusive로 판정한다. active 평생 상품도 **관측 이후 환불을 알 수
있는 캐시가 아니다**. 혜택 소비 전 재조회해야 한다. observedAt은 DB에서 사용할
전역 관측 버전이나 직렬화 보장이 아니다.

실패는 `BillingVerificationException`의 `code`로만 구분한다:
`BillingFailure.configuration`(부분/잘못된 설정), `invalidPurchase`(응답 파싱,
바인딩, 미지원 상품/상태, 404/410), `unavailable`(시간 초과, 네트워크,
나머지 HTTP 오류). 응답 원문·URL·토큰·키는 예외 문자열에 포함하지 않는다.
전송 401/403도 unavailable이므로 운영자는 자격증명/권한을 확인해야 한다.

## 설정

`BillingConfig.fromPasswords(String? Function(String))`는 값을 전달받을 뿐
환경변수나 .env를 직접 읽지 않는다. 나중에 Serverpod PasswordManager에 연결할 때
아래 키를 `SERVERPOD_PASSWORD_` 접두어로 주입할 수 있다.

| Apple 그룹 | Google 그룹 |
| --- | --- |
| billingAppleBundleId | billingGooglePackageName |
| billingAppleIssuerId | billingGoogleClientEmail |
| billingAppleKeyId | billingGoogleKeyId |
| billingApplePrivateKey | billingGooglePrivateKey |
| billingAppleEnvironment | billingGoogleEnvironment |
| billingAppleProducts | billingGoogleProducts |

각 그룹이 전부 없으면 해당 provider는 null이다. 하나라도 있으면 그룹 전체가
필수이며 빈 값, 잘못된 PEM, 환경, 상품 목록은 실패한다. Apple은 App Store Connect
In-App Purchase 키의 P-256 EC PEM, Google은 2048비트 이상 RSA 서비스 계정 PEM과
서비스 계정 이메일을 사용한다. 소셜 로그인용 키/클라이언트 비밀값을 재사용하지 않는다.
환경은 소문자 `production` 또는 `sandbox`만 허용한다. Google의 sandbox는
별도 호스트가 아니라 응답 testPurchase/testPurchaseContext의 존재를 뜻한다.
상품은 JSON object `{"실제_상품_ID":"subscription","다른_실제_ID":"lifetime"}`
형식이며 빈 목록/알 수 없는 kind를 거부한다. 이 예시는 실제 상품 등록이 아니다.
가격을 설정하거나 추측하지 않는다.

## 신뢰와 상태 판정

- Apple: ES256 JWT의 iss/iat/exp(5분)/aud=appstoreconnect-v1/bid와 kid로 인증한다.
  production은 api.storekit.apple.com, sandbox는 api.storekit-sandbox.apple.com이다.
  /inApps/v1/transactions/{id}를 조회하고 구독이면
  /inApps/v1/subscriptions/{originalTransactionId}에서 같은 original 체인의 최신
  거래를 선택한다. 앱·상품·환경·구매 유형·PURCHASED 소유 형태·appAccountToken을
  초기/최신 거래 모두 검사하고 갱신 데이터의 체인·상품·환경도 검사한다.
- Apple JWS 디코더는 private이며 직접 인증한 API 응답에서만 호출한다.
  x5c 인증서 체인이나 JWS 서명을 별도로 검증하지 않는다. 이것은 사용자가 선택한
  TLS 직접 조회 신뢰 경계다. 클라이언트/알림 JWS에 이 경로를 재사용하면 취약점이다.
  transactionId 입력에는 숫자 조회 키만 허용한다. 자체 인증서 암호 구현은 없다.
- Apple status=3 billing retry는 비활성이다. status=4도 실제
  gracePeriodExpiresDate가 없거나 끝났으면 활성화하지 않는다. 취소한 갱신 설정과
  무관하게 유효 거래 만료까지만 활성이다. refund/revocation, isUpgraded는 우선한다.
- Google: RS256 JWT로 oauth2.googleapis.com/token에 서비스 계정 OAuth를 요청하고
  androidpublisher 범위 access token을 받아 고정 androidpublisher.googleapis.com을
  조회한다. packageName은 서버 설정으로 고정한 인증 요청 경로가 보증한다. API
  응답에는 원래 packageName 필드가 없으므로 응답에 있다고 가정하지 않는다.
- Google: /androidpublisher/v3/applications/{package}/purchases/subscriptionsv2/tokens/{token}
  또는 /purchases/productsv2/tokens/{token}을 사용한다. 조회 token은 URL의 한 segment로
  인코딩한다. 상품과 obfuscatedExternalAccountId를 응답과 비교하며 바인딩 누락은 거부한다.
  expected 바인딩은 **인증된 서버 계정에서 가져와야 하며 클라이언트 주장을 전달하면 안 된다**.
- Google ACTIVE/CANCELED는 실제 expiryTime까지, IN_GRACE_PERIOD는 같은 필드의
  현재 연장된 만료까지만 활성이다. pending/hold/paused/expired는 비활성이다.
  deferred replacement 상품을 조기 지급하지 않도록 성공 order ID도 필요하다.
  linkedPurchaseToken을 자동 추적·귀속하지 않는다.
- Google 평생 상품은 단일 수량의 미소비 비대여/비예약 상품만 지원한다.
  CANCELLED 또는 refundableQuantity=0은 revoked다. 누락된 refund 수량을 1로 추측하지
  않는다. 이 제한에 맞는 실제 콘솔 상품/응답 검증이 필요하다.
- 모든 HTTP 요청은 redirect 금지, 연결/전체 응답 각각 최대 10초, 압축 해제 후 응답 최대
  1 MiB다. 전체 응답 timeout은 스트림이 조금씩 오는 경우도 제한하며 IOClient를 닫는다.
  Apple 구독/Google 조회는 최대 2회 전송(각 10초), 자동 재시도/캐시/로그는 없다.

외부 조회는 DB 잠금 밖에서 수행하되, 이후 계정 존재·소유권·최신 관측 순서 확인과
권한 저장은 소유자 잠금 안에서 처리해야 한다. 이 증분에는 DB 코드가 없으며 검증
결과만으로 계정 삭제 경쟁이나 토큰 재사용 방지가 완성된 것은 아니다.

## 공식 근거와 선택 이유

2026-10-19 직접 확인했다. Context7 검색 요약의 Google products v2 경로와 복수
productLineItems 표기는 실제 원문과 달랐다. 아래 원문의 productsv2 경로,
productLineItem, testPurchaseContext.fopType, refundableQuantity를 기준으로 구현했다.

- [Apple API 인증/고정 호스트 공식 SDK](https://github.com/apple/app-store-server-library-node/blob/main/_autodocs/endpoints.md)
- [Apple 구독 status 정의](https://developer.apple.com/documentation/appstoreserverapi/status)
  (developer.apple.com/tutorials/data/documentation/appstoreserverapi/status.json 원문 확인)
- [Apple 거래 payload](https://github.com/apple/app-store-server-library-node/blob/main/models/JWSTransactionDecodedPayload.ts)
- [Apple 갱신 payload](https://github.com/apple/app-store-server-library-node/blob/main/models/JWSRenewalInfoDecodedPayload.ts)
- [Google 서비스 계정 OAuth](https://developers.google.com/identity/protocols/oauth2/service-account)
- [Google 구독 v2 상태/필드](https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.subscriptionsv2)
- [Google 상품 v2 조회 경로](https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.productsv2/getproductpurchasev2)
- [Google 상품 v2 환불·소유자 필드](https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.productsv2)

기존 dart_jsonwebtoken 3.4.1과 http 1.6.0을 사용하여 의존성·lockfile 변경 없이
서버 자격증명을 서명한다. 별도 검증 서비스를 만들거나 자체 인증서 검증기를
작성하는 대신, 고정 호스트 직접 조회를 선택했다. 외부 응답의 미래 필드/알 수 없는
상태는 권한을 추측하지 않으며 일부 새 구매 형식은 의도적으로 거부한다.
Google 출력 timestamp는 공식 문서의 Z-normalized 출력만 받는다.

## 직접 확인과 운영 한계

Dart 3.13.4를 선택한 서버 패키지에서 `dart test test/unit/billing --reporter expanded`로
실제 JSON/JWS 파서와 HTTP 요청 계약, JWT 공개키 서명 검증, 바인딩 오류, 환불,
비활성 상태, 만료 경계를 확인한다. 테스트 clock과 공개 일회성 키를 쓰며 실구매는 없다.

실행 근거 (모두 종료 코드 0): 양 패키지 pub get --enforce-lockfile,
131개 Dart 파일 포맷 무변경, 양 패키지 analyze --fatal-infos 무진단,
전체 서버 테스트 248개 통과, 마지막 추가 경계 테스트를 포함한 billing 테스트 35개
통과, native CLI build 성공, Serverpod 4.0.3 재생성 후 추적/미추적 생성물 drift 없음.
전체 248개 실행 뒤 변경은 초기화 formal 정리와 billing 테스트 3개 추가이며, 해당
최종 코드에 정적 분석과 billing 35개를 재실행했다. timeout 테스트는 10초를 실제로
기다리지 않고 Zone의 timer를 명시적으로 발화시켜 종료·client close를 확인한다.

장애 확인 순서는 전체 provider 설정 → 키 종류/스토어 API 권한 → 환경과 상품 목록 →
서버에서 얻은 owner binding → 실패 code다. 원본 purchase token/JWS/OAuth/PEM을 로그로
남기지 않는다. Google token은 request URL에도 있으므로 향후 HTTP tracing을 붙일 때
해당 경로를 반드시 가려야 한다.

사용자 직접 검증, 실제 키/상품 등록, sandbox 구매·복원·환불, 콘솔 권한·알림,
production TLS 호출과 배포는 미검증이다. 테스트 통과는 해당 운영 준비를 대신하지 않는다.
