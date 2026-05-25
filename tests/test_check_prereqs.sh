# check-prereqs.sh scenarios.

TESTS=(
  test_check_prereqs_specify_on_main_ok
  test_check_prereqs_implement_on_main_rejected
  test_check_prereqs_implement_outside_worktree_rejected
  test_check_prereqs_implement_inside_worktree_ok
  test_check_prereqs_no_constitution_rejected
  test_check_prereqs_iterate_on_session_branch_ok
  test_check_prereqs_iterate_on_ci_session_branch_ok
  test_check_prereqs_iterate_inside_session_worktree_ok
  test_check_prereqs_iterate_session_outside_worktree_rejected
  test_check_prereqs_implement_on_session_branch_rejected
  test_check_prereqs_iterate_on_legacy_branch_ok
)

test_check_prereqs_specify_on_main_ok() {
  init_git_repo
  install_bk_with_worktrees disabled
  capture bash .behavior-kit/scripts/check-prereqs.sh specify
  assert_rc_zero
}

test_check_prereqs_implement_on_main_rejected() {
  init_git_repo
  install_bk_with_worktrees disabled
  capture bash .behavior-kit/scripts/check-prereqs.sh implement
  assert_rc_nonzero
  assert_stderr_contains "refuses to run on"
}

# On the feature branch but in the main checkout (not inside the worktree).
# Construct the branch directly so we end up checked out on it in the main
# checkout — init-feature.sh in worktrees mode leaves the main checkout on main.
test_check_prereqs_implement_outside_worktree_rejected() {
  init_git_repo
  install_bk_with_worktrees enabled
  git checkout -b feature/001-foo --quiet
  capture bash .behavior-kit/scripts/check-prereqs.sh implement
  assert_rc_nonzero
  assert_stderr_contains "must run inside '.worktrees/"
}

test_check_prereqs_implement_inside_worktree_ok() {
  init_git_repo
  install_bk_with_worktrees enabled
  capture bash .behavior-kit/scripts/init-feature.sh foo
  assert_rc_zero
  cd .worktrees/001-foo
  capture bash .behavior-kit/scripts/check-prereqs.sh implement
  assert_rc_zero
}

test_check_prereqs_iterate_on_session_branch_ok() {
  init_git_repo
  install_bk_with_worktrees disabled
  git checkout -b fix/some-bug --quiet
  capture bash .behavior-kit/scripts/check-prereqs.sh iterate
  assert_rc_zero
}

test_check_prereqs_iterate_on_ci_session_branch_ok() {
  init_git_repo
  install_bk_with_worktrees disabled
  git checkout -b ci/workflow-tweak --quiet
  capture bash .behavior-kit/scripts/check-prereqs.sh iterate
  assert_rc_zero
}

test_check_prereqs_iterate_inside_session_worktree_ok() {
  init_git_repo
  install_bk_with_worktrees enabled
  capture bash .behavior-kit/scripts/init-session.sh ci workflow-tweak
  assert_rc_zero
  cd .worktrees/ci-workflow-tweak
  capture bash .behavior-kit/scripts/check-prereqs.sh iterate
  assert_rc_zero
}

test_check_prereqs_iterate_session_outside_worktree_rejected() {
  init_git_repo
  install_bk_with_worktrees enabled
  git checkout -b fix/some-bug --quiet
  capture bash .behavior-kit/scripts/check-prereqs.sh iterate
  assert_rc_nonzero
  assert_stderr_contains "must run inside '.worktrees/fix-some-bug/"
}

test_check_prereqs_implement_on_session_branch_rejected() {
  init_git_repo
  install_bk_with_worktrees disabled
  git checkout -b fix/some-bug --quiet
  capture bash .behavior-kit/scripts/check-prereqs.sh implement
  assert_rc_nonzero
  assert_stderr_contains "expects a 'feature/NNN-slug' branch"
}

test_check_prereqs_iterate_on_legacy_branch_ok() {
  # Branches that predate init-session.sh (any non-trunk name, no enforced
  # prefix or worktree path convention) must still work with /bk.iterate.
  init_git_repo
  install_bk_with_worktrees enabled
  git checkout -b mf/legacy-branch --quiet
  capture bash .behavior-kit/scripts/check-prereqs.sh iterate
  assert_rc_zero
}

test_check_prereqs_no_constitution_rejected() {
  init_git_repo
  capture bash "$INSTALL_SH"
  assert_rc_zero
  rm -f .behavior-kit/memory/constitution.md
  capture bash .behavior-kit/scripts/check-prereqs.sh specify
  assert_rc_nonzero
  assert_stderr_contains "Constitution not found"
}
