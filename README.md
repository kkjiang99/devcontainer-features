# devcontainer-features

Reusable devcontainer features — Claude Code CLI and other dev tools.

## Available Features

### `claude-code`

Installs [Claude Code](https://claude.ai/code) CLI into any devcontainer.

#### Usage

```json
{
  "features": {
    "ghcr.io/kkjiang99/devcontainer-features/claude-code:1": {}
  }
}
```

#### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `latest` | Version of Claude Code to install |

#### Recommended devcontainer.json mounts

To persist Claude Code config and memory across container rebuilds:

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
