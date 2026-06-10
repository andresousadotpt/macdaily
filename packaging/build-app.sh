#!/usr/bin/env bash
#
# Builds macdaily in release mode and assembles a distributable macdaily.app bundle.
# Usage: ./packaging/build-app.sh [output-dir]   (default output: ./dist)
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${1:-$ROOT/dist}"
APP_NAME="macdaily"
EXECUTABLE="MacDaily"
BUNDLE="$OUT_DIR/$APP_NAME.app"

echo "==> Building release binary"
swift build -c release --package-path "$ROOT"
BIN_PATH="$(swift build -c release --package-path "$ROOT" --show-bin-path)/$EXECUTABLE"

echo "==> Assembling $BUNDLE"
rm -rf "$BUNDLE"
mkdir -p "$BUNDLE/Contents/MacOS"
mkdir -p "$BUNDLE/Contents/Resources"

cp "$BIN_PATH" "$BUNDLE/Contents/MacOS/$EXECUTABLE"
cp "$ROOT/packaging/Info.plist" "$BUNDLE/Contents/Info.plist"
cp "$ROOT/packaging/MacDaily.entitlements" "$BUNDLE/Contents/entitlements.plist"

if [[ ! -f "$ROOT/Sources/MacDaily/Resources/Logo.png" ]]; then
  echo "==> Generating AppIcon.png (no Logo.png in Resources)"
  swift "$ROOT/packaging/generate-icon.swift" "$ROOT/packaging/AppIcon.png"
  SRC_ICON="$ROOT/packaging/AppIcon.png"
else
  SRC_ICON="$ROOT/Sources/MacDaily/Resources/Logo.png"
  cp "$SRC_ICON" "$ROOT/packaging/AppIcon.png"
fi

echo "==> Generating AppIcon.icns"
ICONSET="$(mktemp -d)/AppIcon.iconset"
mkdir -p "$ICONSET"
for size in 16 32 128 256 512; do
    sips -z "$size" "$size"        "$SRC_ICON" --out "$ICONSET/icon_${size}x${size}.png"   >/dev/null
    sips -z $((size*2)) $((size*2)) "$SRC_ICON" --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$BUNDLE/Contents/Resources/AppIcon.icns"

echo "==> Ad-hoc code signing"
codesign --force --deep --sign - "$BUNDLE" || echo "warning: codesign failed (app will still run locally)"

echo "==> Done: $BUNDLE"
