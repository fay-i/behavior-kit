#!/usr/bin/env bash
# Shared helpers for behavior-kit tests. Sourced by tests/run.sh.

: "${REPO_ROOT:?REPO_ROOT must be set by run.sh}"

INSTALL_SH="${REPO_ROOT}/install.sh"
SCAFFOLD_DIR="${REPO_ROOT}/scaffold"

# install.sh reads BEHAVIOR_KIT_BASE_URL to override the default GitHub raw URL.
# file:// lets curl read from the local working tree — no HTTP server needed.
export BEHAVIOR_KIT_BASE_URL="file://${SCAFFOLD_DIR}"

setup_workspace() {
  WORKSPACE="$(mktemp -d)"
  cd "$WORKSPACE"
}

teardown_workspace() {
  if [[ -n "${WORKSPACE:-}" && -d "$WORKSPACE" ]]; then
    cd /
    chmod -R +w "$WORKSPACE" 2>/dev/null || true
    rm -rf "$WORKSPACE"
  fi
}

init_git_repo() {
  git init -b main --quiet
  git config user.email "test@behavior-kit.local"
  git config user.name "behavior-kit test"
}

# Write a minimal constitution with the given Worktrees mode (enabled|disabled).
# Overwrites any existing file. Always ratified so check-prereqs is satisfied.
write_constitution() {
  local worktrees="${1:?usage: write_constitution enabled|disabled}"
  mkdir -p .behavior-kit/memory
  cat > .behavior-kit/memory/constitution.md <<EOF
# Test Constitution

## Article I — placeholder

Worktrees: ${worktrees}
Ratified: 2026-05-24
EOF
}

# Install bk into the current (already git-init'd) repo, write a ratified
# constitution with the given worktrees mode, and seed an initial commit so
# init-feature.sh has a HEAD to branch from.
install_bk_with_worktrees() {
  local worktrees="${1:?usage: install_bk_with_worktrees enabled|disabled}"
  capture bash "$INSTALL_SH"
  assert_rc_zero
  write_constitution "$worktrees"
  git add -A
  git commit --quiet -m "seed"
}

# ---- Assertions -------------------------------------------------------------
# Each assertion exits 1 on failure. Tests run in a subshell (see run.sh), so
# exiting aborts only the current test and the runner records it as a fail.

_fail() {
  echo "  ASSERTION FAILED: $1" >&2
  shift
  while (( $# > 0 )); do
    echo "    $1" >&2
    shift
  done
  exit 1
}

assert_eq() {
  local expected="$1" actual="$2" msg="${3:-values differ}"
  [[ "$expected" == "$actual" ]] && return 0
  _fail "$msg" "expected: $expected" "actual:   $actual"
}

assert_file_exists() {
  [[ -f "$1" ]] || _fail "expected file to exist: $1"
}

assert_file_missing() {
  [[ ! -f "$1" ]] || _fail "expected file to be missing: $1"
}

assert_dir_exists() {
  [[ -d "$1" ]] || _fail "expected dir to exist: $1"
}

assert_dir_missing() {
  [[ ! -d "$1" ]] || _fail "expected dir to be missing: $1"
}

assert_executable() {
  [[ -x "$1" ]] || _fail "expected file to be executable: $1"
}

assert_grep() {
  local pattern="$1" file="$2"
  [[ -f "$file" ]] || _fail "assert_grep: file not found: $file"
  grep -qE "$pattern" "$file" || _fail "expected '$file' to match: $pattern"
}

assert_branch_exists() {
  local branch="$1"
  git show-ref --verify --quiet "refs/heads/$branch" \
    || _fail "expected branch to exist: $branch"
}

# Run a command, capturing stdout/stderr/exit. Populates ASSERT_STDOUT,
# ASSERT_STDERR, ASSERT_RC. Returns 0 always so it never trips `set -e`.
capture() {
  ASSERT_STDOUT=""
  ASSERT_STDERR=""
  ASSERT_RC=0
  local _out _err
  _out="$(mktemp)"
  _err="$(mktemp)"
  "$@" >"$_out" 2>"$_err" || ASSERT_RC=$?
  ASSERT_STDOUT="$(cat "$_out")"
  ASSERT_STDERR="$(cat "$_err")"
  rm -f "$_out" "$_err"
  return 0
}

assert_rc_zero() {
  (( ASSERT_RC == 0 )) && return 0
  echo "  ASSERTION FAILED: expected exit 0, got $ASSERT_RC" >&2
  [[ -n "$ASSERT_STDOUT" ]] && echo "    stdout: $ASSERT_STDOUT" >&2
  [[ -n "$ASSERT_STDERR" ]] && echo "    stderr: $ASSERT_STDERR" >&2
  exit 1
}

assert_rc_nonzero() {
  (( ASSERT_RC != 0 )) && return 0
  echo "  ASSERTION FAILED: expected non-zero exit, got 0" >&2
  [[ -n "$ASSERT_STDOUT" ]] && echo "    stdout: $ASSERT_STDOUT" >&2
  [[ -n "$ASSERT_STDERR" ]] && echo "    stderr: $ASSERT_STDERR" >&2
  exit 1
}

assert_stderr_contains() {
  local needle="$1"
  [[ "$ASSERT_STDERR" == *"$needle"* ]] && return 0
  echo "  ASSERTION FAILED: expected stderr to contain: $needle" >&2
  echo "    stderr: $ASSERT_STDERR" >&2
  exit 1
}
