#!/usr/bin/env bash
set -e

# Determine if we’re on main, develop, or a tag
if [[ "$GITHUB_REF" == refs/heads/main ]]; then
  echo "BUILD_SOURCE=main"
elif [[ "$GITHUB_REF" == refs/heads/develop ]]; then
  echo "BUILD_SOURCE=develop"
elif [[ "$GITHUB_REF" == refs/heads/feature/auto-example-app-release ]]; then
   echo "BUILD_SOURCE=testing"
else
  echo "BUILD_SOURCE=${GITHUB_REF#refs/tags/}"
fi
