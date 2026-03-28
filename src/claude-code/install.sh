#!/bin/bash
set -e

VERSION="${VERSION:-latest}"

echo "Installing Claude Code (version: ${VERSION})..."

# Feature install 階段一律以 root 身份執行
# 安裝 Claude Code CLI
if [ "${VERSION}" = "latest" ]; then
    curl -fsSL https://claude.ai/install.sh | bash
else
    curl -fsSL https://claude.ai/install.sh | bash -s -- --version "${VERSION}"
fi

# 尋找 claude binary（可能在 /root/.local/bin 或其他位置）
CLAUDE_BIN=""
for candidate in /root/.local/bin/claude "${HOME}/.local/bin/claude" /usr/local/bin/claude; do
    if [ -f "${candidate}" ]; then
        CLAUDE_BIN="${candidate}"
        break
    fi
done

if [ -z "${CLAUDE_BIN}" ]; then
    echo "ERROR: claude binary not found after install"
    exit 1
fi

# 建立全域 symlink，讓任何使用者都能用
ln -sf "${CLAUDE_BIN}" /usr/local/bin/claude

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

echo "Claude Code installed: $(claude --version)"
