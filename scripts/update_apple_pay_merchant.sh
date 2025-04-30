#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

if [ -z "$MERCHANT_ID" ]; then
  echo "ERROR: MERCHANT_ID not set."
  exit 1
fi

ENT_FILES=(
  "ExampleApp/ExampleApp.entitlements"
  "ExampleApp/ExampleAppDebug.entitlements"
)

for ENT in "${ENT_FILES[@]}"; do
  if [ -f "$ENT" ]; then
    /usr/libexec/PlistBuddy -c "Add :com.apple.developer.in-app-payments array" "$ENT" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Set :com.apple.developer.in-app-payments:0 $MERCHANT_ID" "$ENT"
  else
    echo "[⚠] Entitlements file not found: $ENT"
    exit 1
  fi
done

CONFIG_PLIST="ExampleApp/Config.local.plist"
if [ -f "$CONFIG_PLIST" ]; then
  /usr/libexec/PlistBuddy -c "Add :merchantId string $MERCHANT_ID" "$CONFIG_PLIST" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Set :merchantId $MERCHANT_ID" "$CONFIG_PLIST"
else
  echo "[⚠] Config.plist not found at: $CONFIG_PLIST"
  exit 1
fi

echo "🎉 Update complete."
