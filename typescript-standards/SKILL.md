---
name: typescript-standards
description: >-
  新增、修改、重構、除錯、測試或審查 TypeScript 程式時使用，提供型別安全、函式介面、可設定值與命名規範。可與框架或領域專屬 Skill 一起套用；不取代其框架專屬要求。
---

# typescript-standards

## 型別安全

- 一律使用 **TypeScript**，並啟用 strict mode。
- 禁止顯性與隱性 `any`。外部或不可信任資料先以 `unknown` 接收，再透過 type guard、schema 或明確驗證縮限型別。
- 函式輸入、回傳值與公開資料邊界都要有明確型別。
- 需要使用 `as` 型別斷言前，先告知使用者原因與替代方案；不得為了壓過 lint 或型別錯誤而靜默加入斷言，也不得使用雙重斷言（例如 `as unknown as T`）隱藏問題。
- 不使用 `.js`、`.jsx` 或 `.cjs`。只有工具鏈確實要求 JavaScript 時才允許 `.mjs`。

## 型別匯入

- 同時匯入值與型別時，使用 inline `type` 標記寫在同一行（例如 `import { type Ref, ref } from 'vue'`），不拆成兩條 import。實務上該行經編譯後，`type` 標記的 specifier 會被完整移除，拆成兩行對打包結果沒有實質差異，只會徒增行數。
- 若該檔案完全不需要來源模組的實體（值）匯出，只使用其型別，改用頂層型別匯入（例如 `import type { Ref } from 'vue'`），不要用 inline `type` 寫法。

## 函式介面與可設定值

- 函式需要傳遞超過 3 個值時，改用具明確型別的 options 物件傳參，讓呼叫端能辨識各值的語意；3 個以下的位置參數可依可讀性使用。
- `MAX_COLLECTION_SUGGESTIONS`、`MAX_WATCH_SUGGESTIONS` 等可由使用者調整的數值，不得只寫成不可覆寫的內部常數；應由外部透過 Props、options 或設定介面傳入，並在元件、函式或 Composable 內提供合理預設值。

## Composable 狀態與操作

- 多個互動元件若僅共享同一個事件（例如 `resize`），但各自的開啟／關閉狀態彼此獨立，Composable 的每次呼叫應只管理一個元件狀態；不要將多個元件 state 陣列傳入單一 instance 集中管理。
- Composable 應以具型別的物件同時公開狀態與可操作方法（例如 `{ isOpen, close }`），讓呼叫端能綁定狀態，並在事件以外的情境明確執行操作；不要只回傳裸 `Ref`。

## 命名

| 類型 | 規則 | 範例 |
| --- | --- | --- |
| Helper / 函式 / 區域變數 | camelCase | `getApiError.ts`、`formatPrice` |
| Enum、共用常數物件 | PascalCase | `OrderStatus`、`ApiRoutes` |
| 不可變純量常數 | UPPER_CASE | `DEFAULT_PAGE_SIZE` |

## 避免事項

- 使用 `any`、未告知的 `as`、雙重型別斷言，或以斷言掩蓋資料問題。
- 函式傳遞超過 3 個位置參數，或將可由使用者調整的數值寫成不可覆寫的內部常數。
- 新增 `.js`、`.jsx`、`.cjs` 檔案。

## 完成前檢查

- [ ] TypeScript strict，且沒有 `any`、未告知的 `as` 或非 `.mjs` JavaScript
- [ ] 函式輸入、回傳值與公開資料邊界都有明確型別
- [ ] 函式超過 3 個傳入值時使用具型別的 options 物件；可由使用者調整的數值由外部傳入，並有合理預設值
- [ ] Helper、函式、區域變數與常數符合命名規則
- [ ] 型別匯入依規則使用 inline `type`（同時匯入值與型別）或頂層 `import type`（只使用型別）
