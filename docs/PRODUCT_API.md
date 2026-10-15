# 제품 데이터 API와 개발 fixture

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
