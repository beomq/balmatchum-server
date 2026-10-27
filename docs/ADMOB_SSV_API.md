# AdMob SSV 인텐트 기반

## 범위와 공개 계약

광고 시청 증거는 운영 걸음 보상의 `product.claimDayWithAd`와 연결됩니다.
승인된 기본분의 총 2배를 지급하며 소비·원장·구간 전진은 같은 transaction입니다.
extra quiz 생성, 결제 entitlement, 클라이언트 `onUserEarnedReward` 완료 API는 없습니다.

생성 클라이언트 `client.ads`의 인증 필수 API:

```dart
Future<AdIntent> createIntent(
  String purpose,
  String targetDate,
  int targetRevision,
  AdPlatform platform, // ios | android
);
Future<AdIntent> getIntent(String intentId);
```

목적은 설정된 `dailyReward` 또는 `extraQuiz`, 날짜는 KST `YYYY-MM-DD`, revision은
0 이상의 정수, platform은 앱이 실행 중인 OS(`AdPlatform.ios`/`AdPlatform.android`)입니다.
서버가 인증 소유자를 고정합니다. 같은 소유자·목적·날짜·revision은
동시 요청에서도 동일 인텐트를 반환합니다. 신규 dailyReward는 실제 날짜/revision/미수령량을
검사하며 미래일·삭제일·legacy 정책·미확정/수령완료 자료를 거절합니다.
기존 대상의 재시도는 기존 인텐트를 반환하지만 수령 시 실제 자격을 다시 검사합니다.
extraQuiz 신규 생성은 purposeUnavailable이며 기존 증거 조회만 유지합니다.

`AdIntent`는 `id`, `purpose`, `targetDate`, `targetRevision`, `adUnit`, `userId`,
`customData`, `status`, `createdAt`, `eventExpiresAt`, `acceptUntil`, `verifiedAt?`,
`consumedAt?`를 반환합니다. id/customData는 동일한 256비트 난수 base64url nonce입니다.
`adUnit`은 요청 platform·목적의 전체 ad unit ID입니다. 같은 대상을 다른 platform에서
다시 생성하면 아직 Google 이벤트를 받지 않은 인텐트는 같은 id로 그 platform 단위에 다시 결합되고,
이미 verified/consumed인 인텐트는 그대로 반환됩니다. 앱은 반환된 `adUnit`으로 광고를 요청하고 SSV options의 userId/customData를 그대로 설정합니다.
nonce는 서버 DB에서 소유자와 모든 대상 필드에 결합되고 Google 서명이 custom_data를 포함합니다.
사용자가 nonce를 알아도 Google 서명 없이 verified로 바꿀 수 없습니다.

## 설정과 실제 HTTP 경로

`lib/server.dart`는 `pod.start()` 후 `configureAdMob(pod)`를 호출합니다.
설정이 없으면 콜백 경로를 처리하지 않고 API는 `configurationMissing`입니다. 잘못된 설정은
기동 오류이며 이미 열린 pod도 닫습니다. `.env` 자동 로딩은 없습니다. 별도 포트 설정은 없습니다.

- `SERVERPOD_PASSWORD_admobPlacements`: 목적별 플랫폼 단위 JSON 객체입니다. 두 목적 중 사용할
  것만 등록하며 임의 기본값은 없습니다. 형식(값은 자리표시자):

```json
{
  "dailyReward": {
    "adUnits": {
      "ios": "ca-app-pub-<게시자 16자리>/<iOS dailyReward 단위 10자리>",
      "android": "ca-app-pub-<게시자 16자리>/<Android dailyReward 단위 10자리>"
    },
    "rewardItem": "daily_reward",
    "rewardAmount": "1"
  },
  "extraQuiz": {
    "adUnits": {
      "ios": "ca-app-pub-<게시자 16자리>/<iOS extraQuiz 단위 10자리>",
      "android": "ca-app-pub-<게시자 16자리>/<Android extraQuiz 단위 10자리>"
    },
    "rewardItem": "extra_quiz",
    "rewardAmount": "1"
  }
}
```

- 목적 키는 `dailyReward`/`extraQuiz`만, 목적당 키는 `adUnits`/`rewardItem`/`rewardAmount`만,
  `adUnits`에는 `ios`와 `android` 둘 다 있어야 합니다. 예전 `adUnit` 단일 키는 기동 오류입니다.
- 단위 값은 앱이 그대로 로드하는 **전체 ID** `ca-app-pub-<16자리>/<10자리>`입니다. Google SSV
  콜백의 `ad_unit`은 `/` 뒤 숫자 ID이므로 서버는 전체 ID와 그 숫자 ID를 같은 단위로 인정합니다.
  그래서 숫자 ID는 모든 목적·플랫폼에서 서로 달라야 하며 중복은 기동 오류입니다.
- 같은 목적의 iOS/Android 단위는 콘솔에서 같은 reward item·amount로 설정합니다.

정확한 수신 경로는 공개 API 서버(로컬 8080)의 **`GET /admob/ssv?<Google query>`** 입니다.
`pod.server.addMiddleware`로 등록한 미들웨어가 이 경로만 가로채고 나머지는 Serverpod endpoint로
넘깁니다. Serverpod Cloud는 API 서버만 공개하므로 콘솔에 등록할 운영 URL은
`https://balmatchum-prod.api.serverpod.space/admob/ssv`입니다. 공개 배포/콘솔 변경은 수행하지
않았습니다. Google 콘솔의 URL 등록과 실제 기기 검증은 다음 운영 단계입니다.

`rewardAmount`는 콘솔 서명 메타데이터 일치 조건일 뿐 앱 포인트 수량이 아닙니다.
서버가 인텐트 생성 시 그 목적·platform의 unit/item/amount를 스냅샷하고 콜백에서 전부 비교합니다.
따라서 다른 platform·다른 목적·알 수 없는 unit의 서명 이벤트는 409이며 보상이 없습니다.
현재 설정의 같은 목적에서 제거된 unit도 거절합니다. 설정 변경 전 pending 인텐트를 고려해야 합니다.

## 원본 서명과 키

[공식 SSV 규격](https://developers.google.com/admob/android/ssv)의 마지막 파라미터
`signature`, `key_id` 순서를 강제합니다. 그 앞의 **인코딩된 원본 쿼리 UTF-8 바이트**에
PointyCastle 4.0.0 ECDSA SHA-256을 적용합니다. DER은 라이브러리 ASN.1로 파싱하고 canonical
DER과 비교합니다. 기존 dart_jsonwebtoken의 PEM parser를 사용하며 자체 암호 알고리즘은 없습니다.
서명 후 한 번만 decode하고 중복/알 수 없는 파라미터는 거절합니다.

Dart 3.13.4 `HttpRequest.uri`/Relic `Request.url`은 `%2f`→`%2F`, `%63`→`c`처럼 percent escape를
정규화하며 Serverpod API 서버는 원본 request-target을 노출하지 않습니다. 따라서 정규화된
`Request.url.query`를 검증합니다. Google의 정규 인코딩(대문자 hex, 비예약 문자 미인코딩)은
정규화로 바뀌지 않습니다. 비정규 인코딩으로 서명된 쿼리는 서명 검증에 실패해 보상 없이
400입니다(fail closed). 정규화로 같은 서명 문자열이 되는 요청은 같은 이벤트의 재전송으로만 처리됩니다.
테스트는 공개 API 포트에 raw socket으로 보내 정상 서명은 통과하고 값·서명을 바꾼 요청은 실패함을 확인합니다.

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

성공/동일 재전송은 200, (custom_data가 있는 요청의) 서명/구문 오류는 400, 메타데이터/기간/재사용/없는 인텐트는 409,
삭제된 소유자 잠금 실패는 410, 키/DB/예기치 못한 일시 실패는 503입니다.
405는 GET 이외이며, 다른 경로는 Serverpod endpoint 처리 결과를 따릅니다. 거절된 이벤트는 인텐트를 소모하지 않습니다.

### 콘솔 "URL 확인"과 custom_data 없는 요청

[AdMob 고객센터](https://support.google.com/admob/answer/9603226)의 설정 순서는 콜백 URL을
입력하고 **URL 확인**을 통과해야 **확인된 URL 사용**으로 저장됩니다. 이때 user_id/custom_data는
선택 입력(테스트 전용)이며, [SSV 규격](https://developers.google.com/admob/android/ssv)은 custom_data를
설정하지 않으면 그 파라미터가 콜백에 없다고 설명합니다. 확인 요청의 정확한 쿼리와 서명 키는 공식 문서에
없으므로 형태와 무관하게 받습니다.

- custom_data가 **없거나 빈 값**인 요청은 서명·파라미터와 관계없이 200입니다. 서명이 유효하든 틀리든(모르는
  key_id 포함), 서명이 없든, 파라미터 없는 GET이든 같습니다. 이런 요청은 보상과 연결될 수 없으므로 서명 검사가
  보안을 더하지 않고, 확인 요청 형태가 문서에 없어 규칙을 엄격하게 하면 콘솔 확인이 다시 실패할 수 있습니다.
  광고 인텐트·원장 행은 읽거나 쓰지 않으며, 종류만 info 세션 로그 한 줄로 남깁니다(값 미기록):
  `AdMob SSV reward-less request acknowledged: signatureValid | signatureInvalid | unsigned | emptyQuery`.
  서명 꼬리가 있으면 종류를 정하려고 서명을 검사하므로 gstatic 키를 가져올 수 있습니다. 키 장애도 signatureInvalid로 200입니다.
- custom_data가 비어 있지 않은 요청은 이전과 같습니다. 서명이 필수이고 400/409/410/503/200 규칙도 그대로입니다.
  따라서 확인 요청에는 custom_data를 입력하지 않습니다. 입력하면 형식 오류 400 또는 없는 인텐트 409입니다.

앱이 custom_data를 빠뜨린 실제 광고 콜백도 같은 이유로 200이지만 보상은 없습니다(이전에는 400 후 Google
재시도였고 결과는 같습니다). 위 info 로그가 운영에서 반복되면 앱의 SSV options 설정을 확인합니다.

계정 삭제는 같은 AuthUser→ProductAccount 잠금으로 인텐트 전체를 지웁니다. 삭제 전 인증된
요청/늦은 콜백도 삭제 뒤 데이터를 재생성하지 못합니다. transaction_id 기록도 함께 삭제되지만
서명된 nonce와 user_id가 사라진 소유자에 묶여 다른 소유자로 재사용할 수 없습니다.

## 실제 서버 통합 지점

```dart
Future<void> AdService.consume(Session session, Transaction tx, {
  required String owner,
  required String intentId,
  required String purpose,
  required String targetDate,
  required int targetRevision,
});
```

ProductService.claim은 인증된 owner 잠금 아래 실제 ProductDay revision과 정책 자격을 확인하고
이 헬퍼와 보상 원장·구간별 지급상한·request 결과를 **같은 tx** 안에서 갱신합니다. 실패하면 소비도 rollback됩니다.
이미 consumed면 `intentNotVerified`; 외부 RPC 소비 메서드는 없습니다. 재시도 응답은 업무 통합의
기존 request idempotency 기록으로 처리합니다. 포인트 수량을 클라이언트나 callback에서 읽지 않습니다.

장애 확인 순서: 설정 → 콘솔 콜백 URL(`/admob/ssv`, URL 확인이 200이 아니면 custom_data 입력 여부·배포 버전) → gstatic fetch/TTL → signed metadata →
시간 경계 → 인텐트/transaction 충돌 → 현재 업무 revision. 직접 검증은 `dart test
test/unit/ad_verifier_test.dart test/integration/ad_ssv_test.dart --reporter expanded`입니다.
자동 테스트와 사용자 직접 이해·기기 검증은 별개입니다.
