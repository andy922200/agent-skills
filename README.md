# agent-skills

一組可重複利用的 **AI coding agent 知識／規範 skill** 集合，把個人專案中累積下來的程式規範、除錯經驗整理成結構化的 Markdown 文件，供各種支援自訂指令／知識檔的 AI coding CLI 工具載入使用——例如 [Claude Code](https://claude.com/claude-code)、[OpenAI Codex CLI](https://github.com/openai/codex) 等。

每個 skill 本質上只是一份遵循固定格式的 Markdown 文件（`SKILL.md`），內容與格式本身不綁定任何特定廠商的執行環境，因此原則上任何能讀取自訂 Markdown 規範檔的 AI coding agent 工具都可以使用它們。

## 這是什麼

每個 skill 都是一個獨立資料夾，至少包含一份 `SKILL.md`，開頭是 YAML frontmatter：

```yaml
---
name: skill-folder-name
description: 這份 skill 在做什麼、什麼情況下該被觸發、什麼情況下不該套用
---
```

- `name`：對應資料夾名稱（kebab-case）。
- `description`：以「常見觸發句式 + 排除條件」的方式撰寫，讓 agent 能判斷使用者目前的意圖是否該載入這份知識。

有些 skill 只有單一 `SKILL.md`，內容較多或需要拆分細項規則的 skill（例如 `shadcn-vue`）則會額外搭配 `rules/`、參考文件等子資料夾，並在 `SKILL.md` 中用相對連結指向它們。這是一種與工具無關（tool-agnostic）的純 Markdown 慣例，不依賴任何私有格式或執行環境。

## Skills 一覽

| Skill | 說明 | 語言 |
| --- | --- | --- |
| [`browser-web-data-discovery`](./browser-web-data-discovery) | 爬蟲／網頁資料收集時，先以可用瀏覽器能力檢視渲染內容與資料來源，再考慮直接 HTTP 請求 | 中文 |
| [`git-commit-msg`](./git-commit-msg) | 撰寫／修正 git commit 訊息的規則，採用 Conventional Commits 格式 | 中文 |
| [`ios-safari-fixed-overlay`](./ios-safari-fixed-overlay) | iOS Safari 上 `position: fixed` 全螢幕遮罩／彈窗底部出現縫隙的除錯指南（WebKit 層級問題，與框架無關） | 中文 |
| [`release-notes-from-commit`](./release-notes-from-commit) | 根據單一指定的 git commit 產生適合發佈於 GitHub Release 的 release notes | 中文 |
| [`shadcn-vue`](./shadcn-vue) | 管理 shadcn-vue 元件與專案：新增、搜尋、除錯、樣式調整、透過 CLI 安裝／更新元件 | 英文 |
| [`typescript-standards`](./typescript-standards) | 跨框架的 TypeScript 撰寫標準：型別安全、函式介面、命名慣例 | 中文 |
| [`vue-typescript-frontend`](./vue-typescript-frontend) | Vue 3 + TypeScript 前端開發完整標準：專案建置、元件、路由、Pinia、i18n、RWD 等（依賴 `typescript-standards`） | 中文 |

## 如何使用

### 方式一：使用 `install.sh`（推薦）

這個 repo 附帶 `install.sh`，可以把共用 skill 以 symlink 的方式連結進你的專案，同時保留專案自有的 skill 不被覆蓋。連結路徑遵循以下結構：

```
project/
├── .agents/
│   └── skills/
│       ├── shadcn-vue
│       │   -> /path/to/agent-skills/shadcn-vue
│       └── project-specific-skill/
│
└── .claude/
    └── skills/
        ├── shadcn-vue
        │   -> ../../.agents/skills/shadcn-vue
        └── claude-project-specific-skill/
```

在目標專案的根目錄執行（依 clone 下來的相對路徑調整）：

```bash
# 連結全部共用 skill
../agent-skills/install.sh --all

# 只連結指定的 skill（逗號分隔）
../agent-skills/install.sh --skills shadcn-vue,typescript-standards

# 列出目前可用的共用 skill
../agent-skills/install.sh --list
```

若目標路徑已存在同名的專案自有 skill（非 symlink），該 skill 會被保留、不會被覆蓋。

### 方式二：手動複製／連結

也不綁定特定工具，可以用通用的手動複製／連結方式：

1. Clone 這個 repo：

   ```bash
   git clone https://github.com/andy922200/agent-skills.git
   ```

2. 把想用的 skill 資料夾複製（或用 symlink 連結）到你的專案中、該 AI coding 工具約定用來讀取自訂指令／skill 的目錄。例如 Claude Code 預設會讀取專案內的 `.claude/skills/`：

   ```bash
   cp -r agent-skills/vue-typescript-frontend your-project/.claude/skills/
   ```

3. 不同工具讀取自訂指令／skill 檔案的目錄慣例與載入機制不盡相同，使用前請對照你所使用工具的官方文件，確認正確的放置位置與是否需要額外設定才能被自動載入或觸發。

> 因為每份 skill 都是獨立的純 Markdown 文件，你也可以只複製單一 skill，不需要整份 repo 一起使用。

## Skill 撰寫慣例

若要新增或修改 skill，可參考現有慣例：

- 資料夾名稱使用 kebab-case，且必須與 `SKILL.md` frontmatter 的 `name` 欄位一致。
- `description` 用「觸發句式列舉 + 明確排除條件」撰寫，方便 agent 準確判斷何時該載入、何時該略過。
- 內容較多時，可拆分成子資料夾（例如 `shadcn-vue/rules/`）或同層級的補充文件（例如 `shadcn-vue/cli.md`），再從 `SKILL.md` 用相對連結指向它們。
- Skill 之間可以互相依賴／引用。例如 `vue-typescript-frontend/SKILL.md` 會先讀取並遵循 `typescript-standards/SKILL.md` 的規則，再疊加 Vue 專屬的規範。
- 每份規範型（而非除錯筆記型）的 skill，建議在結尾附上「完成前檢查」的 checklist，方便 agent 在交付前自我檢查。

### 新增一個 skill

```bash
mkdir my-new-skill
cat > my-new-skill/SKILL.md <<'EOF'
---
name: my-new-skill
description: 描述這份 skill 的用途、常見觸發句式，以及不適用的情況
---

# My New Skill

...內容...
EOF
```

## License

本專案採用 [MIT License](./LICENSE)。
