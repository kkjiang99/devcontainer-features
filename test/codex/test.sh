#!/bin/bash
set -e

# Feature 安裝後的基本驗證
echo "=== Codex feature test ==="

# 1. codex 指令存在於 PATH
if ! command -v codex &> /dev/null; then
    echo "FAIL: codex not found in PATH"
    exit 1
fi
echo "PASS: codex found at $(which codex)"

# 2. 可以取得版本號
VERSION_OUTPUT=$(codex --version 2>&1) || true
if [ -z "${VERSION_OUTPUT}" ]; then
    echo "FAIL: codex --version returned empty"
    exit 1
fi
echo "PASS: codex --version = ${VERSION_OUTPUT}"

# 3. symlink 存在
if [ ! -L /usr/local/bin/codex ]; then
    echo "WARN: /usr/local/bin/codex symlink not found (non-fatal)"
else
    echo "PASS: /usr/local/bin/codex symlink exists"
fi

echo "=== All tests passed ==="
