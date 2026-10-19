# AdMob SSV 인텐트 기반

## 범위와 공개 계약

이 증분은 광고 시청 사실만 검증합니다. 2026-10-19 승인된 보상 수치는 다음
경제 정책 증분에서 연결합니다. 포인트 지급, extra quiz 생성, entitlement,
클라이언트 `onUserEarnedReward`에 따른 완료 API는 없습니다.

생성 클라이언트 `client.ads`의 인증 필수 API:

```dart
Future<AdIntent> createIntent(String purpose, String targetDate, int targetRevision);
Future<AdIntent> getIntent(String intentId);
```

목적은 설정된 `dailyReward` 또는 `extraQuiz`, 날짜는 KST `YYYY-MM-DD`, revision은
0 이상의 정수입니다. 서버가 인증 소유자를 고정합니다. 같은 소유자·목적·날짜·revision은
동시 요청에서도 동일 인텐트를 반환합니다. revision의 실제 업무 대상 유효성/삭제 여부와
혜택 자격은 이후 소비 통합에서 현재 서버 상태와 대조해야 합니다. 생성 자체는 자격이 아닙니다.

`AdIntent`는 `id`, `purpose`, `targetDate`, `targetRevision`, `adUnit`, `userId`,
`customData`, `status`, `createdAt`, `eventExpiresAt`, `acceptUntil`, `verifiedAt?`,
`consumedAt?`를 반환합니다. id/customData는 동일한 256비트 난수 base64url nonce입니다.
앱은 반환된 `adUnit`으로 광고를 요청하고 SSV options의 userId/customData를 그대로 설정합니다.
nonce는 서버 DB에서 소유자와 모든 대상 필드에 결합되고 Google 서명이 custom_data를 포함합니다.
사용자가 nonce를 알아도 Google 서명 없이 verified로 바꿀 수 없습니다.

## 설정과 실제 HTTP 경로

`lib/server.dart`는 `pod.start()` 후 `configureAdMob(pod)`를 호출합니다.
둘 다 없으면 listener를 열지 않고 API는 `configurationMissing`입니다. 부분/잘못된 설정은
기동 오류이며 이미 열린 pod도 닫습니다. `.env` 자동 로딩은 없습니다.

- `SERVERPOD_PASSWORD_admobSsvPort`: 전용 loopback HTTP 포트(0은 테스트 동적 포트).
- `SERVERPOD_PASSWORD_admobPlacements`: JSON 객체, 목적별
  `{"adUnit":"콘솔의 콜백 ad_unit 값","rewardItem":"콘솔 문자열","rewardAmount":"콘솔 숫자 문자열"}`.
  두 목적 중 사용할 것만 등록합니다. 임의 기본값은 없습니다.

정확한 수신 경로는 **`GET http://127.0.0.1:<admobSsvPort>/admob/ssv?<Google query>`** 입니다.
API 8080 포트의 endpoint가 아닙니다. 운영에서는 승인된 TLS reverse proxy가 해당 loopback
포트에 원본 request-target을 바이트 그대로 전달해야 합니다. 공개 배포/콘솔 변경은 수행하지
않았습니다. Google 콘솔의 URL 등록과 실제 기기 검증은 다음 운영 단계입니다.

`rewardAmount`는 콘솔 서명 메타데이터 일치 조건일 뿐 앱 포인트 수량이 아닙니다.
서버가 인텐트 생성 시 unit/item/amount를 스냅샷하고 콜백에서 전부 비교합니다.
현재 unit allowlist에서도 제거된 unit은 거절합니다. 설정 변경 전 pending 인텐트를 고려해야 합니다.

## 원본 서명과 키

[공식 SSV 규격](https://developers.google.com/admob/android/ssv)의 마지막 파라미터
`signature`, `key_id` 순서를 강제합니다. 그 앞의 **인코딩된 원본 쿼리 UTF-8 바이트**에
PointyCastle 4.0.0 ECDSA SHA-256을 적용합니다. DER은 라이브러리 ASN.1로 파싱하고 canonical
DER과 비교합니다. 기존 dart_jsonwebtoken의 PEM parser를 사용하며 자체 암호 알고리즘은 없습니다.
서명 후 한 번만 decode하고 중복/알 수 없는 파라미터는 거절합니다.

Dart 3.13.4 `HttpRequest.uri`/Relic `Request.url`은 `%2f`→`%2F`, `%63`→`c`로 바꿀 수 있습니다.
`RawQueryServer`는 소켓 첫 요청 줄만 제한된 크기로 복사하고, HTTP 처리는 SDK
`HttpServer.listenOn`에 맡깁니다. 한 연결당 한 요청, 요청 줄 16 KiB, 연결 10초 제한입니다.
테스트는 raw socket으로 비정규 인코딩을 보내 정상 서명은 통과하고 인코딩만 바꾼 요청은 실패함을 확인합니다.

키 출처는 고정된 `https://www.gstatic.com/admob/reward/verifier-keys.json`입니다.
redirect를 따르지 않으며 callback 제공 키/URL을 사용하지 않습니다. 캐시는 fetch 시작 시각부터
23시간(<24시간), 동시 fetch 병합, 모르는 key_id는 최대 분당 한 번 강제 갱신합니다.
만료 키는 장애 시에도 사용하지 않으며 키 장애는 503입니다. 콜백 원문과 nonce는 로그에 남기지 않습니다.

## 상태, 시각, 재시도와 종료 의미

- `pending`: Google SSV 대기. 클라이언트 완료 신호는 상태를 바꾸지 않습니다.
- `verified`: 실제 서명과 소유자/unit/메타데이터/시각 검증 완료. 아직 혜택 지급 아님.
- `consumed`: 서버 업무 트랜잭션이 한 번 소비. 되돌리는 API 없음.
- `expired`: pending이고 `now >= acceptUntil`일 때 응답에 계산되는 최종 상태.
  DB에는 pending을 유지하지만 이후 최초 콜백은 거부합니다. 같은 대상 재생성으로 연장하지 않습니다.
  복구/새 시청 정책은 차기 통합에서 별도 결정해야 합니다.

모든 instant는 UTC입니다. 생성 시각은 Google과 비교할 수 있게 millisecond로 내림합니다.
Google timestamp 단위는 **epoch milliseconds**입니다.
서명 event 시각은 `[createdAt, createdAt + 1시간)`이어야 하며 수신 시각보다 5분을 넘게
미래일 수 없습니다. 최초 전달은 `now < eventExpiresAt + 7일`까지 허용합니다.
따라서 광고 이벤트가 유효 시간에 일어났다면 지연 콜백을 받을 수 있고, 늦게 광고를 보는 것으로
기간을 연장할 수 없습니다. 1시간/7일/5분은 광고 인증 운용 경계이며 보상 수치가 아닙니다.

정확히 같은 signed payload와 transaction_id의 재전송은 검증 후 200입니다. 이미 accepted된
이벤트는 7일 이후나 consumed 이후에도 200이며 상태/시각을 다시 쓰지 않습니다. verified는 자동
만료하지 않지만 미래 소비 통합이 업무 대상 revision/자격을 다시 검증해야 합니다.
다른 이벤트로 같은 인텐트를 덮거나 같은 transaction_id를 다른 인텐트에 쓰면 409입니다.
소유자 잠금 + transaction_id PostgreSQL advisory lock + unique index로 동시 요청을 직렬화합니다.

성공/동일 재전송은 200, 서명/구문 오류는 400, 메타데이터/기간/재사용/없는 인텐트는 409,
삭제된 소유자 잠금 실패는 410, 키/DB/예기치 못한 일시 실패는 503입니다.
404는 경로 불일치, 405는 GET 이외입니다. 거절된 이벤트는 인텐트를 소모하지 않습니다.
공식 문서의 Google 재시도는 최대 5회, 1초 간격이므로 7일 수신 허용이 실제 재전송을 보장하지 않습니다.

계정 삭제는 같은 AuthUser→ProductAccount 잠금으로 인텐트 전체를 지웁니다. 삭제 전 인증된
요청/늦은 콜백도 삭제 뒤 데이터를 재생성하지 못합니다. transaction_id 기록도 함께 삭제되지만
서명된 nonce와 user_id가 사라진 소유자에 묶여 다른 소유자로 재사용할 수 없습니다.

## 다음 서버 통합 지점

```dart
Future<void> AdService.consume(Session session, Transaction tx, {
  required String owner,
  required String intentId,
  required String purpose,
  required String targetDate,
  required int targetRevision,
});
```

인증된 owner로 기존 소유자 잠금을 잡고, 실제 ProductDay/quiz revision과 정책 자격을 확인한 뒤
이 헬퍼와 실제 entitlement/보상 원장을 **같은 tx** 안에서 갱신합니다. 실패하면 소비도 rollback됩니다.
이미 consumed면 `intentNotVerified`; 외부 RPC 소비 메서드는 없습니다. 재시도 응답은 업무 통합의
기존 request idempotency 기록으로 처리합니다. 포인트 수량을 클라이언트나 callback에서 읽지 않습니다.

장애 확인 순서: 설정/포트 → proxy 원본 URI 보존 → gstatic fetch/TTL → signed metadata →
시간 경계 → 인텐트/transaction 충돌 → 현재 업무 revision. 직접 검증은 `dart test
test/unit/ad_verifier_test.dart test/integration/ad_ssv_test.dart --reporter expanded`입니다.
자동 테스트와 사용자 직접 이해·기기 검증은 별개입니다.
