#!/usr/bin/env bash
set -e
: "${HOST:?Need to set HOST}"

POSSIBLE_PATHS=(
  "OmiseSDK/Sources/OmiseAPI/OmiseAPI.swift"
  "omise-ios/OmiseSDK/Sources/OmiseAPI/OmiseAPI.swift"
)

TARGET_FILE=""
for REL in "${POSSIBLE_PATHS[@]}"; do
  if [ -f "$REL" ]; then
    TARGET_FILE="$REL"
    break
  fi
done

if [ -z "$TARGET_FILE" ]; then
  echo "⚠️  OmiseAPI.swift not found in known locations; skipping host override"
  exit 0
fi

sed -i '' \
  -e "s|https://api\\.omise\\.co|https://api.$HOST|g" \
  -e "s|https://vault\\.omise\\.co|https://vault.$HOST|g" \
  "$TARGET_FILE"

echo "[✔] done updating url"
