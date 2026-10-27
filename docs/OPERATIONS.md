# 운영 배포 (Serverpod Cloud)

> 상태: **배포 전 초안**입니다. 실제 Cloud 프로젝트 생성·비밀값 설정·배포는 아직 하지 않았습니다.
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
| 앱 `SERVER_URL` | 사용자 지정 도메인 연결 전에는 `https://balmatchum-prod.api.serverpod.space/` |
| 사용자 지정 도메인 | Growth 요금제 이상(1개 포함). 예: `api.<도메인>` → `--target api` |

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
| 결제 Apple | `billingAppleBundleId`, `billingAppleIssuerId`, `billingAppleKeyId`, `billingApplePrivateKey`, `billingAppleEnvironment`, `billingAppleProducts` | 6개 모두 넣거나 모두 비움 |
| 결제 Google | `billingGooglePackageName`, `billingGoogleClientEmail`, `billingGoogleKeyId`, `billingGooglePrivateKey`, `billingGoogleEnvironment`, `billingGoogleProducts` | 6개 모두 넣거나 모두 비움 |
| AdMob SSV | `admobPlacements`, `admobSsvPort` | **Cloud에서는 설정하지 않음**(7절) |

일반 변수(평문, `scloud variable set`):

| 이름 | 값 |
| --- | --- |
| `BALMATCHUM_QUIZ_BANK_PATH` | `./assets/quiz/<승인된 팩>.json`. 파일은 `server/assets/quiz/`에 포함해 함께 배포 |
| `SERVERPOD_SESSION_LOG_CLEANUP_INTERVAL` / `_RETENTION_PERIOD` / `_RETENTION_COUNT` | 예: `24h` / `90d` / `100000`. 세 값을 모두 설정해야 로그 정리가 켜짐 |

비밀값은 한 그룹에서 일부만 넣으면 서버가 시작할 때 실패합니다(의도된 동작). 그룹은 전부 넣거나 전부 비웁니다. 비밀값과 password의 저장 한도는 프로젝트당 합계 64,000바이트입니다.

## 7. 알려진 운영 제약

- **AdMob SSV 수신 불가**: SSV listener는 `127.0.0.1:<admobSsvPort>`에만 bind하며 TLS reverse proxy를 전제로 합니다. Cloud는 api/web/insights 세 표면만 공개하므로 Google이 이 포트로 callback을 보낼 수 없습니다. 이 설계로는 `admobPlacements`/`admobSsvPort`를 설정하지 않아 기능을 꺼 둡니다. 이 경우 광고 보상 endpoint는 미설정 오류를 반환합니다. Cloud에서 쓰려면 SSV를 Serverpod web/api 라우트로 옮기는 별도 코드 작업이 필요합니다.
- **Apple Android/web callback·서버 알림 미구현**: web server route를 mount하지 않았습니다(SOCIAL_AUTH_API.md). iOS 네이티브 로그인만 대상입니다.
- **Future call**: 현재 코드는 future call을 쓰지 않습니다. Starter 요금제에서는 future call이 비활성입니다.

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
