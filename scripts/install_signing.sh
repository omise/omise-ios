#!/usr/bin/env bash
set -e

# Expects:
# DISTRIB_CERT_BASE64, DISTRIB_CERT_PASSWORD
# PROFILE_BASE64, KEYCHAIN_PASSWORD

# Decode files
echo "$DISTRIB_CERT_BASE64"   | base64 --decode > dist.p12
echo "$PROFILE_BASE64"        | base64 --decode > profile.mobileprovision

# Create + unlock keychain
security create-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
security unlock-keychain  -p "$KEYCHAIN_PASSWORD" build.keychain

# Import certificate (with private key - .p12)
security import dist.p12 -P "$DISTRIB_CERT_PASSWORD" -A -k build.keychain

# Make the new keychain default/visible
security list-keychains -d user -s build.keychain $(security list-keychains -d user | tr -d '"')
security default-keychain -s build.keychain
security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PASSWORD" build.keychain

# Install provisioning profile
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp profile.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/
