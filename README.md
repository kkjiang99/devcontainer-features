# devcontainer-features

可重用的 devcontainer features — Claude Code、Open Code、CShip 等開發工具。

透過 [devcontainers/action](https://github.com/devcontainers/action) 發布至 GHCR，由 `v*` tag 觸發。

## 可用 Features

### `claude-code`

安裝 [Claude Code](https://claude.ai/code) CLI 至任何 devcontainer。

```json
{
  "features": {
    "ghcr.io/kkjiang99/devcontainer-features/claude-code:1": {}
  }
}
```

| 選項 | 類型 | 預設值 | 說明 |
|------|------|--------|------|
| `version` | string | `latest` | 安裝的 Claude Code 版本 |

#### 建議的 mount 設定

讓 Claude Code 設定與記憶在 container rebuild 後保留：

```json
{
  "mounts": [
    "source=${localEnv:HOME}/.claude,target=/root/.claude,type=bind,consistency=cached",
    "source=${localEnv:HOME}/.claude.json,target=/root/.claude.json,type=bind,consistency=cached"
  ],
  "remoteEnv": {
    "ANTHROPIC_API_KEY": "${localEnv:ANTHROPIC_API_KEY}"
  }
}
```

---

### `cship`

安裝 [cship](https://github.com/anthropics/cship) + [starship](https://starship.rs)，提供 Claude Code statusline，內建預設設定檔。

```json
{
  "features": {
    "ghcr.io/kkjiang99/devcontainer-features/cship:1": {}
  }
}
```

| 選項 | 類型 | 預設值 | 說明 |
|------|------|--------|------|
| `cshipVersion` | string | `latest` | 安裝的 cship 版本 |
| `starshipVersion` | string | `latest` | 安裝的 starship 版本 |

會在 `claude-code` 之後安裝（若存在）。包含 `libsecret-tools`（Linux 上 usage limits 需要）。預設 `cship.toml` 與 `starship.toml` 已內建，不會覆蓋容器內既有設定。

---

### `open-code`

安裝 [Open Code](https://opencode.ai) CLI 至任何 devcontainer。

```json
{
  "features": {
    "ghcr.io/kkjiang99/devcontainer-features/open-code:1": {}
  }
}
```

| 選項 | 類型 | 預設值 | 說明 |
|------|------|--------|------|
| `version` | string | `latest` | 安裝的 Open Code 版本 |

---

### `codex`

安裝 Codex CLI 至任何 devcontainer。

需先確保容器內已有 Node.js / npm。此 feature 只負責安裝 Codex CLI，不額外安裝 Node runtime。

```json
{
  "features": {
    "ghcr.io/kkjiang99/devcontainer-features/codex:1": {}
  }
}
```

| 選項 | 類型 | 預設值 | 說明 |
|------|------|--------|------|
| `version` | string | `latest` | 安裝的 Codex 版本 |

#### 建議的 mount 設定

讓 Codex 設定與登入狀態在 container rebuild 後保留：

```json
{
  "mounts": [
    "source=${localEnv:HOME}/.codex,target=/root/.codex,type=bind,consistency=cached",
    "source=${localEnv:HOME}/.codex/auth.json,target=/root/.codex/auth.json,type=bind,consistency=cached"
  ],
  "remoteEnv": {
    "OPENAI_API_KEY": "${localEnv:OPENAI_API_KEY}"
  }
}
```

---

## 完整範例

使用全部四個 features 搭配 docker-compose 的 devcontainer.json：

```json
{
  "name": "My Project",
  "dockerComposeFile": ["../docker-compose.yml", "docker-compose.devcontainer.yml"],
  "service": "app",
  "workspaceFolder": "/workspace",
  "remoteUser": "root",
  "features": {
    "ghcr.io/kkjiang99/devcontainer-features/claude-code:1": {},
    "ghcr.io/kkjiang99/devcontainer-features/cship:1": {},
    "ghcr.io/kkjiang99/devcontainer-features/open-code:1": {},
    "ghcr.io/kkjiang99/devcontainer-features/codex:1": {}
  },
  "mounts": [
    "source=${localEnv:HOME}/.claude,target=/root/.claude,type=bind,consistency=cached",
    "source=${localEnv:HOME}/.claude.json,target=/root/.claude.json,type=bind,consistency=cached",
    "source=${localEnv:HOME}/.codex,target=/root/.codex,type=bind,consistency=cached",
    "source=${localEnv:HOME}/.codex/auth.json,target=/root/.codex/auth.json,type=bind,consistency=cached"
  ],
  "remoteEnv": {
    "ANTHROPIC_API_KEY": "${localEnv:ANTHROPIC_API_KEY}",
    "OPENAI_API_KEY": "${localEnv:OPENAI_API_KEY}"
  }
}
```

引用時使用 `:1`（major version）而非 `:latest`，避免 rebuild 時遇到 breaking change。

## 版本與發布

- Feature 版本由各自 `devcontainer-feature.json` 的 `"version"` 欄位控制，**不是** git tag
- Git tag（`v*`）只是觸發 GitHub Actions workflow 的手段
- `devcontainers/action` 若 GHCR 上已有相同版本會跳過發布
- **每次修改 feature 後必須 bump JSON 版本號**，否則不會重新發布

## 疑難排解

### cship install.sh 讀取 `/dev/tty`

官方 cship installer 會互動詢問，Docker build 時無 TTY 導致失敗。本 feature 改為直接從 GitHub Releases 下載 binary。

### `VERSION` 環境變數衝突

devcontainer feature 框架會將 options export 為環境變數（如 `VERSION=latest`）。部分第三方 installer 也會讀 `$VERSION`，造成衝突。例如 opencode installer 在 `$VERSION` 前加 `v`，導致嘗試安裝 `vlatest`。install script 在呼叫 installer 前會先 `unset VERSION` 避免此問題。

### Feature 推送後沒更新

推了新 git tag 但 GHCR 上的 feature 沒更新？檢查是否有 bump `devcontainer-feature.json` 的 `"version"`。Action 比對的是 JSON 版本，不是 git tag。
