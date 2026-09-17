#!/bin/bash
set -e
cd "$(dirname "$0")"/..

BIN_DIR="$HOME/.local/bin"
BIN_PATH="$BIN_DIR/stretchbar-dismiss"

mkdir -p "$BIN_DIR"
swiftc -O raycast/dismiss.swift -o "$BIN_PATH"

echo "Installed to $BIN_PATH"
echo "Point your Raycast command at: $BIN_PATH"
