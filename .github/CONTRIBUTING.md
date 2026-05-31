# Contributing to behavior-kit

Thanks for your interest in improving behavior-kit! It's a Bash-based scaffold and
installer that drops a behavior-first development workflow into Claude Code, Cursor, and
Codex projects. There's no build step and no runtime dependencies beyond `bash` and
`git`.

## Getting started

```bash
git clone https://github.com/fay-i/behavior-kit.git
cd behavior-kit
```

The scaffold lives in `scaffold/`, the installer is `install.sh`, and the test suite is
in `tests/`.

## Running the tests

```bash
bash tests/run.sh
```

CI runs the same suite on every push and pull request via
`.github/workflows/test.yml`, pointing the installer at the local scaffold with
`BEHAVIOR_KIT_BASE_URL=file://<workspace>/scaffold` so no network calls are made. Please
make sure the suite is green locally before opening a PR.

## Branch naming

This project dogfoods its own workflow, so branches follow the behavior-kit conventions
enforced by `scaffold/.behavior-kit/scripts/check-prereqs.sh`:

- **Features:** `feature/NNN-slug` (e.g. `feature/012-update-flag`).
- **One-off changes:** a conventional session tag — one of `fix/`, `chore/`,
  `refactor/`, `docs/`, `test/`, `ci/`, `build/`, `perf/`, `style/`, `revert/` — followed
  by a slug (e.g. `docs/community-standards`). Never use `feat/`.

Work happens off `main`; PRs target `main`.

## Commit messages

- Behavior commits (from `/bk.implement`) are prefixed `B001: …`, `B002: …`.
- PR-review commits (from `/bk.iterate`) are prefixed `R1.01: …`, `R1.02: …`.
- Otherwise, write a concise, single-line subject describing the change.

Keep messages to a single line; don't add metadata or attribution trailers.

## Pull requests

1. Branch from `main` using the naming convention above.
2. Make your change and add or update tests in `tests/` where it makes sense.
3. Run `bash tests/run.sh` and confirm it passes.
4. Update `README.md` if you've changed user-facing behavior.
5. Open a PR against `main` and fill out the template.

By participating you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).
