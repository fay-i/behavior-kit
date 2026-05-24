#!/usr/bin/env bash
set -euo pipefail

# Checks that the constitution has been ratified and — for phases that operate
# on an existing feature — that the agent is on the right branch (and inside
# the right worktree, when worktrees are enabled).
#
# Usage: check-prereqs.sh [phase]
#   phase ∈ {session, specify, plan, behaviors, implement, iterate}
#   omitted = constitution-only checks (legacy behavior)

PHASE="${1:-}"
CONSTITUTION=".behavior-kit/memory/constitution.md"

if [[ ! -f "$CONSTITUTION" ]]; then
  echo "Error: Constitution not found. Run /bk.constitution first." >&2
  exit 1
fi

if ! grep -q '^Ratified:' "$CONSTITUTION"; then
  echo "Error: Constitution has not been ratified. Run /bk.constitution first." >&2
  exit 1
fi

if ! grep -qE '^Worktrees:' "$CONSTITUTION"; then
  echo "Error: Constitution is missing the Worktrees decision. Run /bk.constitution to record whether this project uses git worktrees for parallel agents." >&2
  exit 1
fi

# /bk.specify and /bk.session both start from main — they're the phases that
# *create* their branch — so they only need the constitution checks above. An
# un-phased invocation keeps the legacy contract. Everything else has to be on
# a feature branch and, when worktrees are on, inside the matching
# .worktrees/<NNN-slug>/ checkout.
case "$PHASE" in
  ""|specify|session)
    exit 0
    ;;
  plan|behaviors|implement|iterate)
    ;;
  *)
    echo "Error: unknown phase '$PHASE' passed to check-prereqs.sh." >&2
    exit 1
    ;;
esac

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
if [[ -z "$CURRENT_BRANCH" || "$CURRENT_BRANCH" == "HEAD" ]]; then
  echo "Error: /bk.$PHASE must run on a feature branch, but HEAD is detached." >&2
  exit 1
fi

case "$CURRENT_BRANCH" in
  main|master|trunk|develop)
    echo "Error: /bk.$PHASE refuses to run on '$CURRENT_BRANCH'. Switch to the feature branch (or its worktree) before continuing — feature work never lands directly on the trunk." >&2
    exit 1
    ;;
esac

if [[ ! "$CURRENT_BRANCH" =~ ^feature/[0-9]+-[a-z0-9-]+$ ]]; then
  echo "Error: /bk.$PHASE expects a 'feature/NNN-slug' branch, got '$CURRENT_BRANCH'." >&2
  exit 1
fi

# Worktree enforcement: when the constitution opted in, every non-specify phase
# must execute inside the .worktrees/<NNN-slug>/ checkout that init-feature.sh
# created, so two agents on different specs can never trample each other.
if grep -qE '^Worktrees:[[:space:]]*enabled[[:space:]]*$' "$CONSTITUTION"; then
  EXPECTED_SUFFIX="${CURRENT_BRANCH#feature/}"
  EXPECTED_WORKTREE_FRAGMENT="/.worktrees/${EXPECTED_SUFFIX}"
  CWD=$(pwd)
  if [[ "$CWD" != *"$EXPECTED_WORKTREE_FRAGMENT" && "$CWD" != *"$EXPECTED_WORKTREE_FRAGMENT/"* ]]; then
    echo "Error: /bk.$PHASE on '$CURRENT_BRANCH' must run inside '.worktrees/${EXPECTED_SUFFIX}/' (current dir: $CWD)." >&2
    echo "Hint: cd into the worktree, or run 'git worktree add .worktrees/${EXPECTED_SUFFIX} $CURRENT_BRANCH' from the main checkout if it doesn't exist yet." >&2
    exit 1
  fi
fi
