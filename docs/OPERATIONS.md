# 운영 배포 (Serverpod Cloud)

> 상태: 저장소 배포 설정입니다. 소유자는 프로젝트 생성을 확인했으며 이 작업에서는 비밀값 입력·배포를 하지 않았습니다.
> 근거 문서는 2026-10-27에 읽은 https://docs.serverpod.dev/cloud 와 serverpod_cloud_cli 1.2.0 소스입니다.
> 명령은 `scloud <명령>` 또는 `serverpod cloud <명령>` 중 하나로 실행하며 두 형식은 같습니다.

## 1. 구성 요약

| 항목 | 값 |
| --- | --- |
| 배포 단위 | 서버 패키지 `server/` (`scloud.yaml`, `.scloudignore` 위치) |
| Dart SDK | `scloud.yaml`의 `dartSdk: "3.13"` (CI 3.13.4와 같은 minor) |
| 실행 설정 | `config/production.yaml` 없음. Cloud가 `SERVERPOD_*` 환경변수로 주입 |
| DB | Cloud 관리형 PostgreSQL 17, TLS 필수. 접속값과 `database` 비밀번호는 플랫폼이 주입 |
| Cloud 프로젝트 ID | `balmatchum-prod` (생성 완료) |
| 기본 주소 | API `https://balmatchum-prod.api.serverpod.space/`, Web `https://balmatchum-prod.serverpod.space/`, Insights `https://balmatchum-prod.insights.serverpod.space/` |
| 앱 `SERVER_URL` | 확정 기본 도메인 `https://balmatchum-prod.api.serverpod.space/` |
| 요금제 | 테스트 중 Starter, 공개 출시 전 Growth 전환 |
| 첫 출시 | 보상형 광고와 Apple/Google 인앱 결제 포함 |

`client/`는 서버의 dev_dependency이지만 scloud가 업로드할 때 `dev_dependencies`를 제거하고 `pubspec.lock`을 정리하므로 업로드하지 않아도 빌드됩니다. 첫 배포 전에는 `scloud deploy --wet-run --show-files`로 업로드 목록을 확인합니다.

## 2. 배포

서버 패키지(`server/`)에서 실행합니다.

```sh
dart pub global activate serverpod_cli 4.0.3      # pre_deploy hook가 사용
scloud deploy --wet-run --show-files              # 업로드 목록·빌드 사전 점검(배포 안 함)
scloud deploy                                     # Upload → Cloud build → Rollout
scloud status deployment show                     # 진행 상태 추적
```

- `pre_deploy` hook는 고정 CLI 4.0.3으로 `generate`를 실행합니다. 생성 코드가 커밋된 내용과 다르면 `git diff --exit-code`가 실패하고 업로드 전에 배포를 중단합니다.
- 배포는 `main`의 릴리스 태그 커밋에서만 실행합니다. 작업 트리에 커밋되지 않은 변경이 없어야 합니다.
- 빌드가 실패하면 Cloud는 이전 성공 버전으로 계속 서비스합니다.

## 3. 마이그레이션

Cloud는 배포할 때마다 `migrations/`의 미적용 migration을 자동으로 적용합니다. 별도의 `--apply-migrations` 단계는 없습니다.

1. 위험한 migration이 포함된 배포 전에는 수동 스냅샷을 만듭니다: `scloud db backup create --name pre-<버전> --expire-in 7d`
2. 실패하면 `scloud log`에서 `Failed to apply database migrations.`를 확인합니다. migration을 고친 뒤 커밋하고 다시 배포합니다.
3. 이미 적용된 migration은 되돌리지 않습니다. 모델을 되돌린 뒤 `create-migration`으로 forward migration을 만듭니다. 이 방식은 스키마만 되돌리며 데이터는 복원하지 않습니다.

## 4. 롤백

공식 문서에는 "이전 배포로 되돌리기" 전용 명령이 없습니다(2026-10-27 기준).

- **코드 롤백**: 직전 정상 릴리스 태그를 checkout(또는 revert 커밋)한 뒤 `scloud deploy`합니다. `scloud status deployment list`로 성공 배포 이력을 확인합니다.
- **스키마가 바뀐 경우**: 이전 코드는 새 스키마와 맞지 않을 수 있습니다. forward migration을 만들거나 아래 백업 복원과 함께 결정합니다.
- **데이터 롤백**: 5절의 스냅샷 복원을 사용합니다. 복원하면 현재 데이터가 대체되므로 복원 전에 현재 상태를 스냅샷으로 남깁니다.

## 5. 백업·복원 (Growth 요금제 기능)

공개 출시 전 **Growth 전환 + 일일 백업 + 복원 연습 1회**가 todo 15의 go 조건입니다.
Starter 테스트에는 백업이 없으므로 복구 검증 완료로 간주하지 않습니다.

```sh
scloud db schedule set --frequency daily --hour 18 --retention 35d   # 매일 03:00 KST(=18:00 UTC)
scloud db schedule show
scloud db backup create --name pre-release --expire-in 7d            # 수동 스냅샷
scloud db backup list
scloud db backup create --name before-restore                        # 복원 전 현재 상태 보존
scloud db backup restore <snapshot-id>                               # 확인 프롬프트, 되돌릴 수 없음
```

- 예약 스냅샷은 최대 35일 보관합니다. 수동 스냅샷은 `--expire-in`을 지정하지 않으면 직접 삭제할 때까지 보관하며 최대 100개입니다.
- 복원 후에도 접속 정보는 그대로라 서버 설정을 바꿀 필요가 없습니다.
- 백업 저장 비용은 별도로 과금됩니다(1GB당 월 $0.560). 백업이 남아 있으면 Starter로 내릴 수 없습니다.
- `scloud db wipe`는 운영 DB에 사용하지 않습니다.

## 6. 비밀값과 변수 (이름만)

모든 사용자 설정 비밀값은 **password** 계층(`scloud password set <이름> --from-file <파일>`)으로 넣습니다. 코드는 `getPassword('<이름>')`로 읽습니다. 값은 이력에 남지 않도록 `--from-file`을 사용하고, 임시 파일은 사용 후 삭제합니다.

플랫폼 자동 관리(설정 금지): `database`, `serviceSecret`, `SERVERPOD_DATABASE_*`.

| 그룹 | password 이름 | 비고 |
| --- | --- | --- |
| 세션 | `serverSideSessionKeyHashPepper` | 없으면 모든 로그인 거부. 한 번 정하면 회전 시 전 세션 무효 |
| 카카오 | `kakaoAudience`, `kakaoIssuer` | issuer는 `https://kauth.kakao.com`만 허용 |
| 네이버 | `naverClientId`, `naverClientSecret`, `naverRedirectUri` | 운영 redirect: `com.beomq.balmatchum://naver/callback` |
| 구글 | `googleClientSecret` | client secret JSON(`web.client_id`, `web.client_secret`, `web.redirect_uris`) |
| 애플 로그인 | `appleServiceIdentifier`, `appleBundleIdentifier`, `appleRedirectUri`, `appleTeamId`, `appleKeyId`, `appleKey` (선택 `appleAndroidPackageIdentifier`, `appleWebRedirectUri`) | `appleKey`는 Sign in with Apple P-256 키 |
| 결제 공통 | `billingIdentityHmacKey` | base64, 디코딩 32바이트 이상 |
| 결제 Apple | `billingAppleBundleId`, `billingAppleIssuerId`, `billingAppleKeyId`, `billingApplePrivateKey`, `billingAppleEnvironment`, `billingAppleProducts` | 첫 출시 필수, 6개 완전 묶음 |
| 결제 Google | `billingGooglePackageName`, `billingGoogleClientEmail`, `billingGoogleKeyId`, `billingGooglePrivateKey`, `billingGoogleEnvironment`, `billingGoogleProducts` | 첫 출시 필수, 6개 완전 묶음 |
| AdMob SSV | `admobPlacements` | 첫 출시 필수, 아래 JSON과 콘솔 값 일치 |

### 비밀 파일 도우미

서버 패키지에서 실행합니다. 기존 Git work tree 밖의 디렉터리에 **키 이름과 정확히 같은
이름의 파일**을 하나씩 준비합니다. 파일 내용은 채팅·명령 인자·Git·로그로 전달하지 않습니다.
디렉터리 권한은 700, 파일 권한은 600으로 관리하고 생성 후 비밀번호 관리자에 보관합니다.

```sh
bash tool/cloud/set_passwords.sh --generate-local /absolute/private/passwords
bash tool/cloud/set_passwords.sh --dry-run /absolute/private/passwords
# 소유자 CLI 브라우저 로그인 후, 별도 입력 승인 시에만:
bash tool/cloud/set_passwords.sh /absolute/private/passwords
```

`--generate-local`은 세션 pepper(48바이트)와 billing HMAC 키(32바이트)만 생성하고
종료합니다. 기존 파일을 덮어쓰지 않습니다. `--dry-run`은 키별 SET/MISSING만 출력하고
네트워크를 사용하지 않습니다. SET은 로컬 파일의 존재·비어 있지 않음을 뜻하며 Cloud 상태가 아닙니다.
Naver 3개, Apple 로그인 6개, billingApple 6개, billingGoogle 6개의 부분 묶음은
dry-run에서도 실패합니다. AdMob은 단일 키 묶음입니다. 실제 업로드는 선택 Apple
Android/web 2키 외의 전체 키가 있어야 시작합니다. 형식·JSON·PEM·콘솔 일치는 서버와
별도 실기기 검증 책임이며 도우미가 검증하지 않습니다.

도우미는 `scloud password set --project balmatchum-prod --name <키> --from-file <경로>`를
사용하며 scloud가 없으면 `serverpod cloud`로 전달합니다. 공식 플래그:
https://docs.serverpod.dev/cloud/reference/cli/commands/password (`set`).
CLI 원문 출력은 버려 값 노출을 막고 실패한 키 이름만 알립니다. 업로드는 여러 개의 개별
쓰기이므로 중간 실패 시 앞선 키는 반영될 수 있습니다. 동일 파일로 다시 실행하고 상태는
`scloud password list --project balmatchum-prod`에서 확인합니다.
이미 사용 중인 pepper/HMAC을 재생성하면 로그인·결제 식별에 영향이 있으므로 회전은 별도 작업입니다.

### AdMob 콘솔과 서버 설정

SSV는 공개 API의 `GET /admob/ssv`로 수신하므로 Cloud 배포가 가능합니다.
모든 보상형 ad unit에 `https://balmatchum-prod.api.serverpod.space/admob/ssv`를 등록합니다.
소유자는 AdMob 브라우저 로그인으로 Android 앱 ID(없으면 생성), iOS 앱 등록 상태,
`dailyReward`와 `extraQuiz` 각각의 Android/iOS 보상형 ad unit을 준비합니다.
reward item은 공백과 `~`가 없는 ASCII(예: `daily_reward`, `extra_quiz`)로 지정합니다.
비정규 인코딩으로 서명된 요청은 보상 없이 400(fail closed)입니다(todo 17 검증).

`admobPlacements` 파일의 JSON 구조(`server/lib/src/ads/ad_config.dart`):

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

예시 문자열 대신 콘솔 값을 준비합니다. 숫자 수량도 문자열이며 포인트 지급량이 아닙니다.
로더는 두 목적 중 하나 이상을 허용하지만 첫 출시에는 둘 다, 각각 iOS·Android 단위를 준비합니다.

- 목적 키는 `dailyReward`/`extraQuiz`만, 목적당 키는 `adUnits`/`rewardItem`/`rewardAmount`만,
  `adUnits`에는 `ios`와 `android` 둘 다 있어야 합니다. 예전 `adUnit` 단일 키는 기동 오류입니다.
- 단위 값은 앱이 그대로 로드하는 **전체 ID** `ca-app-pub-<16자리>/<10자리>`입니다. Google SSV
  콜백의 `ad_unit`은 `/` 뒤 숫자 ID이므로 서버는 전체 ID와 그 숫자 ID를 같은 단위로 인정합니다.
  그래서 숫자 ID는 모든 목적·플랫폼에서 서로 달라야 하며 중복은 기동 오류입니다.
- 같은 목적의 iOS/Android 단위는 콘솔에서 같은 reward item·amount로 설정합니다.

앱은 `createIntent`에 실행 OS를 보내고 서버는 그 플랫폼 단위를 인텐트로 반환합니다.
이 계약을 쓰는 클라이언트 pin으로 앱을 갱신해야 합니다(ADMOB_SSV_API.md).
기존 pending 인텐트가 있으므로 단위 교체는 영향 확인 후 수행합니다.

일반 변수(평문, `scloud variable set`):

| 이름 | 값 |
| --- | --- |
| `BALMATCHUM_QUIZ_BANK_PATH` | `./assets/quiz/reviewed-v1.json` (이 이름으로 승인 팩을 공급한 뒤 설정) |
| `SERVERPOD_SESSION_LOG_CLEANUP_INTERVAL` / `_RETENTION_PERIOD` / `_RETENTION_COUNT` | 예: `24h` / `90d` / `100000`. 세 값을 모두 설정해야 로그 정리가 켜짐 |

비밀값은 한 그룹에서 일부만 넣으면 서버가 시작할 때 실패합니다(의도된 동작).
비밀값과 password의 저장 한도는 프로젝트당 합계 64,000바이트입니다.

### 운영 퀴즈 팩 (todo 20 승인 대기)

이 변경은 팩을 추가하거나 콘텐츠 승인을 대신하지 않습니다. 실제 검토한 `kind: "reviewed"`
팩을 저장소 기준 `server/assets/quiz/reviewed-v1.json`에 넣는 작업은 todo 20입니다.
[팩 형식과 버전 규칙](QUIZ_ENGINE_API.md)을 따릅니다.

공식 [비 Dart 파일 가이드](https://docs.serverpod.dev/cloud/guides/ship-non-dart-files)의
“Read an asset at runtime”은 서버 프로젝트 루트(`lib/`, `bin/`, `assets/`의 부모)를
기준으로 `./assets/<path>`를 사용하도록 명시합니다. 따라서 저장소 루트의 `./server/assets`
또는 빌드 머신의 절대 경로가 아니라 아래 값을 사용합니다.
`.scloudignore`는 `assets/quiz/*.json`을 명시적으로 포함합니다.

```sh
# todo 20에서 reviewed-v1.json을 승인·공급한 후 소유자가 실행:
scloud variable set BALMATCHUM_QUIZ_BANK_PATH ./assets/quiz/reviewed-v1.json --project balmatchum-prod
```

`configureQuizBank`(`server/lib/src/quiz/quiz_bank.dart:91`)가 시작 시 한 번 읽습니다.
새 팩은 `reviewed-v2.json`처럼 불변 파일명으로 공급하고 변경 문항의 `version`을 증가시킵니다.
새 코드·팩을 승인된 배포에 포함하고 변수도 해당 `./assets/quiz/reviewed-v2.json`로
바꾼 뒤 새 서버 프로세스로 검증합니다. 변수만 바꿔도 실행 중 팩이 hot reload되지는 않습니다.
기존 파일은 전환 중 제거하지 않습니다. 같은 `(questionId, version)` 내용 변경은
`Quiz revision identity conflict`이므로 파일만 롤백해도 등록된 개정을 덮어쓰지 못합니다.

장애 순서: 변수 누락/빈 팩이면 새 발급 `contentUnavailable` → 파일 누락이면 시작 시
FileSystemException → JSON/검토 필드 오류·testFixture 운영 사용이면 FormatException →
동일 개정 충돌과 DB migration 확인. 이미 본 모든 ID는 `exhausted`로 구분합니다.
업로드 목록 확인은 소유자 인증 후 `scloud deploy --wet-run --show-files`로 수행하며
`assets/quiz/reviewed-v1.json` 포함과 `config/passwords.yaml`, `test/` 제외를 확인합니다.

## 7. 알려진 운영 제약

- **Apple Android/web callback·서버 알림 미구현**: web server route를 mount하지 않았습니다(SOCIAL_AUTH_API.md). iOS 네이티브 로그인만 대상입니다.
- **Future call**: 결제 보관 기간 정리(`billing-retention-purge`, 매일 18:00 UTC)만 사용합니다. Starter 요금제에서는 future call이 비활성이라 서버 시작 때 1회 정리만 실행됩니다. 재시작이 드물면 만료분이 다음 재시작까지 남으므로 공개 출시 전 Growth 전환 후 예약 실행을 확인합니다(BILLING_API.md).

## 8. 상태 확인과 장애 대응

헬스 체크(Serverpod 4.0.3 API 서버 기본 라우트):

```sh
curl -fsS https://balmatchum-prod.api.serverpod.space/livez     # 프로세스 생존
curl -fsS https://balmatchum-prod.api.serverpod.space/readyz    # 요청 처리 가능(DB 포함)
curl -fsS https://balmatchum-prod.api.serverpod.space/startupz  # 초기화 완료
```

장애 확인 순서:

1. `scloud status deployment list`: 최근 배포가 `FAILURE`인지 확인합니다.
2. `scloud build log`: 빌드 단계 오류(`ERROR:`/`FAILED:`)를 확인합니다.
3. `scloud log --since 30m`: 런타임 오류를 확인합니다. 시작 실패 메시지는 `Invalid ... configuration`, `Failed to apply database migrations.`입니다.
4. `scloud password list`: 필수 그룹의 누락이나 일부만 설정된 그룹이 있는지 확인합니다(값은 표시되지 않음).
5. `/readyz` 실패: DB 상태를 확인합니다. 데이터 문제라면 5절의 복원을 판단합니다.
6. 세션 단위 추적은 Cloud console의 Insights를 사용합니다.

## 9. 출처

- https://docs.serverpod.dev/cloud
- https://docs.serverpod.dev/cloud/concepts/deployments
- https://docs.serverpod.dev/cloud/concepts/database
- https://docs.serverpod.dev/cloud/concepts/database-backups
- https://docs.serverpod.dev/cloud/concepts/passwords-secrets-env-vars
- https://docs.serverpod.dev/cloud/concepts/custom-domains
- https://docs.serverpod.dev/cloud/concepts/logs
- https://docs.serverpod.dev/cloud/reference/scloud-yaml-schema
- https://docs.serverpod.dev/cloud/reference/dart-sdk-versions
- https://docs.serverpod.dev/cloud/guides/ship-non-dart-files
- https://serverpod.dev/cloud (요금)
