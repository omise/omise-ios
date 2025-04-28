#!/usr/bin/env bash
set -e

# Expects BUILD_SOURCE, FIREBASE_APP_ID, FIREBASE_DISTRIBUTION_GROUP

NOTES="Build from $BUILD_SOURCE • $(date +%Y-%m-%d) • ${GITHUB_SHA:0:7}"
IPA="build/ExampleApp.ipa"

firebase appdistribution:distribute "$IPA" \
  --app    "$FIREBASE_APP_ID" \
  --groups "$FIREBASE_DISTRIBUTION_GROUP" \
  --release-notes "$NOTES"
