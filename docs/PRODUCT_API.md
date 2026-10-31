# 제품 데이터 API와 운영 걸음 보상

## 2026-10-19 운영 계약 (아래 개발 fixture 이력보다 우선)

유료 혜택 후속 증분: `claimDayWithPremium(date, requestId, expectedRevision)`은
활성 결제를 새로 검증하고 기존 광고와 같은 미수령 구간에 총 2배를 지급한다.
기존 무료 claimDay 의미는 유지한다. [정확한 앱 계약](PAID_BENEFITS_API.md)을 참조한다.

정책 버전은 `steps-v1-20261019`이다. 기본분은
`min(100, confirmedSteps ~/ 100)`이며 목표 설정은 계산에 사용하지 않는다.
무료 수령은 미수령 기본분만, 검증 광고 수령은 해당 기본분의 **총 2배**다.
100걸음=1P, 9,999걸음=99P, 10,000걸음 이상=100P이며 광고를 포함한 하루 최대는 200P다.

`client.product.claimDayWithAd(date, requestId, expectedRevision, intentId)`를 추가했다.
무료는 기존 `claimDay`다. 두 API는 같은 구간을 중복 지급하지 않는다.
성공 수령도 날짜 revision을 증가시킨다. 새로운 동작은 getDay의 최신 revision을 사용하고,
응답 유실 시에는 원래 requestId/revision/intentId를 그대로 재전송한다.
동일 요청은 원래 원장 결과를 반환한다. 삭제 후에도 기지급 사실 재조회는 허용한다.
다른 payload는 idempotencyConflict이며 광고 실패는 단위나 원장을 전진시키지 않는다.

### 승인된 유예와 최초 확정 구간

각 신규 기본 단위 구간의 최초 서버 확정 시각과 마감을 저장한다.
무료 마감은 `max(기록일 다음 KST 자정 + 7일, 최초 확정 + 72시간)`이다.
판정은 `now < freeUntil`이며 정확히 같은 시각에는 무료 수령이 끝난다.
예: 10월 19일 기록의 일반 마감은 10월 27일 00:00 KST다.
동일 snapshot 재전송, 같은 양의 새 revision, 하향 정정 후 복구는 마감을 바꾸지 않는다.
최대 최초 확정 단위를 넘는 신규 구간만 별도 마감을 얻는다. 유예 만료는 소멸이 아니며
해당 미수령분은 검증 광고로 수령할 수 있다. 광고는 한 날짜에만 결합된다.

각 구간의 grantedThroughUnits를 별도로 보존한다. 이전 70단위가 만료되고 신규 20단위가
유예 중이라면 무료는 20P만 지급하며 이전 70단위는 광고 대상에 남는다. 이후 광고는
이전 70단위에 140P만 지급한다. 지급된 구간은 정정으로 감소하거나 복구되지 않는다.
날짜 삭제는 미수령 구간을 제거하며 기지급 원장을 환불/차감하지 않는다.
소유자 잠금 뒤 거래 시각을 고정하여 마감 통과 중 금액과 구간 계산이 갈라지지 않게 한다.

### 생성 DTO와 화면 상태

- DailyRecord: policyVersion?, gracePolicyStatus, basePoints?, dailyBaseCap=100,
  stepsPerPoint=100, claimablePoints?(무료), adClaimablePoints?(광고 총액), grantedPoints.
  운영 응답 fixtureLabel은 null이다. 자료 미확정/legacy는 계산 금액이 null이다.
- rewardStatus: pending(미확정), eligible(무료 가능), adRequired(무료 0·광고 가능),
  settled(현재 추가분 없음), canceled(삭제), futureDate, legacyPolicyExcluded.
  eligible에도 만료된 별도 구간이 있으면 광고 총액은 무료 총액의 2배보다 클 수 있다.
- RewardGrant: policyVersion?, basePoints?, multiplier?, slices?를 추가했다.
  운영 응답은 모두 채우며 slices의 (fromUnits, throughUnits]가 실제 지급 구간이다.
  기존 fromUnits/throughUnits는 바깥 범위이며 구간 사이 공백을 지급한 것으로 해석하면 안 된다.
- WalletView: balance는 운영 원장만 합산하고 policyVersion을 표시한다. fixtureLabel=null.
- 오류: futureDate, legacyPolicyExcluded, staleProjection, stepsUnavailable,
  nothingToClaim, adRequired, dayDeleted 및 기존 requestId 오류.

### 광고 거래와 한계

광고 생성은 실제 소유자의 날짜·revision·미수령 단위를 검사한다. 없는 날/임의 revision,
미래일, 삭제일, fixture 날, 미확정 자료, 수령 완료는 새 인텐트를 만들지 못한다.
같은 owner/purpose/date/revision의 기존 인텐트 조회 재시도는 그대로 반환한다.
이는 지급 자격 갱신이 아니며 실제 수령 때 상태와 revision을 다시 검사한다.
AdService.consume, 원장 삽입, 구간 전진, request 결과 저장은 하나의 DB transaction이다.
무료 수령 후 이전 광고 수령은 staleProjection이며 이전 증거로 추가 지급하지 않는다.
후속 퀴즈 엔진은 extraQuiz 인텐트를 지원하며 QUIZ_ENGINE_API.md를 따른다.
유료 entitlement 연동은 PAID_BENEFITS_API.md를 따른다. 결제 권한을 가짜로 생성하지
않는다. SSV 운용 설정은 ADMOB_SSV_API.md 참조.

### 명시적 fixture 전환 전략

마이그레이션 20261019053232006은 point_entry.slices nullable JSON만 추가한다.
기존 원장 amount/policyVersion, 날짜 단위, 기존 request 결과를 수정하지 않는다.
기존 fixture 또는 policyVersion=null인 날짜는 legacyPolicyExcluded로 격리한다.
새로 생성되는 날짜만 운영 정책을 고정한다. 기존 날에 새 snapshot을 보내도 운영 금액으로
재평가하지 않는다. 기존 fixture claim의 동일 requestId 재생은 과거 fixtureLabel이 붙은
결과만 반환하며 운영 잔액에 들어가지 않는다. 이 데이터의 재평가·삭제·전환은 별도 승인 대상이다.
fixture quiz/theme는 기존 개발 DB에서만 유지하고 별도의 fixture 원장 잔액만 사용한다.
운영 포인트로 fixture 상품을 살 수 없고 fixture 포인트로 운영 잔액을 늘릴 수 없다.
배포 전에 기존 날짜의 policyVersion별 건수와 원장 합계를 확인하고 신규/legacy 계정을
각각 검증한다. 자동 backfill이나 fixture 포인트의 10배 변환은 수행하지 않는다.

장애 확인: 인증 소유자 → getDay revision/정책 → 구간별 마감/지급상한 → 인텐트 상태 →
원장 slices/requestId 순서다. 직접 검증은 99→100→199→10,000걸음, 무료/광고 경합,
정확한 KST 마감, 신규 무료 구간 뒤 과거 광고 수령, 날짜 삭제 후 동일 요청 재생이다.
센서 자료 진위, 실제 Google 광고·콘솔/TLS 프록시, 결제, 앱 UI와 사용자 직접 확인은 별도다.

### 검증 환경과 재현

Dart 3.13.4 / Serverpod CLI 4.0.3을 사용한다. 명령별로
`RUN_TMP=/tmp/stepreward`를 만들고 `TMPDIR="$RUN_TMP"`와 공개 disposable DB 비밀번호
`SERVERPOD_PASSWORD_database=local-disposable-test-only`를 전달한다.
두 패키지 enforce-lockfile, format, fatal-infos analyze를 검사한다. 서버 전체 테스트는
`dart test --concurrency=1 --reporter expanded`이며 서버 빌드는
`dart build cli --target bin/main.dart --output build`다.
보상/SSV 통합 테스트는 28개이며 임시 PostgreSQL, 실제 인증 HTTP 생성 클라이언트,
실제 서명·raw callback, 무료/광고 경합과 rollback을 사용한다. 전체 테스트는 201개다.
생성 코드 재생성 diff 및 create-migration의 No changes로 드리프트를 확인한다.
실제 운영 DB·광고 콘솔·앱 배포는 이 검증에 포함되지 않는다.

---

아래는 기존 API와 개발 fixture 구현 이력이다. 경제 수치·정책 미설정 설명은 위 운영 계약으로 대체한다.

구현 기준: Serverpod/CLI 4.0.3, 생성 client `client/lib/src/protocol/client.dart`.
모든 `product` 호출은 기존 인증 세션이 필요하다. 요청에 owner를 받지 않는다.
가상 사용자 발급과 앱 QA harness는 별도 담당 파일이며 이 구현에서 수정하지 않았다.

## 앱 계약

날짜는 `YYYY-MM-DD`, 하루 범위는 Asia/Seoul 자정의 UTC 반열림 구간이다.
예: 2026-10-14 = `[2026-10-13T15:00:00Z, 2026-10-14T15:00:00Z)`.

```dart
client.product.getDay(String date); // DailyRecord
client.product.listDays(String fromDate, String toDate); // List<DailyRecord>, 양끝 포함, 최대 93일
client.product.getWallet(); // WalletView: balance, streamGeneration, fixtureLabel?
client.product.registerStepStream(String requestId, int expectedGeneration); // int
client.product.submitSteps(DailyStepInput input); // DailyRecord
client.product.deleteDay(String date, String requestId); // DailyRecord
client.product.listDeletions(int afterVersion); // List<DailyRecord>, 최대 100개
client.product.claimDay(String date, String requestId, int expectedRevision); // RewardGrant
client.product.getQuiz(String date); // DailyQuiz
client.product.listQuizHistory(String beforeDate); // List<DailyQuiz>, exclusive date cursor, 최대 30개
client.product.answerQuiz(String date, int answerIndex, String requestId); // DailyQuiz
client.product.listThemes(); // ThemeStore
client.product.purchaseTheme(String themeId, String requestId); // ThemeStore
client.product.equipTheme(String themeId, String requestId); // ThemeStore
```

`DailyStepInput` 필수 필드: `date`, `streamGeneration`, `revision`, `windowStart`,
`windowEnd`, `observedAt`, `availability`. `total`만 nullable이다.
세 DateTime은 UTC여야 한다. availability는 `confirmed`, `unknown`,
`permissionUnavailable`, `pendingSync`, `queryFailed` 중 하나다.
confirmed에는 0 이상의 total, 나머지에는 null을 보낸다.

등록은 지갑의 현재 generation을 expectedGeneration으로 전달하는 CAS다. 등록 requestId와
반환 generation을 계정별로 영속 저장한다. 매 snapshot마다 등록하면 안 된다.
새 기기로 교체할 때만 새 requestId로 generation을 전진시킨다. 같은 requestId 재시도는
원래 generation을 반환한다. 다른 기기가 이미 교체했다면 staleGeneration으로 실패한다.
generation은 센서 신뢰성이나 부정행위 검증을 증명하지 않는다.

revision은 `(owner,generation,date)`별 양의 정수다. 입력값과 revision을 함께 durable queue에
저장하여 재시도 때 observedAt까지 동일하게 전송한다. 같은 revision의 다른 payload는
snapshotConflict, 오래된 revision은 최신값을 그대로 반환한다. 이전 generation은 거절한다.
총합은 교체형이며 phone+Watch 값을 합산하지 않는다. 관측 실패를 0으로 바꾸지 않는다.
최신 revision보다 큰 번호로만 정정한다.

`DailyRecord`는 steps?, availability, revision, streamGeneration, stepRevision,
deleted/deletionVersion, rewardStatus, claimablePoints?, grantedPoints, fixtureLabel?, routes를 반환한다.
달력은 없는 날짜도 unknown으로 반환하며 routes는 비운다. 상세의 routes는 원본별·날짜별 실제
points만 반환한다. 품질 임계값·거리·중복 GPS 투영은 구현하지 않았으며 서로 다른 record를
직선으로 연결하면 안 된다.

수령 requestId는 응답 유실 시 그대로 재사용한다. staleProjection이면 상세를 다시 읽고
사용자의 새 동작에 새 requestId를 쓴다. nothingToClaim, stepsUnavailable,
policyUnconfigured, dayDeleted는 성공 수령이 아니다. requestId를 다른 작업이나 payload에
재사용하면 idempotencyConflict다. 구매와 적용은 별도 API이며 구매만으로 적용되지 않는다.
구매·적용 재시도 응답은 원래 작업의 snapshot이므로 최신 상태는 listThemes로 읽는다.

## 삭제와 잠금 선택

모든 제품 조회/쓰기와 기존 GPS 조회/쓰기는 owner별 `ProductAccount` 행을
`INSERT ON CONFLICT` 후 `FOR UPDATE`로 잠근다. 아직 날짜 행이 없어도 직렬화할 수 있고,
날짜와 지갑 잠금 순환이 없다. 같은 계정의 병렬 처리를 희생하는 대신 최소 잠금 계약을 썼다.
다른 계정은 다른 행을 사용한다. 서버 메모리 mutex에 의존하지 않는다.

삭제는 날짜 tombstone을 영속 보존하고 steps·revision digest·보상 미수령 확인구간을 제거한다.
기지급 원장과 지갑 금액은 유지한다. 성공 claim 재시도는 지급 사실만 돌려주므로 삭제된
steps나 좌표를 재노출하지 않는다. listDeletions는 owner별 단조 증가 deletionVersion 순서다.
100개를 받으면 마지막 버전으로 다음 페이지를 조회한다.

GPS v1 입력/ACK 필드는 그대로다. 삭제일과 교차하는 신규 업로드는 **전체 dayDeleted**다.
기존 교차 원본도 payload 전체를 지워 생존일 부분도 더 이상 조회되지 않는다. 최소 receipt
ID와 deleted만 남고 getMine은 dayDeleted다. 부분 수락 ACK는 만들지 않는다. 삭제된 날에
새 활동도 복원할 수 없다. 날짜 경계의 실제 자정 표본은 새 날짜에 속하며 가상점은 만들지 않는다.

## 개발 fixture만 허용하는 경제

경제 fixture는 세 조건을 모두 만족할 때만 활성화된다.

- runMode = development
- PostgreSQL host = localhost / 127.0.0.1 / ::1
- DB name = balmatchum_dev_test

운영 정책 설정 경로는 아직 없다. 조건 밖에서는 보상량·상품 가격이 null이고 수령·구매·fixture
문항 배정은 policyUnconfigured로 거절한다. 응답과 모든 경제 원장에는
`development-fixture-v1-not-production` 표시를 넣는다.

검증 숫자: 1000걸음 완성 단위당 1점, 기본 fixture 퀴즈 정답 2점, sunny 기본 보유,
cloudy/rainy/snowy 각 3점. 네 themeId는 승인된 배경 asset에 연결하기 위한 식별자이며
새 착용 합성은 제공하지 않는다. 색상값은 fallback 식별 정보이지 신규 이미지 자산이 아니다.

fixture 유예는 보행일 포함 7일 뒤 서울 자정과 새 확정 시점+72시간 중 늦은 시각까지다.
이는 미정 운영 경계를 구현 승인한 것이 아니다. 같은 확정 단위는 재전송·하향 정정 후 복구로
기한을 갱신하지 않는다. 지급 상한은 하향 정정에도 내려가지 않는다. 추가 확정량만 별도
append-only 원장으로 지급한다. 만료된 구간을 건너뛴 경우 amount는 유효 확인구간만 합산한다.

퀴즈는 오늘 기본 1개만 배정하며 답변 전 정답을 노출하지 않는다. 최초 답변만 확정하며
같은 답변 재시도·과거 복습은 추가 지급하지 않는다. 테스트 문항 1개이며 출시용 검수 문항집이 아니다.
광고 검증·추가 퀴즈·2배 보상·IAP는 구현하지 않는다.

## 확인과 장애 진단

검증 명령은 저장소 AGENTS.md의 Dart 3.13.4 환경에서 실행한다.

```sh
cd server
dart analyze --fatal-infos
SERVERPOD_PASSWORD_database=local-disposable-test-only dart test --reporter expanded
dart build cli --target bin/main.dart --output build
cd ../client
dart analyze --fatal-infos
```

제품 테스트는 별도 임시 경로 내장 PostgreSQL을 development + balmatchum_dev_test로
기동한다. 실제 인증 세션/HTTP/생성 client 격리, 트랜잭션 동시 수령, 고정 clock 정정·유예,
Completer 장벽으로 claim/delete 양쪽 순서, GPS 삭제, 퀴즈 중복, 구매 경합을 검증한다.
sleep이나 타이밍 운에 의존하지 않는다.

앱 직접 확인: 통합 snapshot 7000 저장 → 7점 수령 → 8000 정정 → 1점 추가 → 6500 정정에도
잔액 8 유지 → 날짜 삭제 후 steps 없음·GPS 재업로드 dayDeleted를 확인한다.
문제 시 실제 인증 → 서버 DB 이름/모드 → generation/revision 영속 저장 → 최신 day revision →
원장 순서로 확인한다. fixture 오류를 운영 정책으로 우회하지 않는다.

공식 근거: [4.0.3 모델](https://github.com/serverpod/serverpod/blob/4.0.3/packages/serverpod/skills/serverpod-models/SKILL.md),
[트랜잭션/행 잠금](https://github.com/serverpod/serverpod/blob/4.0.3/packages/serverpod/skills/serverpod-database/SKILL.md),
[마이그레이션](https://github.com/serverpod/serverpod/blob/4.0.3/packages/serverpod/skills/serverpod-migrations/SKILL.md).
설치 SDK의 database.dart와 생성 repository의 lockMode/transaction 인자를 대조했다.
물리 센싱·실기기 HealthKit 정확성·배터리·운영 경제 정책·사용자 직접 확인은 별도 미검증이다.

## 이번 실행 증거

- Dart 3.13.4, CLI 4.0.3으로 두 패키지 `pub get --enforce-lockfile` 성공.
- 실제 CLI generate와 create-migration 성공. 마이그레이션 `20261014052848316`을
  임시 PostgreSQL에서 적용했다. 기존 gps_record에 deleted 기본값을 추가하고 payload만
  nullable로 바꾸므로 기존 원본을 일괄 수정하지 않는다.
- 제품 통합 테스트 14개 통과. 기존 GPS v1 테스트 10개 통과.
- 서버와 클라이언트 `analyze --fatal-infos` 모두 No issues found.
- `dart build cli --target bin/main.dart --output build` 종료 0.
- 생성 파일 53개의 재생성 전후 SHA-256이 같고 소유 검증 대상 73개 Dart 파일의
  format 변경 0개, git diff --check 통과.
- 첫 전체 테스트는 138개 통과·기존 카카오 invalid alg 테스트 1개 실패했다.
  실패는 token 검증 전 beginLogin의 HTTP 404였다. 동일 기존 테스트 단독 재실행은 통과했다.
  해당 인증 테스트·인증 코드는 수정하지 않았다.
- 전체 `dart test --concurrency=1 --reporter expanded` 최종 실행은 139개 모두 통과,
  종료 0이다. 제품 테스트 안의 별도 DB 세션 동시 수령·구매와 삭제 장벽 경합은
  그대로 실행된다. 파일 간 동시 실행의 첫 HTTP 404 원인은 확정하지 않았다.
- 전체 format 검사는 리드가 추가한 `server/bin/dev_product_harness.dart` 서식 차이 1개를
  보고했다. `--output=none` 검사이므로 해당 파일은 변경하지 않았다.
