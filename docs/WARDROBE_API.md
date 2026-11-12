# 옷장 API (아이템 · 세트 · 매달 구독 선물)

엔드포인트 `wardrobe` (로그인 필요). 모든 쓰기는 `requestId`를 받고, 같은 `requestId`로 다시 보내면 처음 결과를 그대로 돌려준다(다른 내용이면 `idempotencyConflict`). 모든 메서드는 전체 상태 `WardrobeStore`를 돌려준다. 홈 화면은 `product.getHomeSnapshot`의 `wardrobe` 필드로 같은 상태를 받는다.

## 가격과 규칙 (주인님 결정 2026-11-12)
- 아이템은 **색 하나가 한 상품**이다. 색마다 150P. 배경 100P(`sunny`는 무료·기본 보유). 걸음 포인트로만 산다.
- 세트 값 = 그 색으로 **아직 없는 부분**(옷 + 세트 배경)의 합에서 20% 할인, `합 * 80 ~/ 100`. 다 가졌으면 살 수 없고 "세트로 입히기"만 한다.
- **세트 완성** = 세트의 옷을 모두 **같은 색으로** 입고, 배경이 **그 세트 배경**일 때만. 서버가 `completeSetId`, `completeColour`로 알려 준다. 앱은 이때만 세트 이름표와 효과를 그린다.
- 원장 키: 아이템 `outfit:<item>:<colour>`, 배경 `theme:<background>`, 세트 `set:<set>:<colour>`. 정책 버전 `wardrobe-purchase-v1-20261112`(잔액에 포함). 개발 fixture DB에서는 기존처럼 fixture 잔액을 쓴다.

## 카탈로그 (`lib/src/wardrobe/wardrobe_catalog.dart`)
| 세트 | 아이템 | 배경 | 색 | 효과 | 포인트 판매 |
|---|---|---|---|---|---|
| `winter` 겨울 세트 | `padding`, `beanie`, `booties` | `winter-dusk` | tomato pine plum navy | `snow` | 늘 판매 |
| `holiday` 크리스마스 세트 | `rudolph-band`, `santa-cape` | `holiday-night` | tomato pine navy | `holiday` | 선물 전용 |
| `seollal` 설날 세트 | `saekdong-jeogori`, `gulle` | `seollal-morning` | dahong jjok yeondu bunhong | `seollal` | 선물 전용 |

- 조끼(`vest`, 색 `classic`)는 시추·닥스훈트 단품 아이템이다(그림이 그 둘뿐). 예전 `vest-low-v` 보유·착용은 마이그레이션이 `vest/classic`으로 옮겼다.
- 입을 수 있는 견종: 겹쳐 입는 그림이 있는 말티즈·닥스훈트·골든 리트리버는 모든 아이템과 색. 나머지 27견종은 **토마토 패딩만**(강아지 전체에 구운 그림이라 다른 아이템과 같이 입지 않음). 그 견종에게 다른 아이템은 `wearableColours`가 비어 있다(앱: "곧 입을 수 있어요").
- 슬롯: `feet`, `torso`, `head`. 한 슬롯에 하나. 배경은 `product_account.equippedTheme`(기존 테마와 같은 칸).

## 매달 구독 선물 (주인님 결정 2026-11-12: 월 구독이 있으니 매달)
- 한국 시간 달력 달마다 선물이 하나(세트 하나 또는 아이템 하나) 있을 수 있다. 카탈로그 `gifts`의 `yyyy-MM` → `MonthlyGift.set(...)` / `MonthlyGift.item(...)`. 선물이 없는 달은 아무것도 주지 않는다.
- 지금 정한 달: **2026-12 크리스마스 세트, 2027-01 겨울 세트, 2027-02 설날 세트**(2027 설날 2월 7일). 나머지 달은 그림이 준비되면 채운다.
- 대상: 그 달에 **구독 또는 평생 이용권이 활성**(서버에 저장된 마지막 결제 관측 기준)인 사용자. 평생 이용권은 만료가 없어 계속 받는다. 취소된 결제는 받지 않는다.
- 받는 것: 세트면 모든 아이템 × 모든 색 + 세트 배경, 아이템이면 그 아이템의 모든 색. 포인트 원장에는 아무것도 쓰지 않고, 보유 줄의 `source`는 `subscription`, `gift_grant`에 (사용자, 달) 한 줄을 남긴다(고유키라 두 번 주지 않음).
  - 그 달 1일 0시(KST)부터 주기 작업(`grantMonthlyGifts`, 1시간마다, 서버 시작 때도 한 번)이 활성 회원에게 준다. 다시 돌려도 한 번만 준다.
  - 그 달 안에 회원이 되면(`billing.verifyPurchase` / `restorePurchase` / `getEntitlement`) 바로 준다. 이 쓰기가 실패해도 결제 확인 응답은 그대로 돌려주고, 빠진 선물은 주기 작업이 준다. 회원이 `purchaseSet` / `purchaseItem`을 불러도 결제 없이 받는다(이미 받았으면 아무것도 바꾸지 않음).
- 구독을 끊어도 받은 선물은 계속 가지고 입는다(착용은 구독을 확인하지 않는다).
- 지난달 선물은 나중에 회원이 된 사람에게 주지 않는다.
- 그림은 앱에 미리 실어 두고, 선물 전용 세트는 그 달 전에는 응답에서 뺀다. 그 달에는 모두에게 보이고 비회원은 입어 볼 수만 있다(`purchaseSet`은 `subscriptionRequired`). 달이 지나면 가진 사람에게만 보인다.
- 지난 선물의 한정 판매: `MonthlyGift.set('holiday', resale: Window(opensAt, endsAt))`처럼 채워 서버를 배포한다(앱 업데이트 불필요). 그 기간에는 보통 세트처럼 색마다 포인트로 판다.
- 겨울 세트는 늘 포인트로 팔면서 2027년 1월 선물이기도 하다(1월 회원은 모든 색을 받음).

## 메서드
| 메서드 | 하는 일 | 오류 코드 |
|---|---|---|
| `getWardrobe()` | 상태 읽기 | |
| `purchaseItem(itemId, colourId, requestId)` | 아이템 한 색 150P | `unknownOutfit`, `setOnly`(선물 전용 아이템), `subscriptionRequired`(이달 선물 아이템), `outfitIncompatible`, `insufficientPoints` |
| `purchaseBackground(backgroundId, requestId)` | 배경 100P | `unknownTheme`, `setOnly`(선물 전용 세트의 배경), `insufficientPoints` |
| `purchaseSet(setId, colourId, requestId)` | 없는 부분만 20% 할인으로 한 번에 | `unknownSet`, `subscriptionRequired`, `outfitIncompatible`, `setNotPurchasable`, `insufficientPoints` |
| `equipItem(itemId, colourId, requestId)` | 그 슬롯을 바꿈 | `unknownOutfit`, `outfitNotOwned`, `outfitIncompatible` |
| `unequipSlot(slot, requestId)` | 슬롯 비우기 | |
| `equipBackground(backgroundId, requestId)` | 배경 바꾸기 | `unknownTheme`, `themeNotOwned` |
| `equipSet(setId, colourId, requestId)` | 세트 옷 전부 + 세트 배경 | `unknownSet`, `outfitNotOwned`, `outfitIncompatible`, `themeNotOwned` |
| `unequipSet(setId, requestId)` | 입은 세트 옷만 벗기기(배경은 그대로) | `unknownSet` |

이미 가진 것을 다시 사면 아무것도 쓰지 않고 상태만 돌려준다(아이템·배경).

## `WardrobeStore`
- `colours[]`: `colourId`, `name`, `swatch`(ARGB).
- `items[]`: `itemId`, `slot`, `name`, `price`, `colours`, `ownedColours`, `wearableColours`(이 견종이 입을 수 있는 색), `sellable`(false = 선물로만), `setIds`, `gift?`(아이템 자체가 매달 선물일 때).
- `backgrounds[]`: `backgroundId`, `name`, `price`, `owned`, `sellable`, `setId?`.
- `sets[]`: `setId`, `name`, `itemIds`, `backgroundId`, `effect`(앱 `effects/presets.json`의 프리셋 이름), `fullPrice`, `discountPct`, `sellable`, `colours[]`(`colourId`, `price`(내 보유 기준, 다 가졌으면 0), `missingParts`, `purchasable`, `wearable`), `season?`(그 세트가 선물인 달: `month`, `releaseAt`, `endsAt`, `open`, `granted`, `resaleOpen`, `resaleEndsAt?`).
- `equipped[]`: `slot`, `itemId`, `colourId`. `equippedBackground`.
- `completeSetId?`, `completeColour?`, `breedId?`, `balance`, `subscriber`, `fixtureLabel?`.

## 테이블
- `outfit_ownership`: `colourId`(기본 `classic`), `source`(`purchase` | `subscription` | `migration`) 추가, 고유키 (사용자, 아이템, 색).
- `theme_ownership`: `source` 추가.
- 새 `outfit_equip` (사용자, 슬롯 고유), 새 `gift_grant` (사용자, 달 고유). 계정 삭제가 둘 다 지운다.
- 마이그레이션 `20261112144718024-wardrobe-sets`: `vest-low-v` → `vest/classic`(`source = migration`, 둘 다 가진 사용자는 옛 줄을 먼저 지움), `equippedOutfit` → `outfit_equip`(torso), `equippedOutfit` 비움. 원장의 옛 키는 그대로.

예전 `product.listOutfits` / `purchaseOutfit` / `equipOutfit` / `unequipOutfit`는 옛 앱을 위해 남겨 두었고 조끼(`vest-low-v` = `vest/classic`)만 다룬다. 예전 `product.purchaseTheme`의 가격도 그대로다. 새 앱은 `wardrobe`만 쓴다.
