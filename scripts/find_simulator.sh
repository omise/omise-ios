#!/bin/bash
set -e

echo "Finding available iPhone simulator..."

# Try to find an available iPhone simulator
SIMULATOR_LINE=$(xcrun simctl list devices available | grep "iPhone" | head -1)

if [ -z "$SIMULATOR_LINE" ]; then
    echo "No available iPhone simulators found. Booting the first iPhone simulator..."
    # Get any iPhone simulator and boot it
    SIMULATOR_LINE=$(xcrun simctl list devices | grep "iPhone" | grep -v "unavailable" | head -1)
    if [ -n "$SIMULATOR_LINE" ]; then
        SIMULATOR_ID=$(echo "$SIMULATOR_LINE" | sed 's/.*(\([^)]*\)).*/\1/')
        echo "Booting simulator: $SIMULATOR_ID"
        xcrun simctl boot "$SIMULATOR_ID" || true
        sleep 3
        SIMULATOR_LINE=$(xcrun simctl list devices available | grep "iPhone" | head -1)
    fi
fi

if [ -z "$SIMULATOR_LINE" ]; then
    echo "Error: No iPhone simulators found"
    exit 1
fi

# Extract the device name (everything before the UUID)
SIMULATOR=$(echo "$SIMULATOR_LINE" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*([A-F0-9-]*).*$//' | sed 's/[[:space:]]*$//')

echo "Using: $SIMULATOR"
if [ -n "$GITHUB_ENV" ]; then
    echo "SIMULATOR_NAME=$SIMULATOR" >> $GITHUB_ENV
fi