#!/usr/bin/env bash
# Test runner. Sources lib.sh, then each tests/test_*.sh, then executes every
# function listed in that file's TESTS=() array inside its own tmpdir.
set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
export REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

GREEN=$'\033[0;32m'
RED=$'\033[0;31m'
DIM=$'\033[2m'
NC=$'\033[0m'

PASS=0
FAIL=0
FAILED_TESTS=()

run_one() {
  local test_name="$1"
  setup_workspace
  local rc=0
  ( set -e; "$test_name" ) || rc=$?
  if (( rc == 0 )); then
    echo "  ${GREEN}OK${NC}   $test_name"
    PASS=$((PASS + 1))
  else
    echo "  ${RED}FAIL${NC} $test_name"
    FAIL=$((FAIL + 1))
    FAILED_TESTS+=("$test_name")
  fi
  teardown_workspace
}

for test_file in "$SCRIPT_DIR"/test_*.sh; do
  [[ -f "$test_file" ]] || continue
  echo ""
  echo "${DIM}$(basename "$test_file")${NC}"
  TESTS=()
  # shellcheck disable=SC1090
  . "$test_file"
  for t in "${TESTS[@]}"; do
    run_one "$t"
  done
done

echo ""
echo "─────────────────────────────────────────"
echo "${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}"
if (( FAIL > 0 )); then
  echo ""
  echo "Failed:"
  for t in "${FAILED_TESTS[@]}"; do
    echo "  - $t"
  done
  exit 1
fi
