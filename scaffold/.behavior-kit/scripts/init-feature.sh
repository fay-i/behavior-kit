#!/usr/bin/env bash
set -euo pipefail

# Usage: init-feature.sh <feature-name>
# Creates a numbered feature branch and spec directory.

FEATURE_NAME="${1:?Usage: init-feature.sh <feature-name>}"
SLUG=$(echo "$FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')

# Find next feature number from local specs AND remote branches
SPECS_DIR="specs"
mkdir -p "$SPECS_DIR"

# Numbers from local spec directories
LOCAL_LAST=$(ls -1d "$SPECS_DIR"/[0-9]*-* 2>/dev/null | sed 's|.*/||' | grep -oE '^[0-9]+' | sort -n | tail -1 || true)

# Numbers from remote feature branches (feature/NNN-*)
git fetch --quiet origin 2>/dev/null || true
REMOTE_LAST=$(git branch -r 2>/dev/null | grep -oE 'feature/[0-9]+-' | grep -oE '[0-9]+' | sort -n | tail -1 || true)

# Take the higher of the two
LAST=0
[[ -n "$LOCAL_LAST" && "$LOCAL_LAST" -gt "$LAST" ]] && LAST=$LOCAL_LAST
[[ -n "$REMOTE_LAST" && "$REMOTE_LAST" -gt "$LAST" ]] && LAST=$REMOTE_LAST
NEXT=$(printf "%03d" $((10#$LAST + 1)))

FEATURE_DIR="$SPECS_DIR/${NEXT}-${SLUG}"
BRANCH="feature/${NEXT}-${SLUG}"

# Create branch and directory
git checkout -b "$BRANCH"
mkdir -p "$FEATURE_DIR"

echo "Created branch: $BRANCH"
echo "Created directory: $FEATURE_DIR"
echo "$FEATURE_DIR"
