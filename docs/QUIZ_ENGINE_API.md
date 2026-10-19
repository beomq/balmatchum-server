# 버전별 퀴즈 엔진

## 정책과 현재 공급 상태

KST 날짜별 무료 새 문제 1개와 검증 광고로 여는 추가 새 문제 1개입니다.
무료 문제를 제출해야 추가 광고 자격이 생깁니다. 최초 제출은 정오답과 관계없이
2P이며 복습·동일 답 재전송은 새 지급이 없습니다. 날짜가 지난 미제출 문제는
닫힙니다. 지급된 퀴즈 포인트는 운영 지갑에 포함되지만 걸음 보상 계산·상한은
변경하지 않습니다. 유료 entitlement는 항상 false이며 결제 자료나 우회 권한은
만들지 않습니다.

**검토 완료된 실문항은 아직 없습니다. 목표 120개를 충족했다고 표시하지 않습니다.**
미설정·빈 팩은 `contentUnavailable`, 공급된 모든 문제 ID를 이미 본 사용자는
`exhausted`입니다. 같은 ID의 새 버전도 기존 독자에게 새 보상 문제로 반복 발급하지
않습니다. 변경된 버전은 그 ID를 처음 받는 사용자에게만 발급됩니다.

## 실제 검토 팩 공급

상위 담당자가 실제 검토를 마친 JSON 파일을 배포 파일 시스템에 공급하고
서버 프로세스에 `BALMATCHUM_QUIZ_BANK_PATH`를 그 파일 경로로 지정합니다.
`.env` 자동 로딩은 없습니다. 자격증명 설정이 아닙니다. 서버 시작 시
`configureQuizBank`가 읽고 검증·DB 등록합니다. 운영 콘텐츠를 소스에 넣는 경우도
같은 JSON 형식과 담당자 검토 절차를 사용합니다. 이 커밋에는 운영 팩이 없습니다.

최상위 필드는 `schemaVersion: 1`, `kind: "reviewed"`, `questions: [...]`입니다.
각 문항은 다음 필드를 **실제 자료로** 채웁니다. 아래 표는 형식 정의이며 승인 예제
문항이나 자동 승인을 제공하지 않습니다.

| 필드 | 타입·조건 |
| --- | --- |
| questionId | String, `[a-z0-9][a-z0-9_-]{0,95}`, 안정적인 ID, 팩 안에서 중복 불가 |
| version | int >= 1, 내용·출처·조건·검토 정보가 바뀌면 증가 |
| question | 비어 있지 않은 String |
| choices | 중복·빈 문자열 없는 String 배열, 2~8개 |
| correctIndex | 0부터 시작하는 choices 인덱스 |
| explanation | 비어 있지 않은 String |
| source | 호스트가 있는 HTTPS URL |
| conditions | 적용 조건·예외를 담은 비어 있지 않은 String |
| reviewedAt | 실제 검토 날짜 `YYYY-MM-DD`, 유효한 날짜, 미래 불가 |
| reviewedBy | 책임 검토자 식별 String |
| reviewStatus | 정확히 `approved` |

로더는 메타데이터의 존재·형식을 검사하지 의학적 정확성이나 검토자의 자격을
증명하지 않습니다. 승인 권한은 담당자의 실제 검토 과정에 있습니다.
한 팩에는 ID별 활성 버전 하나를 넣습니다. 순서는 신규 문제 발급 순서입니다.
등록된 `(questionId, version)`의 내용은 같은 버전으로 변경할 수 없습니다.
DB `quiz_content_revision`은 재시작·팩 교체·계정 삭제 후에도 버전 식별을 보존합니다.
발급 행은 전체 내용·정답·해설·출처·검토자·검토일·조건의 JSON 스냅샷을 보존하므로
팩 제거나 개정 후에도 과거 답안을 새로운 정답으로 재채점하지 않습니다.

테스트 팩은 `kind: "testFixture"`, 문항 `reviewStatus: "testFixture"`이며
서버 `test` 실행 모드에서만 설치 가능합니다. `quiz-test-fixture-not-production`
정책·라벨을 사용하고 운영 지갑에서 제외합니다. 테스트 자료는
`server/test/test_utils/quiz_fixture.dart`에만 있습니다.

## 생성 클라이언트 API

모든 메서드는 소유자 인증을 요구합니다. API의 owner 인자는 없습니다.

```dart
client.quiz.getToday() -> Future<QuizToday>
client.quiz.unlockExtra(String date, int expectedRevision,
    String intentId, String requestId) -> Future<QuizQuestion>
client.quiz.answer(int assignmentId, String questionId, int version,
    int answerIndex, String requestId) -> Future<QuizQuestion>
client.quiz.listHistory(int? beforeAssignmentId) -> Future<List<QuizQuestion>>
client.quiz.review(int assignmentId) -> Future<QuizQuestion>
```

`getToday`는 서버 시각의 KST 당일 무료 슬롯을 원자적으로 발급하거나 이미 발급된
슬롯을 반환합니다. 호출자가 미래 날짜나 다른 사용자를 지정할 수 없습니다.

`QuizToday`:

| 필드 | 타입·의미 |
| --- | --- |
| date | String, KST 당일 |
| status | String: `ready`, `contentUnavailable`, `exhausted` |
| free, extra | QuizQuestion?, 해당 슬롯의 기존 발급 |
| extraStatus | String: `freeRequired`, `adRequired`, `issued`, `contentUnavailable`, `exhausted` |
| extraRevision | int?, `adRequired`일 때 무료 발급 assignmentId |
| paidEntitlement | bool, 현재 항상 false |

`QuizQuestion`:

| 필드 | 타입 |
| --- | --- |
| assignmentId | int |
| date, slot | String (`slot`은 `free` 또는 `extra`) |
| questionId | String |
| version | int |
| question | String |
| choices | List<String> |
| conditions, reviewedAt, reviewedBy | String |
| answerIndex, correctIndex | int? |
| explanation, source | String? |
| answeredAt | DateTime? |
| awardedPoints | int, 그 발급의 과거 지급량: 미제출 0, 제출 2 |
| policyVersion | String, 운영 `quiz-v1-20261019` |
| fixtureLabel | String?, 운영 null |

제출 전 `answerIndex/correctIndex/explanation/source/answeredAt`는 null입니다.
복습 응답의 `awardedPoints: 2`는 **이전에 지급한 양**이지 이번 복습 지급이 아닙니다.
`review`는 제출 완료된 자기 발급만 반환합니다. 이력은 제출 완료 발급을 ID 내림차순으로
최대 30개 반환하며, 다음 페이지는 마지막 `assignmentId`를 넘깁니다.
무료·추가 둘 다 포함됩니다. 동일 날짜나 수정 날짜를 커서로 사용하지 않습니다.

## 광고 흐름과 재생

1. `getToday` → 무료 제출 → `getToday.extraStatus == adRequired` 확인.
2. `client.ads.createIntent("extraQuiz", today.date, today.extraRevision!)` 호출.
3. 기존 AdMob SSV 서버 서명 검증으로 인텐트가 `verified`가 될 때까지 기존 조회 사용.
4. `unlockExtra(today.date, today.extraRevision!, intent.id, requestId)` 호출.

SSV 검증 자체는 문제를 발급하지 않습니다. 발급·검증 광고 소비·요청 재생 기록은
같은 DB 트랜잭션입니다. 발급 실패 시 광고 소비도 롤백됩니다. 광고 생성 시와 소비 시
모두 KST 당일·무료 제출·무료 발급 ID 개정·추가 슬롯 미사용·남은 문제를 검사합니다.
전날 인텐트, 다른 소유자, `dailyReward` 인텐트는 추가 슬롯에 사용할 수 없습니다.
인텐트 광고 reward_amount는 검증 메타데이터이며 퀴즈 2P를 변경하지 않습니다.

`requestId`는 소유자 내 모든 product 요청과 같은 공간이며 1~128자입니다.
같은 요청 ID·동일 payload는 원래 응답을 반환하고, 변경 payload는
`idempotencyConflict`입니다. unlock 응답 재생은 그 당시 미제출 DTO일 수 있으므로
최신 상태는 `getToday`로 읽습니다. 새 요청 ID로 같은 답을 보내도 추가 지급은 없고,
다른 답은 `alreadyAnswered`입니다. 제출 시 assignmentId, questionId, version 모두
일치해야 합니다. 계정 삭제와 모든 퀴즈 요청은 AuthUser → ProductAccount 잠금을
공유하여 삭제 직전 인증된 요청이 데이터나 보상을 다시 만들 수 없습니다.

오류는 기존 `ProductException` 또는 `AdException`을 사용합니다. 핵심 product 코드:
`freeRequired`, `staleProjection`, `dailyLimitReached`, `contentUnavailable`,
`exhausted`, `futureDate`, `quizClosed`, `quizNotFound`, `staleQuestion`,
`invalidAnswer`, `alreadyAnswered`, `notAnswered`, `invalidCursor`,
`invalidRequestId`, `idempotencyConflict`, `invalidDate`.
광고 코드는 기존 `configurationMissing`, `purposeUnconfigured`,
`intentNotFound`, `intentNotVerified`, `targetMismatch` 등을 유지합니다.

## 호환·검증·장애 확인

기존 `product.getQuiz/listQuizHistory/answerQuiz`와 `DailyQuiz/QuizState`는
기존 로컬 개발 DB fixture API 그대로입니다. 정답만 2P였던 fixture 동작도 바꾸지
않았으며 운영 엔진으로 간주하지 않습니다. 신규 앱 연동은 `client.quiz`를 사용합니다.
기존 fixture 이력을 새 검토 이력으로 변환하거나 승인하지 않습니다.

마이그레이션 `20261019055832745`는 새 테이블 2개와 unique 인덱스를 추가하며 기존
데이터를 변경하지 않습니다. `quiz_assignment`의 owner/date/slot, owner/questionId/version,
owner/questionId unique 제약은 슬롯 중복과 개정 문항 재지급을 방지합니다.

직접 검증: 고정 SDK와 짧은 임시 경로를 선택하고 테스트 비밀번호 환경에서
`dart test test/unit/quiz_bank_test.dart test/integration/quiz_engine_test.dart`를 실행합니다.
자동 테스트는 실제 격리 PostgreSQL, 생성 HTTP 클라이언트와 테스트 키 SSV 검증을
사용합니다. 운영 문항의 사실성·실기기 광고·실결제·운영 배포는 이 테스트가 보장하지
않으며 사용자 직접 확인도 별개입니다.

실패 시 확인 순서: `BALMATCHUM_QUIZ_BANK_PATH`와 팩 검토 필드 → migration 적용과
동일 버전 충돌 → KST date/extraRevision → 인텐트 purpose/owner/status → requestId
재사용 payload. 응답 유실 때 새 광고를 소비하지 말고 같은 요청 재생 또는 상태를
확인합니다. 콘텐츠 개정은 새 version으로 공급하며 과거 스냅샷을 수정하지 않습니다.
