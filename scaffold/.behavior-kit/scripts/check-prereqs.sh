#!/usr/bin/env bash
set -euo pipefail

# Checks that the constitution has been ratified.
# Usage: check-prereqs.sh

CONSTITUTION=".behavior-kit/memory/constitution.md"

if [[ ! -f "$CONSTITUTION" ]]; then
  echo "Error: Constitution not found. Run /bk.constitution first." >&2
  exit 1
fi

if ! grep -q '^Ratified:' "$CONSTITUTION"; then
  echo "Error: Constitution has not been ratified. Run /bk.constitution first." >&2
  exit 1
fi
