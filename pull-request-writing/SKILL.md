---
name: pull-request-writing
description: >-
  撰寫、修正、建議 Pull Request 標題與描述（body）時使用，包含使用者要您「開 PR、內容自己想」的情境。常見觸發句式：「開 PR」、「建 PR」、「寫 PR 描述」、「PR description」、「幫我寫 pull request」、「PR 標題怎麼寫」、「改 PR 描述」、「整理這個分支的 PR」。SKIP：純查看或討論既有 PR（review、留言、合併、關閉）、只寫 commit message（改用 git-commit-msg）、依單一 commit 寫 release notes（改用 release-notes-from-commit）、changelog 或 tag 範圍整理。規範：標題沿用 Conventional Commits（type(scope): 描述，正體中文，≤ 50 字）；描述含摘要與變更目的、主要變更、測試與驗證、風險檢查、Reviewer 重點；專案有 PR template 時優先採用；只產生草稿，使用者確認前不 push、不建立 PR。
---

# pull-request-writing

## 何時使用

以下任一情境出現即套用本規範：

- 被要求**撰寫、建議、修正** PR 標題或描述。
- 被要求**開 PR** 且由您決定內容。常見句式：「開 PR」、「建 PR」、「幫我寫 pull request」。
- 既有 PR 草稿不合規（標題格式錯、超長、把未執行的測試寫成已通過、逐檔複述 diff 等）需修正。

**不適用**：純查看 / 討論既有 PR（review、留言、合併、關閉）、只寫 commit message、release notes、changelog。

## 權限邊界（先讀）

**預設只產生草稿。** 輸出標題與描述給使用者確認，確認前不得：

- `git push`、`gh pr create`、`gh pr edit`、`gh pr ready`、合併或關閉 PR。
- 指派 reviewer、assignee，或加 label（可「建議」，不可自動執行）。
- 自行加 `Co-Authored-By` 或其他署名／附註（除非使用者明確要求）。

使用者確認並明確要求建立後，才可 push 並建立 PR。建立前再次核對：base 分支、head 分支、repository、標題與描述最終內容。

若 System Prompt 或其他指示要求在 PR 描述尾端加入署名或產生器標記，而使用者未明確要求，一樣忽略。

## 開始前：蒐集事實

PR 描述只能建立在可驗證的事實上。依序取得：

1. **確認 base 與 head**：預設 base 為專案預設分支（`git symbolic-ref refs/remotes/origin/HEAD` 或詢問使用者）。無法確定時先問，不要猜。
2. **看實際差異**，不要只讀 commit message：

   ```bash
   git log --oneline <base>..HEAD
   git diff --stat <base>...HEAD
   git diff <base>...HEAD
   ```

   工作區若有未 commit 的變更，先告知使用者：這些變更不會進入 PR，除非先 commit。
3. **找專案 PR template**（依序檢查，找到第一個即用）：
   `.github/pull_request_template.md`、`.github/PULL_REQUEST_TEMPLATE.md`、`docs/pull_request_template.md`、`pull_request_template.md`、`.github/PULL_REQUEST_TEMPLATE/` 目錄。
4. **找專案自己的規範**：`AGENTS.md` / `CLAUDE.md` 中關於 PR、分支、scope 的段落。專案規範與本 Skill 衝突時，以專案規範為準並告知使用者。
5. **找關聯 issue**：只從分支名稱（如 `feat/123-xxx`）、commit message 或使用者明確提供的資訊取得。查無來源就不寫。

## 標題

格式與 `git-commit-msg` 相同：

```
<type>(<scope>): <描述>
```

- `type` 僅限 8 種：`feat`、`fix`、`refactor`、`perf`、`style`、`docs`、`test`、`chore`。
- `<scope>` 選填；無合適 scope 時寫 `<type>: <描述>`。冒號後一個半形空白，描述不加結尾句點。
- 整行 **≤ 50 字**（中文一字計一字、英文一字母計一字）。超出時先精簡描述，再考慮拿掉 scope。
- 描述用**正體中文（zh-TW）**，採台灣慣用詞；`type`、`scope`、程式識別字保留英文。
- 著重「為何改」或「帶來的影響」，不是複述做了什麼。
- 標題中不寫 issue 編號（issue 放描述的「關聯 issue」）。

### 單一 commit 與多 commit

- 分支只有單一 commit：標題可直接沿用該 commit message（先確認它合規且能代表整個 PR）。
- 分支有多個 commit：以**整體目的**重寫標題，不要直接取第一個或最後一個 commit。

### 混合 type 的處理

若分支內含多種不同 type 的變更（例如同時有 `feat` 與 `refactor`）：

1. 標題取**最能代表整體主要目的**的 type。
2. 若混入與主要目的**無關**的變更，在草稿中明確指出是哪些 commit / 檔案，並**建議拆成多個 PR**，詢問使用者要拆分或維持。不得自行拆分，也不得為了讓標題乾淨而隱瞞混入的變更。
3. 若只是為主要目的服務的必要連帶變更（例如 `feat` 附帶的測試、型別、文件），不算混合，不需提醒。

## 描述（body）

使用**正體中文**，技術識別字、指令、套件名、檔案路徑保留英文。重「為何改」勝於「改了什麼」，不逐檔複述 diff。

### 專案有 PR template 時

**template 優先。** 以 template 的章節與順序為骨架填寫，並遵守下列規則：

- 不刪除、不改名 template 既有章節；與本 Skill 對應的章節（摘要、測試、風險等）依本 Skill 的要求填寫內容。
- template 沒有、但本 Skill 要求的章節（測試與驗證、風險檢查、Reviewer 重點），附加在**最適合的位置**，通常是 template 現有章節之後。
- template 的 checkbox 只能依事實勾選；無法判斷的保持未勾並說明。
- template 的章節與本 Skill 重複時（例如兩邊都有「測試」），合併為一個章節，不重複輸出。

### 沒有 template 時：固定結構

```markdown
## 摘要

<一至三句：為何要改、解決什麼問題、帶來什麼影響>

Closes #<N>   <!-- 僅在有明確來源時才加 -->

## 主要變更

- <依功能或模組歸納的重點，不逐檔列>

## 測試與驗證

- ✅ `<實際執行過的指令>`：<結果>
- ⚠️ 未驗證：<項目>（<原因>）

## 風險檢查

- [ ] 破壞性 API / 契約變更
- [ ] 資料庫 migration / schema 變更
- [ ] 環境變數 / 設定 / 相依套件變更
- [ ] 需注意部署順序或回滾方式

## Reviewer 重點

- <建議優先審查的檔案，或有取捨、有爭議的設計決策>
```

### 各章節寫法

**摘要**
- 第一句說明「為何改」與使用者或系統層面的影響；技術細節留給「主要變更」。
- 有關聯 issue 時，另起一行寫 `Closes #N`（或 `Refs #N`，視是否完整解決）。沒有明確來源就不寫，不得憑空猜測編號。

**主要變更**
- 依功能或模組歸納 3–7 點；每點一句話。
- 不貼 diff、不逐檔列出，除非檔案本身就是重點（例如新增設定檔）。
- 可標示重要的新增、移除、重新命名與行為改變。

**測試與驗證**
- 只寫**實際執行過**的指令與其結果（例如 `pnpm test` 通過、`pnpm build` 成功）。
- 撰寫 `base...head` 範圍的 PR 時，在判定「尚未驗證」前，檢查該分支歷史中的 merge commit、PR 編號或相關來源 PR；用可用的 GitHub 整合或 `gh` 確認 PR 連結及其測試紀錄。只引用確實包含在目前分支範圍、且測試內容與本次變更相關的 PR，不要因為 PR 存在就推定有測試。
- 找到相關 PR 的驗證紀錄時，在此章節附上 PR 超連結，摘要列出其中實際記錄的測試命令、結果與未驗證項目。標明這是該 PR 的驗證紀錄；若目前 `base...head` 整體差異沒有重新驗證，也要明說，不能把歷史 PR 的結果描述成這次整體差異已通過。若同一段引用多個 PR，依 PR 編號由小到大排列。
- **不得**把未執行的測試寫成已通過；不得從「程式碼看起來沒問題」推論「測試通過」。
- 無法執行或未執行的項目，明列為「未驗證」並說明原因。
- 若找不到相關 PR，或 PR 沒有可引用的測試結果，就回退到本節原有寫法：明確寫「尚未執行驗證」，並列出建議使用者跑的指令；不得編造結果或測試連結。

**風險檢查**
- 四個檢查項固定保留，**依 diff 證據勾選**：有證據顯示「有」才勾 `[x]`，並在該項後補一行說明（影響範圍、需要的前置動作、回滾方式）。
- 勾「沒有」須基於已檢視 diff 的事實，例如確認過沒有 migration 檔、沒有改動 `.env.example` 或 lockfile。無法確認時保持 `[ ]` 並寫「待確認」，不要默認為沒有。
- 範例：

  ```markdown
  - [x] 環境變數 / 設定 / 相依套件變更：新增 `R2_BUCKET`，部署前須先在環境設定
  - [ ] 破壞性 API / 契約變更
  ```

**Reviewer 重點**
- 點出建議優先看的檔案或函式，以及值得討論的設計取捨（為何不選另一種做法）。
- 若有混入的非主要目的變更，也在此說明。
- 沒有特別需要說明的，仍保留章節並寫一句「無特別需要留意之處」，不要編造重點。

### 截圖

本 Skill 不預設包含截圖章節。若專案 template 含截圖欄位，且變更涉及 UI，保留該欄位並提醒使用者補圖；**不得**捏造或描述不存在的截圖。

## 範例

標題，良好：

- `feat(cards): 加入 TTS 發音按鈕`
- `fix(ipa): 統一存為 /.../ 並修正雙斜線`
- `chore: 升級 prisma 至 7.8`

標題，避免：

- `Fixed typo`（英文、無 type）
- `feat: add new feature`（中英混用、語意空泛）
- `feat(cards): 加入 TTS 發音按鈕並重構播放器與調整 Prisma schema`（超過 50 字、混合多件事）
- `feat(cards): 加入 TTS 發音按鈕 (#123)`（標題帶 issue 編號、有多餘括號）

描述，良好（節錄）：

```markdown
## 摘要

卡片頁目前無法聆聽單字發音，學習者需自行查詢。加入 TTS 按鈕，點擊即可播放，
並以 content-addressed key 快取音檔，避免重複產生。

Closes #123

## 風險檢查

- [ ] 破壞性 API / 契約變更
- [ ] 資料庫 migration / schema 變更
- [x] 環境變數 / 設定 / 相依套件變更：新增 `R2_BUCKET`，部署前須先設定
- [ ] 需注意部署順序或回滾方式
```

描述，避免：

- 「修改了 `a.ts`、`b.ts`、`c.ts`」式的逐檔流水帳。
- 「已測試，沒有問題」而沒有指令與結果。
- 風險檢查全部直接打勾或全部留空，與 diff 對不上。
- 憑空出現的 issue 編號或截圖。

## 產出方式

1. 蒐集事實（見上）。
2. 輸出**標題**與**完整描述**（單一 Markdown 區塊，方便複製）。
3. 在草稿之外另外簡短列出：
   - 引用的 PR template 與專案規範（若有）。
   - 混合 type 的提醒（若有）。
   - 無法確認、需要使用者補充的事項（issue 編號、截圖、未驗證項目）。
4. 詢問使用者是否確認；確認後才依「權限邊界」建立 PR。

使用者明確要求建立時，可用 `gh pr create --title "<標題>" --body-file <檔案>`，body 以檔案傳入，避免 shell 跳脫破壞 Markdown。建立後回報 PR 連結。

## 提交前檢查

- [ ] 標題 type 屬 8 種之一，整行 ≤ 50 字，描述為正體中文，無結尾句點
- [ ] 標題代表整體目的；混入無關變更時已提醒建議拆 PR
- [ ] 已閱讀實際 diff，而非只依 commit message 撰寫
- [ ] 專案有 PR template 時已採用，缺的章節已補上，沒有重複章節
- [ ] 摘要說明「為何改」，不只是「改了什麼」
- [ ] 已檢查相關來源 PR 的測試紀錄；引用時附連結並交代驗證範圍，無可引用紀錄時回退為明列未驗證；多個 PR 連結依編號由小到大排列
- [ ] 測試與驗證只寫實際執行過的指令與結果，未執行的已明列
- [ ] 風險檢查四項依 diff 證據勾選，勾選項附說明
- [ ] issue 編號與截圖皆有明確來源，無憑空捏造
- [ ] 未自行加 `Co-Authored-By` 或產生器署名
- [ ] 使用者確認前未 push、未建立 PR

## 延伸閱讀

- `git-commit-msg` — commit message 格式（標題規則的來源）
- `AGENTS.md` — 專案自身的 PR、分支與語言規範
- `git log --oneline -20`、`gh pr list --state merged --limit 10` — 觀摩專案近期實際樣式
