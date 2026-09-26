# 발맞춤 서버

Serverpod **4.0.3**, Dart **3.13.4** 기반 최소 PostgreSQL 서버입니다. Flutter 팀 SDK는 FVM **3.47.5**입니다. 기본 greeting API·생성 클라이언트·초기 시스템 migration·CI를 포함합니다. 인증·Redis 서비스·웹·제품 기능·배포는 구성하지 않았습니다.

## 팀 문서

- [온보딩과 개발·검증·PR 절차](docs/onboarding.md)
- [실행 모드와 비밀값 관리](docs/configuration-secrets.md)
- [공식 출처·4.0.3 차이·실행 검증](docs/sources-and-verification.md)
- [에이전트 작업 규칙](AGENTS.md)
- [초기 설정과 경로 변경의 과거 기록](SETUP_REPORT.md)

## 저장소 경계

상위 `balmatchum/`은 Git 저장소가 아닙니다. 서버 저장소 루트는 `balmatchum/server/`이며 앱·디자인과 분리됩니다. 원격은 `https://github.com/beomq/balmatchum-server.git`입니다.

| 경로 | 역할 |
| --- | --- |
| `server/` | `balmatchum_server` 패키지, endpoint·모델·설정·migration·테스트 |
| `client/` | 독립 `balmatchum_client`, 앱 Git dependency의 고정 경로 |
| `.github/workflows/ci.yml` | develop/main push 및 PR 검증 |

`develop`에서 짧은 작업 브랜치 → PR·CI 검증 → `develop`을 따릅니다. `main`은 릴리스 PR·버전 태그 전용이며 미검증 기능은 develop에도 머지하지 않습니다. 릴리스 안정화가 다음 작업과 겹칠 때만 `release/*`를 선택합니다. Git·릴리스·배포 작업은 리드가 조정합니다.

개발은 외부 PostgreSQL(Compose), 테스트는 내장 PostgreSQL을 사용합니다. 시작 전 비밀값 문서를 확인하고 기존 개발 DB 비밀번호를 재사용합니다. 자동 QA 통과와 사용자 직접 확인은 별개입니다.
