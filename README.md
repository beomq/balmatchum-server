# 발맞춤 서버

Serverpod **4.0.3**, Dart **3.13.4** 기반 최소 서버입니다. API 연결 확인용 기본 `greeting.hello`와 초기 Serverpod 시스템 테이블 마이그레이션만 포함합니다. 서비스 기능·인증·Redis·웹사이트·Flutter 앱은 포함하지 않습니다.

Serverpod 자체 전이 의존성으로 lockfile에 `redis`가 있고 기본 시스템 마이그레이션에 저장소 관련 테이블이 있지만 Redis 서비스나 cloud storage provider는 설정하지 않았습니다. `serviceSecret`을 제공하지 않으므로 Insights는 비활성화 경고가 발생하며 API는 정상 동작합니다.

## 고정 패키지 경로

- 서버: `balmatchum/balmatchum_server`
- 독립 생성 클라이언트: **`balmatchum/balmatchum_client`**
- CI: `.github/workflows/ci.yml`

클라이언트는 Pub workspace에 묶여 있지 않아 별도 Dart/Flutter 프로젝트의 Git dependency로 사용할 수 있습니다. 원격은 `https://github.com/beomq/balmatchum-server.git`이며 앱 담당자가 검증된 커밋 SHA와 위 클라이언트 경로를 지정합니다. 초기 설정 단계에서는 커밋·푸시하지 않습니다.

## 로컬 준비

저장소 루트에서 실행합니다. 현재 Mac에 설치된 전용 SDK/cache 설정입니다.

```sh
export PATH="/Users/beomseok/fvm/versions/3.47.5/bin/cache/dart-sdk/bin:$PATH"
export PUB_CACHE="/Users/beomseok/fvm/versions/3.47.5/.balmatchum-pub-cache"
dart --version
dart pub global activate serverpod_cli 4.0.3
(cd balmatchum/balmatchum_server && dart pub get --enforce-lockfile)
(cd balmatchum/balmatchum_client && dart pub get --enforce-lockfile)
```

## PostgreSQL과 실행

개발 DB는 Docker Compose의 PostgreSQL 16이며 로컬 `127.0.0.1:8090`에만 노출합니다. 비밀번호는 저장소에 넣지 않고 같은 셸의 환경변수로 전달합니다.

```sh
cd balmatchum/balmatchum_server
export SERVERPOD_PASSWORD_database="$(openssl rand -hex 24)"
docker compose up -d --wait
dart run bin/main.dart --apply-migrations
```

DB 볼륨을 재사용할 때는 처음 설정한 비밀번호를 안전한 로컬 저장소에서 다시 전달해야 합니다. 매번 새 비밀번호를 만들면 기존 DB 인증이 실패합니다. 종료는 서버 `Ctrl-C`, DB는 `docker compose down`을 사용합니다. `down -v`는 데이터를 지우므로 일상 종료에 사용하지 않습니다.

다른 터미널에서 같은 SDK 설정 후 실제 생성 클라이언트 연결을 검증합니다.

```sh
cd balmatchum/balmatchum_client
dart run example/smoke.dart http://localhost:8080/
```

정상이면 `CLIENT_SMOKE_OK`가 출력됩니다.

## 코드 생성과 검증

엔드포인트/모델을 변경하면 서버 패키지에서 실행합니다.

```sh
dart pub global run serverpod_cli:serverpod_cli --no-interactive --no-analytics generate
# 저장 모델을 바꾼 경우에만:
dart pub global run serverpod_cli:serverpod_cli --no-interactive --no-analytics create-migration
```

저장소 루트의 기본 검증 명령입니다.

```sh
dart format --output=none --set-exit-if-changed balmatchum/balmatchum_server balmatchum/balmatchum_client
(cd balmatchum/balmatchum_server && dart analyze --fatal-infos)
(cd balmatchum/balmatchum_client && dart analyze --fatal-infos)
(cd balmatchum/balmatchum_server && SERVERPOD_PASSWORD_database=local-disposable-test-only dart test)
(cd balmatchum/balmatchum_server && dart build cli --target bin/main.dart --output build)
```

테스트는 `config/test.yaml`의 `database.dataPath`를 이용하는 **내장 PostgreSQL**입니다. 테스트 그룹마다 임시 DB를 생성하고 정리하므로 개발 DB 및 Docker와 분리됩니다. 최초 실행에는 PostgreSQL 바이너리 다운로드가 필요합니다. `SELECT 1` 연결 검증과 기본 endpoint 테스트를 실행합니다. 생성 헬퍼의 기본 테스트 제한시간은 120초입니다.

CI는 Dart 3.13.4와 CLI 4.0.3을 고정하고 lockfile 설치, 생성 코드 drift 및 미추적 생성 파일 확인, 양쪽 패키지 format/analyze, 격리 PostgreSQL 테스트, 서버 실행 파일 컴파일을 수행합니다. CI의 공개 비밀번호는 외부 서비스에 사용하지 않는 일회성 테스트 전용 값입니다.

## 문제 확인 순서와 범위

1. `dart --version`, `PUB_CACHE`, CLI 버전을 확인합니다. 명령은 `dart pub global run serverpod_cli:serverpod_cli`입니다.
2. 개발 DB 오류라면 `docker info`, `docker compose ps`, 포트 8090 및 초기 비밀번호를 확인합니다.
3. 테스트가 로딩 직후 종료되면 `SERVERPOD_PASSWORD_database`를 먼저 확인합니다. 테스트 헬퍼는 생성자 오류 출력을 숨깁니다. 이후 바이너리 다운로드 네트워크, OS 지원, `.serverpod/test` 권한을 확인합니다. 개발 Docker를 켜는 것으로 해결되지 않습니다.
4. 생성 오류라면 두 패키지의 `dart pub get` 후 서버의 `config/generator.yaml`을 확인합니다.

운영/스테이징 설정, 배포 파이프라인, 인증 및 업무 모델은 아직 없습니다. 로컬 자동 검증과 사용자 직접 확인, 실제 GitHub CI 실행은 별개입니다. 초기 원격 CI는 커밋/푸시 승인 후 확인해야 합니다.

근거: [Serverpod 공식 문서](https://docs.serverpod.dev/), 설치된 `serverpod_cli` 4.0.3의 `create --help` 및 생성 테스트 헬퍼. 프로젝트 생성에는 `--no-interactive create balmatchum --template server --database --no-redis --no-auth --no-webapp --no-website --ide none`을 사용했고, 서버 전용 독립 패키지로 정리했습니다.
