#!/bin/bash
set -e

CSHIP_VERSION="${CSHIPVERSION:-latest}"
STARSHIP_VERSION="${STARSHIPVERSION:-latest}"

# --- 1. 安裝 starship（cship 的依賴） ---
echo "Installing starship (version: ${STARSHIP_VERSION})..."
if [ "${STARSHIP_VERSION}" = "latest" ]; then
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
else
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes --version "v${STARSHIP_VERSION}"
fi

# 確認安裝成功
if ! command -v starship &> /dev/null; then
    echo "ERROR: starship binary not found after install"
    exit 1
fi
echo "starship installed: $(starship --version | head -1)"

# --- 2. 安裝 cship ---
# 不使用官方 install.sh，因為它會讀 /dev/tty 互動提示，Docker build 時會失敗
echo "Installing cship (version: ${CSHIP_VERSION})..."

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  TARGET="x86_64-unknown-linux-musl" ;;
    aarch64) TARGET="aarch64-unknown-linux-musl" ;;
    *)       echo "ERROR: Unsupported architecture: $ARCH"; exit 1 ;;
esac

if [ "${CSHIP_VERSION}" = "latest" ]; then
    CSHIP_URL="https://github.com/stephenleo/cship/releases/latest/download/cship-${TARGET}"
else
    CSHIP_URL="https://github.com/stephenleo/cship/releases/download/v${CSHIP_VERSION}/cship-${TARGET}"
fi

mkdir -p /root/.local/bin
curl -fsSL "${CSHIP_URL}" -o /root/.local/bin/cship
chmod +x /root/.local/bin/cship
ln -sf /root/.local/bin/cship /usr/local/bin/cship

echo "cship installed: $(cship --version 2>/dev/null || echo 'ok')"

# --- 2b. 安裝 libsecret-tools（cship usage limits 在 Linux 上需要） ---
if command -v apt-get &> /dev/null; then
    apt-get update -qq && apt-get install -y -qq libsecret-tools > /dev/null 2>&1 \
        && echo "libsecret-tools installed" \
        || echo "WARNING: libsecret-tools install failed, usage limits may not work"
fi

# --- 3. 寫入預設 config（若不存在則建立） ---
# 這些 config 會被 bind mount 覆蓋（如果有的話）

CONFIG_DIR="${HOME}/.config"
mkdir -p "${CONFIG_DIR}"

# cship.toml — Full Starship Prompt 模式 + context bar + usage limits
if [ ! -f "${CONFIG_DIR}/cship.toml" ]; then
    cat > "${CONFIG_DIR}/cship.toml" << 'CSHIP_EOF'
[cship]
lines = [
  "$directory$git_branch $cship.model $cship.context_bar $cship.usage_limits",
]

[cship.model]
symbol = "⚡"
style  = "fg:#d171a1"

[cship.context_bar]
symbol             = " "
format             = "[$symbol$value]($style)"
width              = 8
full_char = "█"
empty_char = "█"
style              = "fg:#7dcfff"
warn_threshold     = 40.0
warn_style         = "fg:#e0af68"
critical_threshold = 70.0
critical_style     = "bold fg:#f7768e"

[cship.usage_limits]
five_hour_format   = "⏱ 5h {pct}% ({reset})"
seven_day_format   = "⏱ 7d {pct}% ({reset})"
separator          = " "
style              = "fg:#fbdd95"
warn_threshold     = 70.0
warn_style         = "fg:#e0af68"
critical_threshold = 90.0
critical_style     = "bold fg:#f7768e"
CSHIP_EOF
    echo "Default cship.toml written"
else
    echo "cship.toml already exists, skipping"
fi

# starship.toml — 簡潔 prompt（directory + git branch + status）
if [ ! -f "${CONFIG_DIR}/starship.toml" ]; then
    cat > "${CONFIG_DIR}/starship.toml" << 'STARSHIP_EOF'
format = """
$directory\
$git_branch\
$git_status\
$character\
"""

[directory]
style = "fg:#FFFFFF"
format = "[](fg:#84A9F3 bg:84A9F3)[ $path ](fg:#000000 bg:#84A9F3)[](fg:#84A9F3 bg:#84A9F3)"

[git_branch]
style = "fg:#000000 bg:#98BB94"
format = "[$symbol$branch ]($style)[](fg:#98BB94)"
STARSHIP_EOF
    echo "Default starship.toml written"
else
    echo "starship.toml already exists, skipping"
fi

echo "CShip setup complete!"
