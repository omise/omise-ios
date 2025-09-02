#!/bin/bash
set -e

SIMULATOR=$(xcrun simctl list devices available | grep "iPhone" | sort -V | tail -1 | sed 's/.*\(iPhone [^(]*\).*/\1/' | sed 's/[[:space:]]*$//')

echo "Using: $SIMULATOR"
echo "SIMULATOR_NAME=$SIMULATOR" >> $GITHUB_ENV