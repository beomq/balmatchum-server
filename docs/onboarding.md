# 서버 팀 온보딩

## 먼저 이해할 흐름

앱의 생성 `Client` → HTTP API → 서버 endpoint → PostgreSQL 순서입니다. 서버의 `.spy.yaml` 모델과 endpoint에서 Dart 서버 코드·클라이언트·테스트 헬퍼를 생성합니다. `generate`는 Dart 계약을 만들고, migration은 DB 스키마를 변경합니다. 둘은 서로 대신할 수 없습니다.

로컬 상위 `balmatchum/`은 Git 저장소가 아닙니다. 이 저장소는 `balmatchum/server/`, 앱은 별도 `balmatchum/app/`입니다. 여기서 `server/`는 `balmatchum_server`, `client/`는 `balmatchum_client` 패키지입니다. 아래 명령의 시작 위치는 **서버 저장소 루트**입니다.

## 도구와 첫 검증

현재 초기 세팅의 새 폴더 구조는 `chore/project-layout`에 있고 `develop` 반영은 아직 대기 중입니다. 지금 검토하려는 팀원은 아래처럼 해당 브랜치를 명시합니다. PR 병합 후 일반 온보딩 기준은 `develop`으로 바꿉니다. 이미 checkout이 있으면 clone을 반복하지 않습니다.

```sh
git clone --branch chore/project-layout https://github.com/beomq/balmatchum-server.git server
cd server
git status --short
```

로컬 폴더 이름은 자유롭게 선택할 수 있습니다. 형제 앱 저장소나 상위 작업 공간 문서는 설치 선행 조건이 아닙니다.

Dart **3.13.4**, Serverpod/CLI **4.0.3**을 사용합니다. 팀 Flutter SDK는 FVM의 **3.47.5**입니다. 서버 명령에는 Flutter 자체가 필요하지 않습니다. 해당 SDK의 Dart를 PATH에 선택하거나 독립 Dart 3.13.4를 설치한 후 버전을 확인합니다. FVM을 사용하는 개발자는 자신이 설정한 FVM 프로젝트에서 `fvm dart --version`으로 확인하고 같은 SDK로 아래 명령을 실행합니다. 이 서버 저장소에 앱의 FVM 설정을 복사하거나 개인 SDK 절대 경로를 문서에 넣지 않습니다.

```sh
dart --version
dart pub global activate serverpod_cli 4.0.3
dart pub global run serverpod_cli:serverpod_cli --version
(cd server && dart pub get --enforce-lockfile)
(cd client && dart pub get --enforce-lockfile)
(cd server && dart pub global run serverpod_cli:serverpod_cli --no-interactive --no-analytics generate)
dart format --output=none --set-exit-if-changed server client
(cd server && dart analyze --fatal-infos)
(cd client && dart analyze --fatal-infos)
(cd server && SERVERPOD_PASSWORD_database=local-disposable-test-only dart test --reporter expanded)
(cd server && dart build cli --target bin/main.dart --output build)
```

코드 생성 drift 검사(CI와 동일):

```sh
git diff --exit-code -- server/lib/src/generated server/test/integration/test_tools client/lib
test -z "$(git ls-files --others --exclude-standard -- server/lib/src/generated server/test/integration/test_tools client/lib)"
```

최초 설치는 네트워크가 필요합니다. `PUB_CACHE`를 별도로 쓰고 싶다면 자신의 쓰기 가능한 디렉터리를 선택하고 CLI 설치와 모든 명령에 동일하게 적용합니다. 기본 캐시도 지원하며 특정 사용자의 홈 경로는 요구하지 않습니다. 셸 예시는 POSIX 셸 기준입니다.

테스트는 Docker가 아닌 `server/config/test.yaml`의 내장 PostgreSQL을 사용합니다. 그룹마다 임시 DB를 만들고 정리합니다. 기대 결과는 테스트 2개 통과입니다. 빌드는 네이티브 SQLite 전이 의존성의 hooks를 실행하므로 `dart compile exe` 대신 `dart build cli`를 사용합니다. DB를 PostgreSQL로 선택해도 이 전이 의존성은 존재합니다.

## 개발 서버 실행

먼저 [설정·비밀값 관리](configuration-secrets.md)를 읽고 `SERVERPOD_PASSWORD_database`에 **기존 개발 DB의 비밀번호**를 주입합니다. 아래 검사는 값을 출력하지 않습니다.

```sh
cd server
: "${SERVERPOD_PASSWORD_database:?개발 DB 비밀번호를 먼저 주입하세요}"
docker info
docker compose config --quiet
docker compose up -d --wait
dart run bin/main.dart --mode=development --apply-migrations
```

다른 터미널에서 저장소 루트 기준:

```sh
cd client
dart run example/smoke.dart http://localhost:8080/
```

정상이면 `CLIENT_SMOKE_OK`입니다. 서버는 Ctrl-C, DB는 서버 패키지에서 `docker compose down`으로 종료합니다. 데이터 보존이 기본이며 `down -v`는 사용하지 않습니다. Docker 데몬이 꺼져 있으면 개발 서버의 DB 검증은 불가능하지만 내장 PostgreSQL 테스트는 별도로 실행할 수 있습니다.

## 변경·리뷰 규칙

1. `develop`에서 짧은 작업 브랜치를 만듭니다. 작업 범위를 합의한 뒤 PR·CI 검증을 거쳐 `develop`에 통합합니다. 고장 나거나 미검증된 기능을 먼저 머지하지 않습니다.
2. endpoint 또는 모델 변경 후 서버 패키지에서 `generate`를 실행합니다. `server/lib/src/generated/`, `server/test/integration/test_tools/`, `client/lib/src/`를 직접 수정하지 않습니다.
3. 저장 모델 변경이 있을 때만 아래 명령으로 migration을 생성하고 SQL·기존 데이터 영향을 리뷰합니다. 업무 모델 변경이 없는 문서 작업에서는 생성하지 않습니다.

   ```sh
   cd server
   dart pub global run serverpod_cli:serverpod_cli --no-interactive --no-analytics generate
   dart pub global run serverpod_cli:serverpod_cli --no-interactive --no-analytics create-migration
   # 로컬 개발 DB 적용: 기존 비밀번호와 실행 모드 확인 후
   dart run bin/main.dart --mode=development --apply-migrations
   ```

4. 기존 적용 migration을 지우거나 다시 쓰지 않습니다. `--force`/repair는 일상 해결책이 아닙니다. 데이터 손실 경고를 확인하고 리드와 대응을 정합니다. 역방향 자동 롤백이 보장된다고 가정하지 않습니다.
5. 서버 담당자가 계약·생성 client·테스트·migration·lockfile을 같은 검증 단위로 관리합니다. 앱 담당자는 서버 저장소 Git dependency의 **`path: client`와 검증된 commit SHA**를 pin합니다. 이동 전 커밋의 경로와 혼합하지 않습니다. 공개 배포용 client 버전 정책은 아직 없으며 앱 pin 변경은 앱 담당 영역입니다.
6. PR에 변경 이유, 실행 명령/종료 코드, DB 영향, 미검증 사항을 씁니다. `main`은 릴리스 PR·버전 태그 전용입니다. 안정화와 다음 작업이 겹칠 때만 `release/*`를 선택합니다. 커밋·푸시·PR·머지·태그·원격 보호·배포는 리드 조정과 명시적 작업 지시가 필요합니다.

현재 범위는 초기화·CI입니다. 기능 공개 예약/feature flags, 최소 버전 강제 업데이트, Sentry, Fastlane은 논의 후보이며 설치·구현 대상이 아닙니다.

## 실패 시 확인 순서

- 생성 실패: Dart/CLI 버전 → 두 패키지 의존성 → `server/config/generator.yaml`의 `../client`.
- 테스트가 로딩 직후 종료: 비밀번호 환경변수 → 실제 서버 오류 출력. 4.0.3 테스트 헬퍼는 생성자 출력을 숨길 수 있습니다.
- 개발 DB 연결 실패: Docker → 포트 8090 → 기존 볼륨 비밀번호 → 실행 모드.
- 내장 DB 실패: 최초 바이너리 다운로드 네트워크 → `.serverpod/test` 권한. 개발 Docker와 별개입니다.

[공식 근거·버전 차이·검증 기록](sources-and-verification.md)을 함께 확인합니다. 자동 검증 성공과 사용자 직접 실행·이해 확인은 별개입니다.
