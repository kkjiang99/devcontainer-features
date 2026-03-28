#!/bin/bash
set -e

VERSION="${VERSION:-latest}"

echo "Installing Claude Code (version: ${VERSION})..."

# 安裝 Claude Code CLI
if [ "${VERSION}" = "latest" ]; then
    curl -fsSL https://claude.ai/install.sh | bash
else
    curl -fsSL https://claude.ai/install.sh | bash -s -- --version "${VERSION}"
fi

# 偵測實際安裝使用者的 home 目錄
INSTALL_HOME="${HOME:-/root}"

# 確保 PATH 在所有 shell 都正確
EXPORT_LINE="export PATH=\"${INSTALL_HOME}/.local/bin:\$PATH\""

if [ -f /etc/bash.bashrc ]; then
    echo "${EXPORT_LINE}" >> /etc/bash.bashrc
fi
if [ -f /etc/profile ]; then
    echo "${EXPORT_LINE}" >> /etc/profile
fi
if [ -f /etc/zsh/zshenv ] || [ -d /etc/zsh ]; then
    mkdir -p /etc/zsh
    echo "${EXPORT_LINE}" >> /etc/zsh/zshenv
fi

# 建立全域 symlink，解決 devcontainer PATH 問題
if [ -f "${INSTALL_HOME}/.local/bin/claude" ]; then
    ln -sf "${INSTALL_HOME}/.local/bin/claude" /usr/local/bin/claude
fi

echo "Claude Code installed: $(claude --version)"
