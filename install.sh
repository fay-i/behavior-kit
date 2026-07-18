#!/usr/bin/env bash
set -euo pipefail

# behavior-kit installer
# Usage:
#   Install into existing repo:  curl -fsSL ...install.sh | bash
#   Install locally (hidden):    curl -fsSL ...install.sh | bash -s -- --local
#   Create new project:          curl -fsSL ...install.sh | bash -s -- --init <project-name>
#   Update existing install:     curl -fsSL ...install.sh | bash -s -- --update

REPO="krnl-panic/behavior-kit"
BRANCH="main"
BASE_URL="${BEHAVIOR_KIT_BASE_URL:-https://raw.githubusercontent.com/${REPO}/${BRANCH}/scaffold}"

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
DIM='\033[2m'
NC='\033[0m'

info() { echo -e "${GREEN}[behavior-kit]${NC} $1"; }
warn() { echo -e "${YELLOW}[behavior-kit]${NC} $1"; }
dim() { echo -e "${DIM}  $1${NC}"; }

# Parse flags
INIT=false
LOCAL=false
UPDATE=false
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
    --update)
      UPDATE=true
      shift
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# --update and --init are mutually exclusive (one creates a project, the other
# refreshes an existing install).
if $UPDATE && $INIT; then
  echo "Error: --update and --init can't be used together." >&2
  exit 1
fi

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

if $UPDATE; then
  info "Updating behavior-kit to latest from ${BRANCH}..."
else
  info "Installing behavior-kit..."
fi

# Files to install (relative to scaffold/). Order matters only for readability —
# every file is independently downloaded.
FILES=(
  ".claude/commands/bk.constitution.md"
  ".claude/commands/bk.specify.md"
  ".claude/commands/bk.plan.md"
  ".claude/commands/bk.behaviors.md"
  ".claude/commands/bk.implement.md"
  ".claude/commands/bk.iterate.md"
  ".claude/commands/bk.session.md"
  ".claude/commands/bk.monitor.md"
  ".claude/agents/bk-specify.md"
  ".claude/agents/bk-plan.md"
  ".claude/agents/bk-behaviors.md"
  ".claude/agents/bk-implement.md"
  ".claude/agents/implementation-agent.md"
  ".claude/agents/bk-enhance.md"
  ".claude/agents/bk-verify.md"
  ".claude/agents/pr-monitor.md"
  ".cursor/rules/bk-constitution.mdc"
  ".cursor/rules/bk-specify.mdc"
  ".cursor/rules/bk-plan.mdc"
  ".cursor/rules/bk-behaviors.mdc"
  ".cursor/rules/bk-implement.mdc"
  ".cursor/rules/bk-iterate.mdc"
  ".cursor/rules/bk-session.mdc"
  ".agents/skills/bk-constitution/SKILL.md"
  ".agents/skills/bk-specify/SKILL.md"
  ".agents/skills/bk-plan/SKILL.md"
  ".agents/skills/bk-behaviors/SKILL.md"
  ".agents/skills/bk-implement/SKILL.md"
  ".agents/skills/bk-iterate/SKILL.md"
  ".agents/skills/bk-session/SKILL.md"
  ".agents/skills/bk-monitor/SKILL.md"
  ".behavior-kit/memory/constitution.md"
  ".behavior-kit/templates/spec-template.md"
  ".behavior-kit/templates/plan-template.md"
  ".behavior-kit/templates/behavior-template.md"
  ".behavior-kit/templates/review-template.md"
  ".behavior-kit/scripts/init-feature.sh"
  ".behavior-kit/scripts/init-session.sh"
  ".behavior-kit/scripts/check-prereqs.sh"
  ".behavior-kit/scripts/setup-worktrees.sh"
)

# Files that hold user-edited state. On --update we leave these alone if the
# user already has a copy; on fresh install they're seeded from the scaffold.
PRESERVE_ON_UPDATE=(
  ".behavior-kit/memory/constitution.md"
)

is_preserved() {
  local needle="$1"
  for f in "${PRESERVE_ON_UPDATE[@]}"; do
    [[ "$f" == "$needle" ]] && return 0
  done
  return 1
}

# Download each file
for file in "${FILES[@]}"; do
  if $UPDATE && is_preserved "$file" && [[ -f "$file" ]]; then
    dim "$file (preserved)"
    continue
  fi
  mkdir -p "$(dirname "$file")"
  curl -fsSL "${BASE_URL}/${file}" -o "$file"
  dim "$file"
done

# Make scripts executable
chmod +x .behavior-kit/scripts/init-feature.sh \
         .behavior-kit/scripts/init-session.sh \
         .behavior-kit/scripts/check-prereqs.sh \
         .behavior-kit/scripts/setup-worktrees.sh

# --local: hide bk files from git via .git/info/exclude
if $LOCAL; then
  EXCLUDE_PATHS=(
    ".claude/commands/bk.*.md"
    ".claude/agents/bk-*.md"
    ".claude/agents/implementation-agent.md"
    ".claude/agents/pr-monitor.md"
    ".cursor/rules/bk-*.mdc"
    ".agents/skills/bk-*/"
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
if $UPDATE; then
  info "Updated. Constitution and specs/ left untouched; everything else refreshed from ${BRANCH}."
else
  info "Done! Commands available:"
  dim "/bk.constitution  — Set up project principles"
  dim "/bk.specify        — Write a feature spec"
  dim "/bk.plan           — Research codebase context"
  dim "/bk.behaviors      — Decompose into testable behaviors"
  dim "/bk.implement      — Execute behaviors test-first"
  dim "/bk.iterate        — Address PR review feedback"
  dim "/bk.session        — Lightweight pairing / one-off session"
  dim "/bk.monitor        — Drive a PR's automated review loop to merge-ready"
  echo ""
  dim "Codex users: slash names use hyphens (e.g. /bk-specify, /bk-session)."
  echo ""
  info "Start with: /bk.constitution"
fi
