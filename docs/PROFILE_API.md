# 반려견 프로필 API

## 계약

Serverpod 4.0.3 생성 client의 `client.profile` 호출입니다. 아래 모든 메서드는
서버 인증 세션을 요구하며 userId/owner를 인자로 받지 않습니다.

```dart
Future<ProfileView?> getProfile()
Future<ProfileView> createProfile(ProfileInput input, String requestId)
Future<ProfileView> renameDog(String name, String requestId, int expectedRevision)
Future<ProfileView> updateGoal(int goal, String requestId, int expectedRevision)
```

- `ProfileInput`: breedId, name, sex (String), dailyGoal (int).
- `ProfileView`: 입력의 네 필드와 firstMetAt (UTC DateTime), revision (int).
- 최초 조회는 null이며, 생성 revision은 1입니다. 이름/목표 변경 성공마다 1 증가합니다.
- firstMetAt은 생성 트랜잭션 안의 서버 clock으로 정하고 이후 변경하지 않습니다.
- 소유자당 한 프로필만 허용합니다. 별도 요청 ID로 두 번째 생성은 alreadyExists입니다.
- 삭제, 품종/성별 변경, provider 변경, 경제 정책은 이번 계약에 없습니다.

## 입력과 재실행

이름은 앱 FirstMeetingController처럼 trim 후 1~12 grapheme입니다.
영문 대소문자, 숫자, ASCII 공백, 한글 음절·호환 자모·조합 자모·확장 자모만 허용합니다.
`characters`를 직접 의존성으로 선언해 조합형 한글도 앱과 같은 길이로 계산합니다.
sex는 male/female, dailyGoal/goal은 양의 정수입니다. 임의 상한이나 경제 정책은 추가하지 않습니다.
breedId는 앱 FirstMeetingCatalog의 30개 ID이며 표시 이름을 받지 않습니다.
카탈로그가 바뀌면 `server/lib/src/profile/profile_service.dart`의 목록도 함께 검토해야 합니다.

requestId는 1~128 길이이며 기존 ProductRequest의 소유자별 이름 공간을 공유합니다.
메서드 이름과 원본 입력(변경 시 expectedRevision 포함)을 digest에 넣으므로
trim 결과가 같아도 원본 payload가 다르면 idempotencyConflict입니다.
동일 요청의 성공 응답은 원래 ProfileView 그대로 재생합니다. 이후 revision이 올라가도
과거 요청을 다시 보내면 과거 응답이므로 최신 상태는 getProfile로 조회합니다.
실패는 기록하지 않으며, 응답 유실 시 같은 ID와 같은 payload로 재전송합니다.

CAS는 최신 revision과 expectedRevision이 같을 때만 수정합니다.
staleRevision이면 getProfile로 재조회하고 사용자 변경을 검토한 후 새 requestId로 보냅니다.
원본 성공 요청의 재생은 CAS 검사보다 먼저 처리합니다.

## 실패 계약과 저장

인증 실패는 Serverpod의 unauthorized 응답(생성 클라이언트 ServerpodClientUnauthorized)입니다.
그 외 ProfileException.code는 invalidName, invalidBreed, invalidSex, invalidGoal,
invalidRequestId, idempotencyConflict, alreadyExists, notFound, staleRevision입니다.

ProfileEndpoint → ProductService.run → ProfileService 순서로 호출합니다.
기존 ProductAccount의 소유자 잠금 안에서 읽기·생성·수정·응답 기록을 처리하여
동시 생성과 서로 다른 기기의 CAS 수정도 직렬화합니다. dog_profile_owner 고유 인덱스는
DB에서도 소유자당 하나를 보장합니다. 보상/가격 fixture 조건과 무관하게 사용할 수 있습니다.

생성 migration `20261017054642164`는 dog_profile 테이블과 고유 인덱스만 추가합니다.
기존 테이블/데이터를 삭제하거나 변경하지 않습니다. 운영 DB 적용은 수행하지 않았습니다.

## 직접 검증과 장애 확인

FVM Flutter 3.47.5의 Dart 3.13.4 환경에서 서버 패키지 기준:

```sh
SERVERPOD_PASSWORD_database=local-disposable-test-only dart test test/integration/profile_endpoint_test.dart --reporter expanded
```

테스트는 내장 임시 PostgreSQL migration 적용 후 익명 거절, A의 생성/재생과 행 수,
B의 격리, 잘못된 입력, 서버 시계 고정, 수정 후 firstMetAt 불변을 확인합니다.
실제 생성 클라이언트 HTTP 경로에서도 인증/직렬화와 별도 트랜잭션의 동시 생성,
동일 ID 동시 재생, 동시 rename의 단일 성공 및 staleRevision을 확인합니다.
고정 sleep이나 경쟁 승자 가정은 없습니다.

장애 시 인증 헤더 → getProfile 결과/revision → requestId/payload 재사용 여부 →
적용 migration/소유자 인덱스 순서로 확인합니다. 운영 적용, 앱 연동, 사용자 직접 실행과
이해 확인은 자동 QA와 별개이며 이번 작업에서 수행하지 않습니다.
