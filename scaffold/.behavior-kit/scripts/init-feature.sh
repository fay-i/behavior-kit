#!/usr/bin/env bash
set -euo pipefail

# Usage: init-feature.sh <feature-name>
# Creates a numbered feature branch and spec directory.

FEATURE_NAME="${1:?Usage: init-feature.sh <feature-name>}"
SLUG=$(echo "$FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')

# Find next feature number
SPECS_DIR="specs"
mkdir -p "$SPECS_DIR"
LAST=$(ls -d "$SPECS_DIR"/[0-9]*-* 2>/dev/null | sort -t/ -k2 -n | tail -1 | grep -oP '\d+' | head -1 || echo "0")
NEXT=$(printf "%03d" $((10#$LAST + 1)))

FEATURE_DIR="$SPECS_DIR/${NEXT}-${SLUG}"
BRANCH="feature/${NEXT}-${SLUG}"

# Create branch and directory
git checkout -b "$BRANCH"
mkdir -p "$FEATURE_DIR"

echo "Created branch: $BRANCH"
echo "Created directory: $FEATURE_DIR"
echo "$FEATURE_DIR"
