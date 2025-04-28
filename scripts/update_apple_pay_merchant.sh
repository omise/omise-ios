#!/usr/bin/env bash
set -e

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
  fi
done

CONFIG_PLIST="ExampleApp/Config.local.plist"
if [ -f "$CONFIG_PLIST" ]; then
  /usr/libexec/PlistBuddy -c "Add :merchant_id string $MERCHANT_ID" "$CONFIG_PLIST" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Set :merchant_id $MERCHANT_ID" "$CONFIG_PLIST"
else
  echo "[⚠] Config.plist not found at: $CONFIG_PLIST"
fi

echo "🎉 Update complete."
