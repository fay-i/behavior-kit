#!/usr/bin/env bash
set -euo pipefail

# behavior-kit installer
# Usage:
#   Install into existing repo:  curl -fsSL ...install.sh | bash
#   Install locally (hidden):    curl -fsSL ...install.sh | bash -s -- --local
#   Create new project:          curl -fsSL ...install.sh | bash -s -- --init <project-name>

REPO="fay-i/behavior-kit"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/scaffold"

GREEN='\033[0;32m'
DIM='\033[2m'
NC='\033[0m'

info() { echo -e "${GREEN}[behavior-kit]${NC} $1"; }
dim() { echo -e "${DIM}  $1${NC}"; }

# Parse flags
INIT=false
LOCAL=false
PROJECT_NAME=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --init)
      INIT=true
      PROJECT_NAME="${2:?Usage: install.sh --init <project-name>}"
      shift 2
      ;;
    --local)
      LOCAL=true
      shift
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# --init: create new project directory and git repo
if $INIT; then
  if [[ -d "$PROJECT_NAME" ]]; then
    echo "Error: directory '$PROJECT_NAME' already exists." >&2
    exit 1
  fi
  info "Creating project: $PROJECT_NAME"
  mkdir -p "$PROJECT_NAME"
  cd "$PROJECT_NAME"
  git init -b main --quiet
  cat > .gitignore <<'GITIGNORE'
# OS
.DS_Store
Thumbs.db

# Editors
.vscode/
.idea/
*.swp
*.swo

# Dependencies
node_modules/
vendor/
__pycache__/

# Environment
.env
.env.local
GITIGNORE
  mkdir -p specs
else
  # Verify we're in a git repo
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: not a git repository. Use --init <name> to create a new project, or run from an existing repo." >&2
    exit 1
  fi
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
  ".behavior-kit/scripts/check-prereqs.sh"
)

# Download each file
for file in "${FILES[@]}"; do
  mkdir -p "$(dirname "$file")"
  curl -fsSL "${BASE_URL}/${file}" -o "$file"
  dim "$file"
done

# Make scripts executable
chmod +x .behavior-kit/scripts/init-feature.sh .behavior-kit/scripts/check-prereqs.sh

# --local: hide bk files from git via .git/info/exclude
if $LOCAL; then
  EXCLUDE_PATHS=(
    ".claude/commands/bk.*.md"
    ".cursor/rules/bk-*.mdc"
    ".behavior-kit/"
  )

  EXCLUDE_FILE="$(git rev-parse --git-dir)/info/exclude"
  mkdir -p "$(dirname "$EXCLUDE_FILE")"
  touch "$EXCLUDE_FILE"

  for pattern in "${EXCLUDE_PATHS[@]}"; do
    if ! grep -qF "$pattern" "$EXCLUDE_FILE" 2>/dev/null; then
      echo "$pattern" >> "$EXCLUDE_FILE"
    fi
  done

  info "Added patterns to .git/info/exclude (local only, won't affect teammates)"
fi

# Create specs directory
mkdir -p specs

# --init: make initial commit
if $INIT; then
  git add .gitignore specs/
  git commit --quiet -m "Initial commit"
  info "Created git repo with initial commit on main"
fi

echo ""
info "Done! Commands available:"
dim "/bk.constitution  — Set up project principles"
dim "/bk.specify        — Write a feature spec"
dim "/bk.plan           — Research codebase context"
dim "/bk.behaviors      — Decompose into testable behaviors"
dim "/bk.implement      — Execute behaviors test-first"
echo ""
info "Start with: /bk.constitution"
