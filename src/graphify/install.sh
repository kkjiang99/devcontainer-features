#!/bin/bash
set -e

echo "Installing graphify..."

# --- 1. 確保有 python3 + pip ---
if ! command -v python3 &> /dev/null; then
    echo "python3 not found, installing..."
    if command -v apt-get &> /dev/null; then
        apt-get update -qq && apt-get install -y -qq python3 python3-pip > /dev/null 2>&1
    else
        echo "ERROR: python3 not found and no apt-get available"
        exit 1
    fi
fi

# 確保 pip 可用
if ! python3 -m pip --version &> /dev/null; then
    if command -v apt-get &> /dev/null; then
        apt-get update -qq && apt-get install -y -qq python3-pip > /dev/null 2>&1
    fi
fi

# --- 2. 安裝 graphifyy（PyPI 套件名） ---
echo "Installing graphifyy from PyPI..."
python3 -m pip install graphifyy --break-system-packages 2>/dev/null \
    || python3 -m pip install graphifyy

# --- 3. 執行 graphify install ---
echo "Running graphify install..."
graphify install --break-system-packages 2>/dev/null \
    || graphify install \
    || echo "WARNING: graphify install failed, you may need to run it manually"

# 確認安裝成功
if command -v graphify &> /dev/null; then
    echo "graphify installed successfully"
else
    echo "WARNING: graphify command not found in PATH after install"
fi

echo "Graphify setup complete!"
