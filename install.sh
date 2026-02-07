#!/usr/bin/env bash
set -euo pipefail

# behavior-kit installer
# Usage: curl -fsSL https://raw.githubusercontent.com/fay-i/behavior-kit/main/install.sh | bash

REPO="fay-i/behavior-kit"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/scaffold"

GREEN='\033[0;32m'
DIM='\033[2m'
NC='\033[0m'

info() { echo -e "${GREEN}[behavior-kit]${NC} $1"; }
dim() { echo -e "${DIM}  $1${NC}"; }

# Verify we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Error: not a git repository. Run this from your project root." >&2
  exit 1
fi

info "Installing behavior-kit..."

# Files to install (relative to scaffold/)
FILES=(
  ".claude/commands/bk.constitution.md"
  ".claude/commands/bk.specify.md"
  ".claude/commands/bk.plan.md"
  ".claude/commands/bk.behaviors.md"
  ".claude/commands/bk.implement.md"
  ".cursor/rules/bk-constitution.mdc"
  ".cursor/rules/bk-specify.mdc"
  ".cursor/rules/bk-plan.mdc"
  ".cursor/rules/bk-behaviors.mdc"
  ".cursor/rules/bk-implement.mdc"
  ".behavior-kit/memory/constitution.md"
  ".behavior-kit/templates/spec-template.md"
  ".behavior-kit/templates/plan-template.md"
  ".behavior-kit/templates/behavior-template.md"
  ".behavior-kit/scripts/init-feature.sh"
)

# Paths to exclude from git tracking
EXCLUDE_PATHS=(
  ".claude/commands/bk.*.md"
  ".cursor/rules/bk-*.mdc"
  ".behavior-kit/"
)

# Download each file
for file in "${FILES[@]}"; do
  mkdir -p "$(dirname "$file")"
  curl -fsSL "${BASE_URL}/${file}" -o "$file"
  dim "$file"
done

# Make scripts executable
chmod +x .behavior-kit/scripts/init-feature.sh

# Add to .git/info/exclude (local gitignore)
EXCLUDE_FILE="$(git rev-parse --git-dir)/info/exclude"
mkdir -p "$(dirname "$EXCLUDE_FILE")"
touch "$EXCLUDE_FILE"

for pattern in "${EXCLUDE_PATHS[@]}"; do
  if ! grep -qF "$pattern" "$EXCLUDE_FILE" 2>/dev/null; then
    echo "$pattern" >> "$EXCLUDE_FILE"
  fi
done

info "Added patterns to .git/info/exclude (local only, won't affect teammates)"

# Create specs directory
mkdir -p specs

echo ""
info "Done! Commands available:"
dim "/bk.constitution  — Set up project principles"
dim "/bk.specify        — Write a feature spec"
dim "/bk.plan           — Research codebase context"
dim "/bk.behaviors      — Decompose into testable behaviors"
dim "/bk.implement      — Execute behaviors test-first"
echo ""
info "Start with: /bk.constitution"
