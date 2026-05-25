# install.sh scenarios.

TESTS=(
  test_install_init_creates_project
  test_install_fresh_in_existing_repo
  test_install_outside_repo_fails
  test_install_local_excludes
  test_install_update_preserves_constitution
  test_install_update_init_rejected
)

test_install_init_creates_project() {
  capture bash "$INSTALL_SH" --init demo
  assert_rc_zero
  assert_dir_exists demo
  assert_file_exists demo/.gitignore
  assert_dir_exists demo/specs
  assert_file_exists demo/.behavior-kit/memory/constitution.md
  assert_file_exists demo/.behavior-kit/scripts/init-feature.sh
  assert_file_exists demo/.claude/commands/bk.specify.md
  assert_file_exists demo/.cursor/rules/bk-specify.mdc
  assert_file_exists demo/.agents/skills/bk-specify/SKILL.md
  local branch commits
  branch=$(cd demo && git rev-parse --abbrev-ref HEAD)
  assert_eq "main" "$branch" "expected initial branch to be main"
  commits=$(cd demo && git log --oneline | wc -l | tr -d ' ')
  assert_eq "1" "$commits" "expected exactly one initial commit"
}

test_install_fresh_in_existing_repo() {
  init_git_repo
  capture bash "$INSTALL_SH"
  assert_rc_zero
  assert_file_exists .behavior-kit/scripts/init-feature.sh
  assert_file_exists .behavior-kit/scripts/init-session.sh
  assert_file_exists .behavior-kit/scripts/check-prereqs.sh
  assert_file_exists .behavior-kit/scripts/setup-worktrees.sh
  assert_file_exists .behavior-kit/memory/constitution.md
  assert_file_exists .behavior-kit/templates/spec-template.md
  assert_dir_exists specs
  assert_executable .behavior-kit/scripts/init-feature.sh
  assert_executable .behavior-kit/scripts/init-session.sh
  assert_executable .behavior-kit/scripts/check-prereqs.sh
  assert_executable .behavior-kit/scripts/setup-worktrees.sh
}

test_install_outside_repo_fails() {
  capture bash "$INSTALL_SH"
  assert_rc_nonzero
  assert_stderr_contains "not a git repository"
}

test_install_local_excludes() {
  init_git_repo
  capture bash "$INSTALL_SH" --local
  assert_rc_zero
  local exclude=".git/info/exclude"
  assert_file_exists "$exclude"
  assert_grep '\.claude/commands/bk\.\*\.md' "$exclude"
  assert_grep '\.cursor/rules/bk-\*\.mdc' "$exclude"
  assert_grep '\.agents/skills/bk-\*/' "$exclude"
  assert_grep '\.behavior-kit/' "$exclude"
  local before after
  before=$(wc -l < "$exclude" | tr -d ' ')
  capture bash "$INSTALL_SH" --local
  assert_rc_zero
  after=$(wc -l < "$exclude" | tr -d ' ')
  assert_eq "$before" "$after" "exclude file grew on idempotent rerun"
}

test_install_update_preserves_constitution() {
  init_git_repo
  capture bash "$INSTALL_SH"
  assert_rc_zero
  echo "SENTINEL_CONSTITUTION_TEXT" > .behavior-kit/memory/constitution.md
  echo "TAMPERED_INIT_FEATURE" > .behavior-kit/scripts/init-feature.sh
  capture bash "$INSTALL_SH" --update
  assert_rc_zero
  assert_grep "SENTINEL_CONSTITUTION_TEXT" .behavior-kit/memory/constitution.md
  # Non-preserved file should have been refreshed back to the real scaffold
  assert_grep "Usage: init-feature.sh" .behavior-kit/scripts/init-feature.sh
}

test_install_update_init_rejected() {
  capture bash "$INSTALL_SH" --update --init foo
  assert_rc_nonzero
  assert_stderr_contains "can't be used together"
}
