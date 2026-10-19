# 유료 보상·추가 퀴즈 연동 (2026-10-19)

승인된 정책은 활성 결제가 검증 광고를 **대체**하는 것이다. 걸음 청구 대상 기본분의
총 2배이며 기존 지급분에 2배를 더하지 않는다. 광고/무료/유료가 같은 구간과 일일 상한을
공유한다. 퀴즈는 무료 제출 후 하루 추가 1문제, 정오답과 무관한 최초 제출 2P다.
운영 문항 팩은 아직 별도 공급 대상이며 테스트 문항을 운영 콘텐츠로 승인하지 않는다.

## 생성 클라이언트 계약

모든 API는 인증이 필요하다. owner, 구매 토큰, premium bool을 요청에 넣지 않는다.

```dart
Future<RewardGrant> client.product.claimDayWithPremium(
  String date, String requestId, int expectedRevision);
Future<QuizToday> client.quiz.getTodayWithPremium();
Future<QuizQuestion> client.quiz.unlockExtraWithPremium(
  String date, int expectedRevision, String requestId);
```

기존 `claimDay`는 유료 사용자에게도 무료 금액만 지급한다. 기존 `claimDayWithAd`,
`quiz.unlockExtra`는 검증 광고가 필요하다. 자동 프리미엄 전환은 없다.
`billing.verifyPurchase/restorePurchase/getEntitlement` 계약은 BILLING_API.md를 따른다.

걸음 화면: 구매 등록/복원 후 `billing.getEntitlement().active`를 새로 읽고,
`product.getDay(date)`의 revision과 `adClaimablePoints`를 사용한다. 활성 결제의
예상 지급액은 `adClaimablePoints`와 같다. `rewardStatus == adRequired`인 무료 유예
만료 미수령 구간도 청구 가능하다. 이는 화면용 관측이며 지급 보장이 아니다.
실제 청구는 재검증하고 잠금 안에서 현재 시간과 순번을 다시 검사한다.
이미 받은 구간은 추가 지급하지 않는다. 기본 상한 100P, 모두 유료/광고라면 최대 200P다.
신규 증가분의 72시간 보호가 과거 구간 유예를 연장하지 않는다.

퀴즈 화면: 무료 경로 `getToday`는 결제 통신을 하지 않고 `paidEntitlement: false`,
`premiumStatus: notChecked`를 반환한다. false를 결제 없음으로 단정하면 안 된다.
`getTodayWithPremium`은 신선한 조회 후 `premiumStatus: active|inactive`와
`paidEntitlement`를 반환한다. 조회 실패를 inactive로 숨기지 않고 BillingException으로
반환한다. 활성 결제이며 무료 제출·남은 문항·미사용 추가 슬롯 조건이 맞으면
`extraStatus: premiumAvailable`, `extraRevision`은 무료 assignmentId다.
나머지 상태는 `freeRequired`, `issued`, `contentUnavailable`, `exhausted`,
비활성 결제에서 가능한 `adRequired`다. `extraRevision`은 `adRequired` 또는
`premiumAvailable`일 때만 제공된다. 활성 결제도 콘텐츠/일일 한도를 우회하지 못한다.
`answer/listHistory/review`와 QuizQuestion은 기존 계약이다. 발급 후 제출에는 결제를
다시 요구하지 않는다. 광고로 발급한 문제도 광고를 제출 때 다시 소비하지 않는 것과 같다.

## 재시도와 오류

`requestId`는 기존 owner별 product 요청 공간을 공유한다. 동일 ID·payload는 원래
성공 응답을 반환하며 스토어에 다시 연결하지 않는다. 환불·만료·스토어 장애나 날짜
삭제 뒤에도 기존 걸음 지급 사실만 재생한다. 퀴즈 재생 DTO는 발급 당시 미제출 상태일
수 있으므로 최신 상태는 getToday로 확인한다. 계정 탈퇴 뒤에는 인증/존재 검사로 거부한다.
다른 payload나 다른 지급 방식으로 같은 ID를 쓰면 `ProductException.idempotencyConflict`다.

- `BillingException.entitlementInactive`: 신선한 구매 조회에 현재 활성 권한 없음.
- `temporarilyUnavailable`, `invalidPurchase`, `configurationMissing`,
  `purchaseUnavailable`, `staleObservation`: 기존 결제 의미 유지.
- `staleObservation`: 더 나중 결제 요청이 순번을 예약했다. 그 요청이 실패했어도
  오래된 결과로 소비하지 않는다. 진행 중 요청 완료 후 같은 ID를 재시도하거나
  화면을 새로 조회한다. 성공한 중복 호출이 있다면 원래 성공 결과를 재생한다.
- ProductException의 `staleProjection`, `nothingToClaim`, `dayDeleted`,
  `freeRequired`, `dailyLimitReached`, `contentUnavailable`, `exhausted`,
  `futureDate`, `quizClosed` 등 기존 정책 오류를 유지한다.

성공 응답 유실은 실패 확정이 아니다. 새 ID로 재청구하지 말고 원래 ID/date/revision을
그대로 재전송한다. 광고·프리미엄 버튼은 공유 슬롯/구간을 소비하므로 동시에 누르지 않는다.

## 구현 선택과 잠금

기존 BillingService의 실제 Apple/Google 검증 경로를 재사용한다. 새 검증기는 없다.
전체 저장 구매 목록에 한 account sequence를 예약하고 각각 재조회한다. 일부 구매가
실패하면 소비하지 않는다. 스토어 재조회·Google 승인은 owner 트랜잭션 밖에서 실행한다.
server-only BillingBenefit에는 owner/binding/sequence만 담으며 앱에는 노출하지 않는다.
소비 시 ProductService가 AuthUser → ProductAccount 잠금을 얻은 뒤 같은 트랜잭션에서
binding/sequence와 각 구매 sequence를 비교하고 만료 exclusive 조건을 검사한다.
그 뒤 기존 원장·구간/퀴즈 슬롯·재생 결과를 원자적으로 기록한다.
추가 요청의 순번 예약·환불 관측·탈퇴가 먼저 이기면 소비가 실패한다. 이미 소비가
잠금을 잡은 경우 삭제/새 관측은 commit 이후 진행된다. 외부 스토어에서만 발생하고
아직 관측되지 않은 환불까지 원자화할 수는 없다. 여러 구매도 모두 재조회하며
실패 시 오래된 활성 행으로 대체하지 않는다.

성공 재생은 조회 전과 소비 트랜잭션 안에서 검사한다. 동시 최초 호출은 한쪽이
staleObservation을 받을 수 있지만 원장은 한 번만 생긴다. 별도 DB 열/마이그레이션은
필요하지 않으며 새 DTO 필드와 endpoint는 CLI 생성물에 포함된다.

## 직접 검증과 장애 확인

```sh
export PATH=/Users/beomseok/fvm/versions/3.47.5/bin/cache/dart-sdk/bin:$PATH
export PUB_CACHE="${PUB_CACHE:-$HOME/.pub-cache}"
export RUN_TMP="$(mktemp -d /tmp/bmpaid.XXXXXX)"
export TMPDIR="$RUN_TMP/" XDG_CACHE_HOME="$RUN_TMP/cache"
mkdir -p "$XDG_CACHE_HOME"
cd server
SERVERPOD_PASSWORD_database=local-disposable-test-only dart test test/integration/billing_endpoint_test.dart --reporter expanded
```

테스트는 실제 격리 PostgreSQL·인증 HTTP·생성 client·실제 결제 파서를 사용한다.
외부 스토어 전송만 고정 fixture이며 Completer로 경합을 제어한다. 네트워크 중
별도 연결의 AuthUser FOR UPDATE NOWAIT가 성공하는지도 검사한다.
장애 확인 순서: 결제 설정/오류 code → 새 entitlement → 날짜 revision/구간 또는
퀴즈 extraRevision/콘텐츠 → 원래 requestId → 원장/슬롯이다. 구매 원문은 로그로 남기지 않는다.
실제 콘솔·구매·앱 UI·사용자 직접 검증·배포·알림·월별 선물은 이 증분에 포함되지 않는다.

## 실행 근거

Dart 3.13.4 / Serverpod CLI 4.0.3에서 양 패키지 `pub get --enforce-lockfile`과
`analyze --fatal-infos`가 성공했다. 전체 149개 Dart 파일 format 검사 변경 0개,
관련 결제/보상/퀴즈/광고 테스트 69개가 통과했다. 이후 다중 구매 재조회·스토어
유예 만료·거래 rollback 사례 3개를 추가한 최종 전체 테스트는 **284개 통과**했다.
결제 HTTP 파일에는 기존 16개와 신규 혜택 16개, 합계 32개 테스트가 있다.
모든 경합은 Completer로 제어했고 store HTTP 중 별도 owner 잠금 획득도 검사했다.
최초 검사에서 새 테스트 중괄호 스타일 1건과 광고 fixture transaction ID 형식을
수정했다. 최종 전체 실행에는 해당 실패가 없다. 테스트의 의도적 DB 예외/인증 거부
로그는 거절·rollback 검증이며 테스트 실패가 아니다.
재생성 전후 생성 diff 해시와 미추적 파일 목록이 동일했고 `create-migration`은
`No changes detected`로 종료했다. LSP 최신 진단은 시간 초과였지만 고정 SDK의
전체 정적 분석은 양 패키지 모두 무진단으로 통과했다.
`dart build cli --target bin/main.dart --output build`도 native asset 3개를 포함한
실행 파일을 생성하고 종료 코드 0으로 완료했다. 위 최종 검증 명령은 모두 종료 코드 0이다.
