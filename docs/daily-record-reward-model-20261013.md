# 일일 기록·보상 모델 설계안

2026-10-13 서버 담당. **리뷰용 제안이며 제품 구현·공유 계약 확정이 아니다.** 기준 `7ab29fb232b57bcee25f68f97c0d61fd58304b5e`. 앱 기준은 배정 문서의 `4deacc31c9c0131d8afebbdea29e82fa80cebbc6`이며 앱 checkout 검증·변경은 하지 않았다.

## 1. 근거와 결정 경계

현재 코드에서 확인한 사실:

- `server/lib/src/records/gps_record_input.spy.yaml:1`: schemaVersion, clientRecordId, startedAt, endedAt, source, routePoints만 있다. 걸음·날짜·삭제 상태는 없다.
- `server/lib/src/records/stored_gps_record.spy.yaml:1`: owner+clientRecordId unique, payload 한 행 저장. 원본 metadata와 좌표가 원자적으로 저장된다.
- `server/lib/src/records/records_endpoint.dart:7`: 인증 필수. saveConfirmed는 로그인 사용자 owner를 사용하고 같은 ID의 JSON payload가 다르면 conflict, 같으면 기존 receipt를 반환한다. getMine은 owner로 제한하며 다른 계정은 notFound.
- 같은 endpoint의 _validate는 UTC, 시간 순서, 좌표 범위·유한성·accuracy를 검사한다. 차량 판정·거리 계산·중복 경로·tombstone·일일 보상은 구현되어 있지 않다.
- `server/lib/src/auth/auth_setup.dart`, `kakao_provider.dart`: 서버 세션, 계정 분리 및 로그인 후 세션 철회. 아래 day transaction 직렬화는 인증 정책을 변경하지 않는다.

제품 근거(상위 작업공간에서 읽기만 함):

- `setup/release-contract-20261009.md`, `setup/next-increment-assignment-20261013.md`: 하루 관리, Watch 버튼 GPS/phone 자동 GPS, 삭제 시 미수령 취소·기지급 유지, v1 codec/ACK 불변, 계정별 큐 보존.
- `design/docs/functional-spec.md:9-15,19-29`: HealthKit 통합 집계, 한국 Asia/Seoul 자정, 하루 삭제, GPS 공백 비연결, 경로 없는 실내 걸음 인정. 과거 미수령 미정 문구는 최신 release-contract가 우선한다.
- `design/docs/character-and-walk-events.md:42`: 가상 성장과 실제 반려견 동행을 구분하고 같은 구간 보상 중복 금지. 동행 분류는 이번 API에 추가하지 않는다.

**확정:** 시간대 Asia/Seoul, 하루 삭제, GPS와 걸음 분리, 이미 지급한 포인트 유지, 미수령 취소, 계정 격리. 2026-10-09 사용자 선택은 뒤늦게 확정된 추가분의 추가 수령을 허용한다. 과거의 날짜별 1회 수령 문구는 이를 막는 근거로 사용하지 않는다. 무료 유예 7일, 서비스 측 확정 지연분은 확정 후 최소 3일 보호, 유예 중 선택적 광고 총 2배 방향도 이미 채택됐다. **권고:** 아래 모델/원자성/선택 알고리즘. **미정:** 포인트 액수·인정 걸음/보상 단위, 유예의 정확한 포함 경계, 수동/외부 표본 인정, 품질 임계값, 물리 소거 기간. 최근 30일 자동 반영은 초안이며 하드 거절 기한으로 쓰지 않는다.

위 추가 수령 정책은 리드가 `notes/facts/walk-companion-design-decisions.md`의 2026-10-09 승인 기록과 대조한 교정이다. 문서의 첫 버전은 이전 1회 수령 규칙을 적용했으며, 아래 entitlement/ledger는 추가분을 허용하도록 수정했다. 공유 구현 계약은 `setup/next-increment-contract-20261013.md`를 참조한다.

## 2. 원본, 날짜 투영, 보상의 분리

원본 입력은 수신 시 UTC와 안정적인 ID로 식별하고 정상 수정으로 덮어쓰지 않는다. 투영은 언제든 동일 원본 집합과 algorithmVersion으로 다시 만들 수 있다. 보상 원장은 투영의 revision과 독립된 지급 사실이다. GPS 저장 성공은 일일 집계 확정이나 보상 지급을 뜻하지 않는다.

| 제안 entity | 주요 필드·제약 | 목적 |
| --- | --- | --- |
| SourceRecordReceipt | owner, clientRecordId, serverRecordId, canonicalDigest, schemaVersion, acceptedAt; unique(owner,clientRecordId) | 재전송/충돌 판정. 삭제 후에는 최소 digest/ID만 보존 |
| SourceDayPayload | receiptId, localDate, startedAtUtc, endedAtUtc, points, originalPointIndexes; unique(receiptId,localDate) | 원본을 날짜별로 자른 immutable 보존 단위. 삭제만 예외로 payload 제거 |
| DayGuard | owner, localDate, state(active/deleted), deletionVersion, dataRevision; unique(owner,localDate) | 아직 자료 없는 날짜도 잠글 수 있는 직렬화 기준 |
| DayTombstone | owner, localDate, deletionId, deletedAt, deletionVersion; unique(owner,localDate) | 향후 도착 ID·백업 복원까지 삭제일을 영구 논리 차단 |
| DailyProjection | owner, localDate, revision, algorithmVersion, routeState, stepState, aggregateRef; unique(owner,localDate) | 최신 조회 포인터. deleted에는 경로·걸음 노출 없음 |
| ProjectionSegment | projectionRevision, [from,to), selectedReceiptId, pointIndexRange, reason, alternatives, gapReason | 어떤 원본을 왜 사용/배제했는지. 삭제 시 함께 제거 |
| DailyStepObservation | owner, date, streamId, revision, queryStartUtc/queryEndUtc, total, availability, observedAt; unique(owner,streamId,date,revision) | phone이 전달하는 통합 집계의 교체형 snapshot. 증가분 합산 금지 |
| RewardEntitlement | owner, date, kind, status, evaluatedRevision, policyVersion, confirmedUnits, grantedThroughUnits, nextGrantSequence; unique(owner,date,kind) | 하루 보상 누적 상태와 이미 지급한 단위의 상한. revision 자체를 지급 키로 쓰지 않음 |
| RewardConfirmation | entitlementId, fromUnit, throughUnit, confirmedAt, freeUntil, policyVersion; unique(entitlementId,throughUnit) | 최초 확정·지연 추가 확정 구간의 자격/유예를 보존. 같은 단위 재평가로 유예를 재시작하지 않음 |
| RewardClaimRequest | owner, requestId, requestDigest, resultRef; unique(owner,requestId) | claim 요청 재시도·다른 payload 충돌 |
| PointLedger | id, owner, entitlementId, grantSequence, fromUnit, throughUnit, baseAmount, bonusAmount, policyVersion, grantedAt; unique(entitlementId,grantSequence) | append-only 추가분 지급 사실. 한 entitlement에 중복 없는 여러 지급 가능. 좌표·경로·원본 건강 표본 없음 |

모든 사용자 자료는 owner=인증된 authUserId에서 결정한다. 요청 owner를 신뢰하지 않는다. relation ID만 검증하지 말고 owner 일치도 검증한다. cascade 삭제로 보상 원장을 지우지 않는다. 탈퇴 후 최소 중복 방지 식별자의 보관 근거·기간은 법적/제품 정책으로 별도 결정하며 무기한 개인 식별자 보관을 확정하지 않는다.

## 3. 날짜 귀속·늦은 자료

Asia/Seoul localDate D의 UTC 반열림 구간은 `[D-1 15:00Z, D 15:00Z)`다. timezone 규칙 이름과 계산 version을 명시하고 업로드 날짜·기기 현지 시간대·수신 시각으로 귀속하지 않는다. 원본 종료와 정확히 일치하는 끝점은 이전 구간 geometry 설명에만 쓰고 다음 날의 양/시간에 중복 가산하지 않는다. 정확히 자정에 기록된 실제 point는 새 날짜에 속한다.

자정을 넘는 선분에서 실제 표본이 없는 자정 위치를 만들어 저장하지 않는다. 날짜별 points를 나누고 경계 양쪽의 미관측 연결은 gap으로 표현한다. 부정확한 긴 구간을 직선으로 채워 거리·성장에 반영하지 않는다. elapsed interval과 observed route coverage는 별도 값이다. 0길이 기록은 receipt 가능하나 거리 증거가 아니다.

늦은 정상 업로드는 해당 과거 day를 dirty로 만들고 revision을 증가시켜 재투영한다. 삭제된 day는 revision으로 되살릴 수 없다. 보상 claim 후 projection 수치가 내려가도 원장과 grantedThroughUnits는 유지한다. 나중에 확정량이 지급 상한을 초과하면 그 차이만 추가 수령 가능하다. 재집계 자체가 포인트를 지급하지는 않는다. 액수·인정 단위가 미정인 보상에 숫자0을 지급한 것으로 표시하지 않는다.

유예 경계 권고는 보행일 포함 7번째 날의 다음 한국 자정 전까지, 서비스 측 지연 확정 구간은 확정 시각부터 최소 72시간 보장이다. 두 시각의 최댓값을 구간별 freeUntil로 저장한다. 이는 기존 7일/3일 방향의 구체화 제안이며 확정 운영 시간 규칙이 아니다. 재전송이나 재집계만으로 confirmedAt을 갱신하지 않는다. 광고 총 2배는 해당 미수령 구간의 기본분+추가 1배이며, 이미 지급한 구간 전체를 다시 2배 지급하는 뜻이 아니다. 광고 완료 서버 검증·광고 제거 혜택 경계는 별도 설계하며 클라이언트 성공 콜백만으로 bonusAmount를 확정하지 않는다.

## 4. idempotency와 중복 경로는 다른 문제

같은 owner+clientRecordId+동일 canonical payload는 receipt 재사용, 다른 payload는 conflict다. canonicalization 규칙은 UTC 정규화·숫자 표현·필드 순서까지 version을 고정한다. 현 v1은 JSON equality이므로 기존 자료의 digest를 신뢰 없이 바꿔 충돌 계약을 바꾸지 않는다. 새 canonicalDigest는 기존 equality와의 호환 검증을 먼저 한다.

다른 ID로 같은 payload가 들어오면 별도 수신 이력일 수 있다. payload digest 일치는 후보 표시이지 자동 삭제·동일 활동 증명이 아니다. source/device timestamp만으로 현실의 같은 활동을 확정할 수 없고 GPS로 걸음 수의 중복을 해결할 수 없다. 중복 원본은 보존하되 projection에서 겹치는 시간을 두 번 합산하지 않는다.

선택 권고 알고리즘(정책 검토 필요): 유효한 인접 관측 pair만 후보로 만들고 후보 경계로 시간축을 분할한다. gap threshold·accuracy threshold를 넘는 pair는 관측 공백 처리한다. 각 구간에서 유효 후보 하나를 선택한다: accuracy 있는 후보 우선 → 낮은 accuracy 값 → 짧은 표본 간격 → stable clientRecordId 사전순 → point index. 수신 순서·DB auto ID는 tie-break로 쓰지 않는다. Watch를 항상 우선하지 않는다. 이 선택은 품질 proxy이지 센서 정확도 증명이 아니다.

선택되지 않은 source는 선택 source의 공백에서만 보완한다. 위치가 다른 기기의 점을 하나의 선으로 연결하지 않는다. source 전환·불연속·권한 없음·차량 의심·삭제 경계는 separate segment/gapReason으로 기록한다. 거리 계산은 실제 선택된 유효 pair만 사용하고 중간 경계 절단은 계산 규칙을 명시해야 한다. 임계값을 실기기 근거 없이 확정하지 않는다. algorithmVersion 변경은 새 projection을 생성하되 claim unique key는 유지한다.

걸음은 별도 HealthKit 통합 조회 snapshot이다. phone 값+Watch 값을 합산하지 않는다. 같은 stream revision 다른 값은 conflict, 더 오래된 revision은 최신값을 덮지 않는다. 기기 교체 stream 우선순위는 서버 등록 generation으로 지정해야 하며 임의 기기 ID나 snapshot으로 활성화하지 않는다. unknown/permissionUnavailable/pendingSync/queryFailed와 confirmedZero를 구분한다. 시간별 원시 걸음 데이터가 없는 상태에서 하루 total을 GPS slice에 비례 배분하지 않는다.

## 5. 삭제: 아직 도착하지 않은 기록도 차단

deleteDay는 좌표가 없는 날짜에도 tombstone을 만든다. 삭제일은 이후 새 ID의 업로드도 거부하며 재개/복원 API는 제안하지 않는다. '삭제 이후 새로 걸은 같은 날을 허용할지'는 UX 정책 미정이며 현재 권고는 하루 전체 봉쇄다. 시간 cutoff 방식은 다른 ID 백업 복원 부활을 허용하므로 기본으로 삼지 않는다.

day guard row를 insert-on-conflict로 확보하고 잠근 뒤 tombstone 설정, payload/projection/step 자료 제거, unclaimed entitlement canceled를 한 transaction에서 수행한다. 이미 claimed이면 ledger 유지. 같은 삭제 requestId는 같은 결과, 다른 day에 재사용하면 conflict. 여러 날을 만지는 upload는 date 오름차순으로 guard를 잠가 deadlock 순환을 피한다.

자정 교차 record 중 하루만 삭제되면 원본 전체 JSON 보존은 삭제 정책과 충돌한다. 따라서 receipt/digest는 남기고 삭제일 SourceDayPayload만 제거, 생존일 slice만 유지한다. 원본 immutable은 '정상 변경 금지'이지 삭제 불가가 아니다. 원본 전체를 별도 로그·event outbox에 복제하지 않는다. legacy getMine은 full 원본을 복원할 수 없으므로 삭제된 자료에는 terminal deleted/notFound로 응답하는 후속 버전 계약이 필요하다.

업로드가 먼저 잠그면 저장 후 delete가 제거한다. delete가 먼저 잠그면 후속 upload는 삭제일 payload를 쓰지 않는다. 둘 모두 commit 뒤 삭제일 자료가 없어야 한다. partial acceptance는 삭제된 day와 수락된 day 목록을 명시해야 하며 기존 recordId 하나의 serverSaved 의미를 몰래 넓히지 않는다. v1 클라이언트가 partial receipt를 처리할 수 없으면 교차 record 전체를 terminal deleted로 거부하는 호환 정책을 리드와 먼저 정한다(생존일 자료 손실 trade-off). 삭제 이벤트 outbox는 좌표 없는 day/version만 전달한다.

기기 삭제 전파: authenticated `listDeletionChanges(afterCursor)`로 day/version과 cursor 전달. phone은 local tombstone을 durable 저장한 뒤 Watch에 기존 계정 경계 내 전달. 끊긴 기기가 뒤늦게 보내도 서버 tombstone이 마지막 방어선이다. Watch envelope의 recordId=clientRecordId이고 server receipt recordId와 혼동하지 않는다. old-account 큐는 삭제/계정 전환을 빌미로 새 owner에 재전송하지 않는다.

## 6. 보상 원자성과 정정

하루 상태와 지급 구간을 분리한다. 상태는 pending(자료/정책 미확정), ineligible, eligible(미수령 추가분 있음), settled(현재 추가분 없음), canceled(삭제)다. settled 뒤 신규 확정량이 지급 상한을 초과하면 eligible이 될 수 있지만, canceled는 다시 열리지 않는다. 삭제는 미수령분만 취소하므로 하나의 날짜에 과거 grant와 canceled가 함께 존재할 수 있다.

보상 정책은 날짜별 policyVersion으로 고정하며, 인정 단위를 포인트로 변환하는 단조 함수 F를 제공한다. Q=현재 확정 단위, G=이미 지급한 단위의 상한이면 수령 가능한 기본분은 Q>G일 때 F(Q)-F(G), 아니면 0이다. Q가 내려가도 G를 낮추거나 음수 차감하지 않는다. Q가 다시 올라와도 G 이하 구간은 재지급하지 않는다. 단위·단가·상한이 미정이면 계산/지급하지 않으며 임시 숫자를 운영값으로 넣지 않는다. 정책 변경으로 과거 일일 보상의 F가 바뀌는 것은 명시적 별도 마이그레이션 정책이 필요하다.

claimDayReward(date,kind,requestId,expectedRevision)는 day guard 잠금 → 동일 requestId 결과 우선 조회 → tombstone 확인 → current revision/확정 policy/유예 확인 → entitlement 잠금 → Q와 G 재계산 → 새 grantSequence의 구간 (G,Q]와 ledger insert → G를 Q로 전진 → balance cache/claim 결과 저장을 한 transaction으로 commit한다. expectedRevision 불일치는 staleProjection이며 재조회한다. 요청 ID가 달라도 잠금 뒤 같은 G를 다시 읽으므로 같은 구간을 두 번 지급하지 않는다. unique(entitlementId,grantSequence)는 추가 방어이지 겹치는 구간을 막는 유일한 장치가 아니다. 클라이언트 amount는 받지 않는다. 반복 requestId는 원래 결과만 돌려주며 나중에 생긴 추가분을 같은 요청에 포함하지 않는다. 정책 미확정이면 rewardUnavailable이다.

구간마다 freeUntil과 선택 보너스 자격을 확인한다. 마감이 서로 다른 여러 확인 구간을 한 번에 수령할 때는 각 구간의 기본/보너스 내역을 보존하고 무자격 구간을 조용히 지급하지 않는다. 광고 총 2배는 아직 지급하지 않은 승인 구간에만 적용하며 외부 검증 식별자의 재사용도 막는다. 광고 실패/취소로 지급 상한이 전진하지 않는다. 구체적인 광고 프로토콜·포인트 함수는 이번 설계의 후속이다.

삭제/claim 경합은 guard lock 획득 순서로 선형화한다. claim 먼저 commit하면 그 지급 유지 후 남은 자격 취소, 삭제 먼저면 새 claim은 canceled다. 삭제 후 성공 requestId 재시도는 저장된 지급 사실만 돌려주고 좌표/projection은 재노출하지 않는다. balance 캐시가 있다면 같은 transaction에서 delta 적용, 권위는 ledger다. 외부 알림 실패는 commit된 지급을 취소하지 않으며 outbox로 분리한다.

정정은 raw overwrite가 아니라 명시적 correction/supersedes 관계와 사유·version을 둔다. 현 v1에는 정정 endpoint가 없으므로 다른 ID를 정정으로 자동 추론하지 않는다. correction은 affected days guard를 잠그고 revision을 바꾼다. 늦은 정상 추가 확정분의 수령은 위 누적 구간 규칙을 따르며, 별도의 부정 회수/음수 원장은 승인하지 않는다.

## 7. 후속 API 제안과 구현 순서

현재 saveConfirmed/getMine는 그대로 유지한다. 아래는 이름·형태의 리뷰 제안이며 generated client 변경 없음:

- getDailyRecord(date): projection revision, availability, segments/gaps, rewardStatus, deletionVersion. owner는 세션에서.
- listDailyRecords(cursor): owner별 날짜/상태 페이지. 없는 자료와 삭제를 구분하되 다른 계정 자료를 누설하지 않음.
- submitDailyStepObservation(date,streamGeneration,revision,window,total?,availability): 앱 통합 집계용 별도 계약. v1 GPS envelope 확장 아님.
- deleteDailyRecord(date,requestId): deletionVersion 및 canceled/retained reward 상태.
- listDeletionChanges(afterCursor): 재연결·기기 복원 동기화용.
- claimDailyReward(date,kind,requestId,expectedRevision): ledgerId/amount/이미 지급 결과 또는 typed error.
- 향후 GPS 수신 v2: acceptedDays/deletedDays와 terminal 상태. 기존 serverSaved는 실제 동일 server receipt일 때만 사용.

권고 증분: (1) 날짜·source receipt/slice·guard·삭제 모델과 v1 호환 계약 → (2) projection/step observation, 측정된 품질 정책 → (3) 확정 보상 정책을 주입한 entitlement/ledger/claim. 단계마다 실제 HTTP+DB 테스트, CLI 모델 생성·migration 적용을 수행해야 한다. 이번에는 아무 단계도 구현하지 않았다.

## 8. 경계 사례와 미래 테스트 행렬

| 입력/경합 | 기대 결과와 검증 지점 |
| --- | --- |
| 10/13 23:59~10/14 00:02 KST, 다음날 업로드 | 10/13·14로 분할. 자정 가상점 없음, receipt 하나와 slice 둘, 해당날 revision만 변경 |
| 14:59:59Z와15:00:00Z 표본 | 서로 다른 KST date. 자정 point 이중 계산 없음 |
| 10/13 삭제 후10/20 새로운 ID로10/13 업로드 | tombstone hit, payload/보상 부활 없음. 원 ID를 모르더라도 차단 |
| 위 삭제일과10/14에 걸친 record | 삭제일 좌표0, 생존일 slice만 허용하는 v2 또는 명시적 v1 전체 거부. ACK 계약 테스트 필수 |
| ID A 동일 payload 10회 동시 저장 | receipt 하나. 같은 A 다른 payload는 conflict |
| ID A/B 동일 시간·좌표 | 두 수신 이력, projection 한 구간. 동일 실제 활동 증명으로 오인하지 않음 |
| phone 품질좋음/Watch 품질낮음 겹침 | 결정적 선택. 입력 도착 순서를 뒤집어도 동일 projection/provenance |
| phone 공백에 Watch 표본 존재 | Watch segment 보완, 둘 사이 직선 생성 없음 |
| HealthKit 권한 거절/조회 실패 | unknown 계열, 실제0으로 확정하지 않음. 보상 pending |
| 하루7000→지연8000→정정6500 snapshot | 합산21500 금지. stream revision별 최신6500, 기지급은 유지 |
| 같은 확정 단위 Q에 claim 20개 | 새 구간 ledger1개·balance1회 증가. requestId가 달라도 같은 구간 중복 없음 |
| Q=7000 지급 후8000 확정·다시 claim | (7000,8000]만 추가 지급. 초기 requestId 재전송은 초기 지급 결과만 반환 |
| 8000까지 지급 후6500으로 정정·이후7500/8500 | G=8000 유지. 7500에서는 없음, 8500이면 (8000,8500]만 수령 가능 |
| 기본분 수령·광고 실패·삭제·재시도 | 각 요청의 확정 구간/광고 검증 사실만 인정. 실패나 삭제가 기지급 구간 재수령을 만들지 않음 |
| claim과 delete 동시 | 순서에 따라 grant 유지 또는 canceled, 둘의 모순 상태 없음 |
| 재집계와 claim 동시 | guard로 current revision 일치 검증, staleProjection 명시 |
| 계정 A 큐를 B 로그인에서 송신 | 앱에서 격리, 서버 owner B로 A의 참조 ID 조회 불가. 서버가 센서 출처의 A 귀속을 payload만으로 증명할 수 없다는 한계도 시험 |
| 계정 A 삭제 tombstone을 B가 조회 | notFound/권한 거부, 날짜·보상 정보 누설 없음 |
| 삭제 outbox 실패·기기 장기 오프라인 | 서버 삭제 유지, cursor 재시도, 도착하는 과거 자료 계속 거부 |

테스트는 고정 clock·DB transaction barrier로 경합을 강제하며 sleep에 기대지 않는다. 순열 기반 projection 결정성/interval 중복 없음 속성 검사를 추가한다. 문서 문구를 pinning하는 테스트는 만들지 않는다.

## 9. 리드 결정 요청과 검증 한계

우선 seam: (a) 부분 삭제/부분 수락의 v2 receipt와 v1 terminal 처리, (b) 삭제된 오늘에 새 활동도 봉쇄하는 정책, (c) HealthKit stream generation 및 인정 표본 규칙, (d) 인정 단위·단가와 유예 포함 경계. 뒤늦은 추가 확정분 수령 자체는 채택된 방향이며 미정으로 되돌리지 않는다. 원본 공유 계약은 리드만 변경한다.

실행 증거는 fetch 기준 일치, worktree 생성, 현행 코드·기획 문서 읽기, 문서 diff 검사뿐이다. migration/컴파일/실기기 검증은 실행하지 않았다. 기기 배터리, OS background 유지, HealthKit 중복 처리 정확도, GPS 누락률, WatchConnectivity 내구성을 서버 문서만으로 통과 선언할 수 없다. 그 결과가 있어야 품질 threshold와 보상 자격을 구현할 수 있다. 사용자 이해 확인과 운영 준비도 미확인이다.
