#!/bin/bash
set -e

# Feature 安裝後的基本驗證
echo "=== Claude Code feature test ==="

# 1. claude 指令存在於 PATH
if ! command -v claude &> /dev/null; then
    echo "FAIL: claude not found in PATH"
    exit 1
fi
echo "PASS: claude found at $(which claude)"

# 2. 可以取得版本號
VERSION_OUTPUT=$(claude --version 2>&1) || true
if [ -z "${VERSION_OUTPUT}" ]; then
    echo "FAIL: claude --version returned empty"
    exit 1
fi
echo "PASS: claude --version = ${VERSION_OUTPUT}"

# 3. symlink 存在
if [ ! -L /usr/local/bin/claude ]; then
    echo "WARN: /usr/local/bin/claude symlink not found (non-fatal)"
else
    echo "PASS: /usr/local/bin/claude symlink exists"
fi

echo "=== All tests passed ==="
