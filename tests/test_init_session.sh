# init-session.sh scenarios.

TESTS=(
  test_init_session_valid
  test_init_session_invalid_tag
  test_init_session_empty_slug
  test_init_session_branch_collision
  test_init_session_worktrees_enabled
)

test_init_session_valid() {
  init_git_repo
  install_bk_with_worktrees disabled
  capture bash .behavior-kit/scripts/init-session.sh fix login-loop
  assert_rc_zero
  assert_branch_exists fix/login-loop
}

test_init_session_invalid_tag() {
  init_git_repo
  install_bk_with_worktrees disabled
  capture bash .behavior-kit/scripts/init-session.sh notatag foo
  assert_rc_nonzero
  assert_stderr_contains "is not one of"
}

test_init_session_empty_slug() {
  init_git_repo
  install_bk_with_worktrees disabled
  # All-punctuation slug normalizes to empty string.
  capture bash .behavior-kit/scripts/init-session.sh fix "!!!"
  assert_rc_nonzero
  assert_stderr_contains "slug is empty"
}

test_init_session_branch_collision() {
  init_git_repo
  install_bk_with_worktrees disabled
  capture bash .behavior-kit/scripts/init-session.sh fix login-loop
  assert_rc_zero
  git checkout --quiet main
  capture bash .behavior-kit/scripts/init-session.sh fix login-loop
  assert_rc_nonzero
  assert_stderr_contains "already exists"
}

test_init_session_worktrees_enabled() {
  init_git_repo
  install_bk_with_worktrees enabled
  capture bash .behavior-kit/scripts/init-session.sh fix login-loop
  assert_rc_zero
  assert_dir_exists .worktrees/fix-login-loop
  assert_branch_exists fix/login-loop
}
