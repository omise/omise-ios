#!/usr/bin/env bash
set -euo pipefail

: "${DISTRIB_CERT_BASE64:?ERROR: DISTRIB_CERT_BASE64 is not set}"
: "${DISTRIB_CERT_PASSWORD:?ERROR: DISTRIB_CERT_PASSWORD is not set}"
: "${PROFILE_BASE64:?ERROR: PROFILE_BASE64 is not set}"
: "${KEYCHAIN_PASSWORD:?ERROR: KEYCHAIN_PASSWORD is not set}"

security delete-keychain build.keychain 2>/dev/null || echo "– no existing keychain"

security create-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
security unlock-keychain  -p "$KEYCHAIN_PASSWORD" build.keychain

security list-keychains -d user

echo "$DISTRIB_CERT_BASE64" | base64 --decode > temp_cert.p12
security import temp_cert.p12 \
         -f pkcs12 \
         -k build.keychain \
         -P "$DISTRIB_CERT_PASSWORD" \
         -T /usr/bin/codesign
rm temp_cert.p12

security find-identity -p codesigning build.keychain

security list-keychains -d user -s build.keychain $(security list-keychains -d user | sed 's/"//g')
security default-keychain -s build.keychain
security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PASSWORD" build.keychain

# decode profile
echo "$PROFILE_BASE64" | base64 --decode > distribution_profile.mobileprovision
DEST="$HOME/Library/MobileDevice/Provisioning Profiles"
mkdir -p "$DEST"
cp distribution_profile.mobileprovision "$DEST/"

rm distribution_profile.mobileprovision
ls -l "$DEST" | grep distribution_profile.mobileprovision
