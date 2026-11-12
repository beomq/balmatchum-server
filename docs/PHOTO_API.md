# 사진 업로드 API (S3 presigned URL)

> 상태: 개발 버킷 `balmatchum-photos-dev`로 로컬 서버 검증. 운영 비밀값 입력과 배포는 하지 않았습니다.

앱이 고른 사진을 서버가 아닌 S3(시드니 `ap-southeast-2`, 비공개 버킷)에 직접 올립니다.
서버는 짧게 유효한 서명 URL만 발급하고, 메타데이터를 PostgreSQL `photo` 테이블에 저장합니다.
AWS 비밀 키는 서버 밖으로 나가지 않으며 SDK 없이 SigV4 query 서명(`server/lib/src/photos/s3_presigner.dart`)을 사용합니다.

## 흐름

1. `photo.createUpload(contentType, byteSize)` → `PhotoUploadTicket`
   - `contentType`은 `image/jpeg`만, `byteSize`는 1..5 MiB(`photoMaxBytes`).
   - 서버는 `photo` 행을 `pending`으로 만들고 5분짜리 PUT URL을 돌려줍니다.
   - 객체 키: `photos/<authUserId>/<photoId>.jpg` (`photoId`는 UUID v7).
   - `Content-Type`과 `Content-Length`가 서명에 포함되므로 다른 크기·형식의 본문은 S3가 403으로 거절합니다.
2. 앱이 `uploadUrl`에 `headers`를 그대로 붙여 PUT합니다.
3. `photo.confirmUpload(photoId, width, height)` → `PhotoView`
   - 서버가 S3 HEAD로 객체 존재·크기·형식을 확인한 뒤 `ready`로 바꿉니다. 이미 `ready`면 같은 결과(멱등).
   - 객체가 아직 없으면 `notUploaded`(재시도 가능). 크기·형식이 다르면 객체와 행을 지우고 `invalidUpload`.
4. `photo.listMine()` → 최신순 `PhotoView` 목록. 각 항목의 `url`은 10분짜리 GET URL입니다.
   URL은 매번 바뀌므로 앱은 `photoId`로 캐시하고, `urlExpiresAt`이 지나면 다시 조회합니다.
5. `photo.deletePhoto(photoId)` → S3 객체를 먼저 지우고 행을 지웁니다. S3 실패 시 행이 남아 그대로 재시도할 수 있습니다.

모든 메서드는 로그인 필요(`requireLogin`)이며 다른 계정의 사진은 `notFound`입니다.

## 제한과 오류 코드 (`PhotoException.code`)

| 코드 | 의미 |
| --- | --- |
| `unsupportedType` | `image/jpeg` 외 형식 |
| `invalidSize` | 0 이하 또는 5 MiB 초과 |
| `tooManyPending` | 5분 안의 미확정 업로드가 계정당 5개 이상 |
| `quotaExceeded` | 확정 사진이 계정당 500개 이상 |
| `invalidDimensions` | 가로·세로가 1..10000 밖 |
| `notFound` | 내 사진이 아님 또는 없음 |
| `notUploaded` | confirm 시점에 S3 객체 없음 |
| `invalidUpload` | S3 객체 크기·형식 불일치(객체 삭제됨) |
| `storageUnavailable` | S3 호출 실패(재시도 가능). 로그에는 상태 코드나 예외 종류만 남기고 서명 URL은 남기지 않습니다 |
| `notConfigured` | 사진 저장소 비밀값 미설정 |

## 정리

- 1시간 안에 확정되지 않은 `pending` 행은 주기 정리(`PeriodicMaintenance`, 1시간)가 S3 객체와 함께 지웁니다(`sweepPendingPhotos`).
- 계정 삭제(`account.deleteAccount`)는 같은 트랜잭션에서 `photos/<authUserId>/` 아래의 모든 객체를 나열해 지우고 `photo` 행을 지웁니다. S3가 실패하면 삭제 전체가 롤백되어 다시 시도할 수 있습니다. 확정 전 객체도 같은 prefix라 함께 지워집니다.
- 알려진 한계: 계정 삭제 직후 아직 유효한(최대 5분) PUT URL로 업로드가 끝나면 그 객체는 행 없이 남을 수 있습니다. 정기 버킷 대조 정리는 아직 없습니다.

## 설정 (Serverpod password)

`awsAccessKeyId`, `awsSecretAccessKey`, `awsRegion`, `photosBucket` 네 개를 한 묶음으로 넣습니다.
네 개 모두 없으면 사진 기능만 꺼지고(`notConfigured`), 일부만 있으면 서버가 시작하지 않습니다.
운영 입력 방법은 [운영 배포](OPERATIONS.md) 6절을 따릅니다.

로컬 개발은 값을 파일이나 저장소에 쓰지 않고 AWS CLI 프로필 `balmatchum-dev`에서 환경변수로 주입합니다.
값은 출력하지 않습니다.

```sh
cd server
eval "$(aws configure export-credentials --profile balmatchum-dev --format env)"
export SERVERPOD_PASSWORD_awsAccessKeyId="$AWS_ACCESS_KEY_ID"
export SERVERPOD_PASSWORD_awsSecretAccessKey="$AWS_SECRET_ACCESS_KEY"
export SERVERPOD_PASSWORD_awsRegion=ap-southeast-2
export SERVERPOD_PASSWORD_photosBucket=balmatchum-photos-dev
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
dart run bin/main.dart --mode=development --apply-migrations
```

dev 키는 dev 버킷에만 Put/Get/Delete/List 권한이 있고 운영 버킷에는 접근할 수 없습니다.
로컬에서 운영 버킷 이름을 쓰지 않습니다.

## 검증

- `test/unit/s3_presigner_test.dart`: AWS 문서의 SigV4 예시 서명과 일치, PUT 서명 헤더·만료, 키 인코딩, 설정 묶음 검사.
- `test/integration/photo_endpoint_test.dart`: 비로그인 거부, 키 형식, 형식·크기 제한, confirm/list/delete, 계정 간 격리, 미확정 개수 제한, 미설정, 정리 작업.
- `test/integration/account_deletion_coverage_test.dart`: 계정 삭제가 `photo` 행과 계정 prefix 객체를 지우고 다른 계정 객체는 남기는지 확인.
- 실제 dev 버킷 E2E 결과는 PR 본문에 기록합니다.
