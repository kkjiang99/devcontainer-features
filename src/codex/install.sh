#!/bin/bash
set -e

VERSION="${VERSION:-latest}"

echo "Installing Codex (version: ${VERSION})..."

# Feature install 階段一律以 root 身份執行
# 安裝 Codex CLI
if ! command -v npm &> /dev/null; then
    echo "ERROR: npm is required to install Codex CLI"
    echo "This feature expects Node.js/npm to already exist in the container image."
    exit 1
fi

if [ "${VERSION}" = "latest" ]; then
    npm install -g @openai/codex
else
    npm install -g "@openai/codex@${VERSION}"
fi

# 尋找 codex binary。npm 10 已移除 `npm bin`，因此改用 prefix 與套件目錄回推。
CODEX_BIN=""
for candidate in "$(command -v codex 2>/dev/null || true)" /usr/local/bin/codex /usr/bin/codex /root/.npm-global/bin/codex "${HOME}/.npm-global/bin/codex"; do
    if [ -z "${candidate}" ]; then
        continue
    fi

    if [ -f "${candidate}" ]; then
        CODEX_BIN="${candidate}"
        break
    fi
done

if [ -z "${CODEX_BIN}" ]; then
    NPM_GLOBAL_PREFIX="$(npm prefix -g 2>/dev/null || true)"
    for candidate in \
        "${NPM_GLOBAL_PREFIX}/bin/codex" \
        "${NPM_GLOBAL_PREFIX}/lib/node_modules/@openai/codex/bin/codex.js" \
        "/usr/local/lib/node_modules/@openai/codex/bin/codex.js" \
        "/usr/lib/node_modules/@openai/codex/bin/codex.js"
    do
        if [ -f "${candidate}" ]; then
            CODEX_BIN="${candidate}"
            break
        fi
    done
fi

if [ -z "${CODEX_BIN}" ]; then
    NPM_GLOBAL_ROOT="$(npm root -g 2>/dev/null || true)"
    if [ -n "${NPM_GLOBAL_ROOT}" ] && [ -f "${NPM_GLOBAL_ROOT}/@openai/codex/bin/codex.js" ]; then
        CODEX_BIN="${NPM_GLOBAL_ROOT}/@openai/codex/bin/codex.js"
    fi
fi

if [ -z "${CODEX_BIN}" ]; then
    echo "ERROR: codex binary not found after install"
    exit 1
fi

# 建立全域 symlink，讓任何使用者都能用
ln -sf "${CODEX_BIN}" /usr/local/bin/codex

# 確保 /usr/local/bin 在 PATH（通常已在，但保險起見）
EXPORT_LINE='export PATH="/usr/local/bin:$PATH"'

for rc_file in /etc/bash.bashrc /etc/profile; do
    if [ -f "${rc_file}" ]; then
        grep -qF '/usr/local/bin' "${rc_file}" || echo "${EXPORT_LINE}" >> "${rc_file}"
    fi
done
if [ -d /etc/zsh ] || [ -f /etc/zsh/zshenv ]; then
    mkdir -p /etc/zsh
    grep -qF '/usr/local/bin' /etc/zsh/zshenv 2>/dev/null || echo "${EXPORT_LINE}" >> /etc/zsh/zshenv
fi

echo "Codex installed: $(codex --version)"
