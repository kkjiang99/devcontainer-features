#!/bin/bash
set -e

VERSION="${VERSION:-latest}"

echo "Installing Open Code (version: ${VERSION})..."

# Feature install 階段一律以 root 身份執行
# 安裝 Open Code CLI
# 注意：devcontainer feature 框架會 export VERSION 環境變數，
# opencode installer 也會讀 $VERSION，導致 "vlatest" 錯誤。
# 必須先儲存再 unset，安裝完再還原。
_OPENCODE_VERSION="${VERSION}"
unset VERSION

if [ "${_OPENCODE_VERSION}" = "latest" ]; then
    curl -fsSL https://opencode.ai/install | bash
else
    curl -fsSL https://opencode.ai/install | bash -s -- --version "${_OPENCODE_VERSION}"
fi

# 尋找 opencode binary（可能在 /root/.local/bin 或其他位置）
OPENCODE_BIN=""
for candidate in /root/.opencode/bin/opencode "${HOME}/.opencode/bin/opencode" /root/.local/bin/opencode "${HOME}/.local/bin/opencode" /usr/local/bin/opencode; do
    if [ -f "${candidate}" ]; then
        OPENCODE_BIN="${candidate}"
        break
    fi
done

if [ -z "${OPENCODE_BIN}" ]; then
    echo "ERROR: opencode binary not found after install"
    exit 1
fi

# 建立全域 symlink，讓任何使用者都能用
ln -sf "${OPENCODE_BIN}" /usr/local/bin/opencode

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

echo "Open Code installed: $(opencode --version)"
