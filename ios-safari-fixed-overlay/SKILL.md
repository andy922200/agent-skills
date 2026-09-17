---
name: ios-safari-fixed-overlay
description: >-
  在 iOS Safari 上除錯全螢幕 `position: fixed` 遮罩／Dialog／Modal／Drawer 出現「底部露出一小段沒被遮住」「畫面跑版但重新整理就恢復」時使用。常見觸發句式：「Safari 遮罩沒滿版」「iOS 上 Dialog 底部有縫」「遮罩沒蓋滿螢幕」「重新整理才正常」「桌機正常但手機 Safari 有問題」。這是 WebKit 層級的已知行為，不限特定框架或元件庫。
---

# ios-safari-fixed-overlay

## 症狀特徵

符合以下特徵即屬於這類 bug，不要當成一般 CSS 排版問題處理：

- 只在 **iOS Safari**（含 iOS 上的 Chrome/Edge，因為都用系統 WebKit）重現，桌面瀏覽器與 Android 正常。
- 只在**特定操作順序之後**才出現，不是一開啟頁面就有問題。
- **重新整理頁面就會恢復正常**——這是最關鍵的辨識線索，代表元素本身的 CSS 沒寫錯，是瀏覽器在某次重繪時用了過期的 viewport 尺寸。
- 缺口通常是**底部一小段或一條細縫**，不是整體位置偏移或大範圍跑版。
- 無法在 Chrome DevTools 的裝置模擬模式穩定重現，因為問題本質是 WebKit 對真實 visual viewport／瀏覽器工具列狀態變化的重繪時機，模擬器不會重現這個時序。

## 常見觸發情境與根因

同樣的「露出一小段」症狀可能來自三種不同根因，修法也不同。務必先問清楚**觸發前做了什麼操作**，再對應下表判斷：

| 情境 | 觸發操作 | 根因 |
| --- | --- | --- |
| A：鍵盤收合中開啟 | 先 focus 文字輸入框（跳出虛擬鍵盤）→ 緊接著開啟遮罩 | 遮罩在鍵盤收合動畫（約 250–300ms）尚未結束前就掛載，Safari 用尚未回復的 visual viewport 高度繪製 `fixed` 元素 |
| B：工具列狀態轉換 | 捲動頁面導致瀏覽器工具列（address bar）收合/展開，狀態轉換過程中開啟遮罩 | `fixed; bottom: 0`／`inset: 0` 依賴的「自動撐滿到視窗底部」行為，在工具列狀態於元素掛載**之後**才變化時不會重新計算 |
| C：頁面已捲動再開啟 | 頁面已捲動一段距離（例如載入更多內容、滾動瀏覽後）才開啟遮罩 | 多數第三方 Dialog/Modal 元件庫（Radix、reka-ui 等）的 scroll lock 只做 `overflow: hidden` + 攔截 `touchmove`，並未真正凍結頁面捲動位置；疊加工具列狀態轉換一樣會誤繪 |

三種情境可能同時混在同一個 bug 回報裡（使用者常常只描述「Safari 遮罩沒滿版」，不會主動說操作順序），**修好其中一種不代表全部解決**，收到「還是一樣」的回報時要先確認是否換了觸發路徑，而不是重複同一個修法。

## 已驗證無效／不足的嘗試（不要重試）

- **`nextTick()`（或任何框架的 render-flush 等待）**：只等前端框架把 reactive 狀態 patch 進 DOM，通常幾毫秒內 resolve，跟 WebKit 原生鍵盤/工具列動畫的時間尺度（250ms+）完全無關，不會等到動畫結束。
- **監聽 `window.visualViewport` 的 `resize` 事件，偵測「鍵盤是否還開著」後延後開啟遮罩**：只能涵蓋情境 A，涵蓋不到 B、C；且會對「當下沒有鍵盤」的情境誤判，得另外寫啟發式規則排除，複雜度換不到完整覆蓋率，不建議走這條路。

## 已驗證有效的修法

### 1. CSS：遮罩改用 `dvh`，不要依賴 `inset: 0` / `bottom: 0`

`dvh`（dynamic viewport height）是 CSS 專門為了讓瀏覽器工具列變化時持續即時反映而生的單位，Safari 對它的重繪比對 `fixed; bottom: 0` 的隱式撐滿可靠得多。

```css
/* 避免 */
.overlay { position: fixed; inset: 0; }

/* 改用 */
.overlay { position: fixed; top: 0; left: 0; right: 0; height: 100dvh; }
```

Tailwind 對應：把 `fixed inset-0` 改成 `fixed inset-x-0 top-0 h-dvh`。這一步解決情境 B。

### 2. JS：開啟遮罩時做 iOS 專屬的捲動凍結

單純 `overflow: hidden` 不夠，要讓頁面在視覺上完全靜止在原本捲動位置，才能避開「頁面已捲動 + 工具列轉換」的組合觸發（情境 C，連帶也讓情境 A 更穩定）：

```ts
// 開啟時
const scrollY = window.scrollY
document.body.style.position = 'fixed'
document.body.style.top = `-${scrollY}px`
document.body.style.width = '100%'

// 關閉時
document.body.style.position = ''
document.body.style.top = ''
document.body.style.width = ''
window.scrollTo(0, scrollY)
```

只在 iOS 裝置套用（避免不必要影響桌機/Android 的捲動行為），且應放在**共用的 Dialog/Modal 基礎元件層**（例如 Vue 專案中 `DialogRoot` 的包裝層），讓所有用到這個基礎元件的頁面自動受益，不要在各頁各自處理。

> 這是業界處理此類 iOS Safari fixed 定位 bug 的標準作法，多數成熟的 modal 元件庫最終都會補上這一段；如果專案用的第三方元件庫（如 Radix、reka-ui）本身的 scroll lock 只攔截 `touchmove`，代表它沒做這層凍結，仍需要自己補。

### 參考實作

本專案（Vue 3 + reka-ui + Tailwind）曾實際套用上述兩步：

- `app/src/components/ui/dialog/DialogOverlay.vue`：遮罩 class 由 `fixed inset-0` 改為 `fixed inset-x-0 top-0 h-dvh`。
- `app/src/components/ui/dialog/Dialog.vue`：在 `DialogRoot` 包裝層 `watch(() => props.open, ...)`，做上述 iOS 捲動凍結，只在 `isIosDevice()` 為真時執行。
- `app/src/lib/platform.ts`：`isIosDevice()` 判斷式（UA 比對 `iP(?:ad|hone|od)` 或 iPadOS 的 `maxTouchPoints > 2` + `Macintosh` UA）。

這是**範例**而非可直接複製貼上的通用檔案——不同專案要把邏輯放進自己對應的共用 Dialog/Modal 元件，且要用該專案的 UA／裝置偵測方式（例如已有 `@vueuse/core` 可考慮的 `isIOS`，但注意它是從 `@vueuse/shared` 匯出，`@vueuse/core` 的型別定義並未重新匯出，直接 import `@vueuse/shared` 屬於未宣告相依，建議自行寫等效判斷式，如本專案的 `isIosDevice()`）。

## 除錯建議

- **必須用真機 iOS Safari 實測**，無法用桌面模擬器穩定重現，也不要僅憑程式碼推論就回報「應該修好了」。
- 每次修改後收到「還是一樣」的回報時，追問**當下的操作順序**與**露出的具體位置**（例如「底部一條線」vs「整個畫面跳動/位置跑掉」），因為三種情境的根因與修法不同，同一句「還是一樣」可能代表換了另一種觸發路徑，不是前一版修法沒生效。
- 修好一種情境後，建議明確列出「這次修的是哪個情境」給使用者，方便他們針對性重現驗證，而不是每次都要求「整個流程重測一次」。
