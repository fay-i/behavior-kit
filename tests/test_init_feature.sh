# init-feature.sh scenarios.

TESTS=(
  test_init_feature_fresh_repo
  test_init_feature_increments
  test_init_feature_worktrees_enabled
  test_init_feature_collision_retry
)

# Regression for the pipefail bug: with no prior features anywhere, the
# numbering pipeline produced an empty stream, grep exited non-zero, and
# pipefail killed the script before LAST=${LAST:-0} could fire.
test_init_feature_fresh_repo() {
  init_git_repo
  install_bk_with_worktrees disabled
  capture bash .behavior-kit/scripts/init-feature.sh foo
  assert_rc_zero
  assert_dir_exists specs/001-foo
  assert_branch_exists feature/001-foo
}

test_init_feature_increments() {
  init_git_repo
  install_bk_with_worktrees disabled
  capture bash .behavior-kit/scripts/init-feature.sh foo
  assert_rc_zero
  git checkout --quiet main
  capture bash .behavior-kit/scripts/init-feature.sh bar
  assert_rc_zero
  assert_dir_exists specs/002-bar
  assert_branch_exists feature/002-bar
}

test_init_feature_worktrees_enabled() {
  init_git_repo
  install_bk_with_worktrees enabled
  capture bash .behavior-kit/scripts/init-feature.sh foo
  assert_rc_zero
  assert_dir_exists .worktrees/001-foo
  assert_dir_exists .worktrees/001-foo/specs/001-foo
  # Main checkout must not have the spec dir
  assert_dir_missing specs/001-foo
  assert_branch_exists feature/001-foo
}

test_init_feature_collision_retry() {
  init_git_repo
  install_bk_with_worktrees disabled
  # Pre-seed a 001 spec dir without a corresponding branch so the
  # defense-in-depth retry kicks in.
  mkdir -p specs/001-foo
  capture bash .behavior-kit/scripts/init-feature.sh foo
  assert_rc_zero
  assert_dir_exists specs/002-foo
  assert_branch_exists feature/002-foo
}
