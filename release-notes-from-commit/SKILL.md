---
name: release-notes-from-commit
description: >-
  依指定的單一 Git commit 撰寫 Release notes 時使用。適用於使用者提供 commit SHA，或要求從特定歷史提交整理版本說明；不適用於依 tag 範圍、PR 清單或多個 commits 產生 changelog。開始前必須先確認撰寫語言，並確認該 commit 是範圍單一、可獨立 cherry-pick 的發布單位；否則先詢問目的。
---

# release-notes-from-commit

## 必要前置條件

依下列順序執行，完成前不得開始撰寫 Release notes：

1. 先確認使用者要使用的語言。若同一個請求已明確指定語言，直接採用；否則先詢問，不得從 repository 文件語言、使用者介面或 commit message 自行推定。
2. 確認唯一的目標 commit。若沒有明確 commit reference，先請使用者提供或指定。
3. 將 reference 解析成完整 SHA，並以該 commit 的父提交為基準檢查 metadata、檔案清單與完整 diff。不得用目前工作區內容代替該 commit 的內容。
4. 確認該 commit 是範圍單一、語意完整，可作為獨立 cherry-pick 與發布說明的單位。

只有同時符合下列條件，才可直接產生 Release notes：

- 是具有單一父提交的普通 commit，不是 merge commit。
- 所有變更共同服務一個可明確描述的目的，沒有混入無關功能、重構、文件或資料修改。
- commit 本身包含完成該目的所需的實作與必要契約變更，沒有明顯依賴未包含或未指出的前置提交。
- 可以只根據 commit 內可觀察到的事實完整描述，不需要猜測發布範圍或自行挑選部分變更。

Git 能執行 `cherry-pick` 不代表該變更可獨立發布；仍須判斷它在語意上是否完整且範圍單一。

若任一條件不成立或無法確認，停止產生 Notes，指出具體疑點並先詢問使用者目的。例如：

> 這個 commit 同時包含前端功能與資料契約變更，無法確認是否要視為同一個發布單位。你希望描述整個 commit、只整理其中一部分，還是先拆成可獨立 cherry-pick 的 commits？

在使用者回答前，不得自行排除檔案、改用相鄰 commits、拆 commit，或把混合變更包裝成單一版本目的。

## 分析與撰寫

以指定 commit 為唯一事實來源，至少檢查：

```bash
git show --no-ext-diff --format=fuller --stat <commit>
git diff --no-ext-diff --find-renames <commit>^ <commit>
```

依實際差異整理：

- 版本目的與使用者可感知的結果。
- 重要的新功能、修正或契約變更。
- 相容性、破壞性差異與必要遷移方式；沒有證據時省略，不得推測。
- 已由該 commit 或使用者提供資訊證實的驗證結果；不得把未執行的測試寫成已通過。
- 完整 commit SHA；需要線上連結時，先確認 repository URL。

依使用者指定的語言撰寫。內容以版本影響為主，不逐檔複述 diff，也不加入 commit 無法支持的動機、日期、issue、相容性承諾或效能結論。

## 輸出與權限邊界

若使用者沒有指定格式，輸出可直接貼入 GitHub Release 的 Markdown；依內容需要包含摘要、重要變更、相容性／破壞性差異與來源 commit，沒有實質內容的段落不要硬加。

產生 Release notes 不代表已授權建立 tag、發布 GitHub Release、上傳附件、推送分支或修改 commit。只有使用者明確要求這些操作時才執行，並在操作前再次核對目標 repository、tag 與 commit。
