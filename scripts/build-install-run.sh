#!/bin/bash
set -e
cd "$(dirname "$0")"
cd ..

INSTALL_PATH="/Applications/StretchBar.app"

killall StretchBar 2>/dev/null || true

xcodebuild -scheme StretchBar -configuration Release clean build

APP=$(xcodebuild -scheme StretchBar -configuration Release -showBuildSettings | grep -m1 "BUILT_PRODUCTS_DIR" | awk '{print $3}')/StretchBar.app

echo ""
ls -lh "$APP/Contents/MacOS/StretchBar"

rm -rf "$INSTALL_PATH"
cp -R "$APP" "$INSTALL_PATH"
echo "Installed to $INSTALL_PATH"

open /Applications/
read -p "Press enter to run..."
open "$INSTALL_PATH"
