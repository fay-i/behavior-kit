# behavior-kit

Behavior-first development framework for Claude Code and Cursor. Every task is a testable behavior. Architecture emerges from tests. No over-engineering.

## Install

**New project:**
```bash
curl -fsSL https://raw.githubusercontent.com/fay-i/behavior-kit/main/install.sh | bash -s -- --init my-project
```

**Existing repo:**
```bash
curl -fsSL https://raw.githubusercontent.com/fay-i/behavior-kit/main/install.sh | bash
```

**Local-only install** (hidden from git, won't affect teammates):
```bash
curl -fsSL https://raw.githubusercontent.com/fay-i/behavior-kit/main/install.sh | bash -s -- --local
```

The `--local` flag adds behavior-kit paths to `.git/info/exclude` so the files stay invisible to git.

**Shell helper** (optional) — add to your `.zshrc` or `.bashrc`:
```bash
bk() { curl -fsSL https://raw.githubusercontent.com/fay-i/behavior-kit/main/install.sh | bash -s -- "$@"; }
```

Then use `bk`, `bk --local`, or `bk --init my-project`.

## Workflow

```
/bk.constitution     Define project principles (once)
        ↓
/bk.specify          Write a feature spec (Given/When/Then)
        ↓
/bk.plan             Research existing codebase context
        ↓
/bk.behaviors        Decompose into atomic, testable behaviors
        ↓
/bk.implement        Execute behaviors test-first (red → green → refactor)
        ↓
   push & open PR
        ↓
/bk.iterate          Address PR review feedback (re-run per round)
```

## Commands

Each command is a slash command in Claude Code (and an equivalent rule in Cursor). All feature-scoped commands accept the feature directory as an argument (e.g. `/bk.plan specs/001-user-login`) or infer it from the current branch.

| Command | Purpose | Reads | Writes |
| --- | --- | --- | --- |
| `/bk.constitution` | Define or amend the 5 foundational articles plus any project-specific ones. Run once per project. | `.behavior-kit/memory/constitution.md` | `.behavior-kit/memory/constitution.md` |
| `/bk.specify <description>` | Turn a feature idea into a Given/When/Then spec. Creates the feature branch and `specs/NNN-feature-name/` directory via `init-feature.sh`. Max 3 inline clarifying questions. | constitution, spec template | `specs/NNN-feature-name/spec.md` |
| `/bk.plan` | Research-only pass over the existing codebase to capture patterns, touch points, and open questions. Does not propose architecture. | constitution, `spec.md`, plan template, codebase | `specs/NNN-feature-name/plan.md` |
| `/bk.behaviors` | Decompose each acceptance criterion into atomic behaviors (Action + Input + Output + Test) with branches for edges/errors. Builds an AC → behavior coverage matrix. | constitution, `spec.md`, `plan.md`, behavior template | `specs/NNN-feature-name/behaviors.md` |
| `/bk.implement` | Execute behaviors one at a time, test-first (red → green → refactor). Commits each as `B001: …`. Architecture (models, helpers, routes) emerges as behaviors demand it. | constitution, `behaviors.md` | source code + tests; commits per behavior |
| `/bk.iterate` | Address one round of PR review feedback. Fetches comments via `gh`, categorizes them, makes changes one comment at a time, replies and resolves threads. Commits as `R1.01: …`. Re-run per round. | constitution, feature dir, PR comments via `gh` | code changes, GitHub replies, `specs/NNN-feature-name/review.md` |

All feature-scoped commands run `.behavior-kit/scripts/check-prereqs.sh` first and stop if prerequisites are missing (e.g. no constitution, no spec). `/bk.iterate` additionally requires an authenticated `gh` CLI and an open PR on the current branch.

## Philosophy

**5 articles govern everything:**

1. **Behavior-First** — Every unit of work is a testable behavior (action + input → output)
2. **Lean Specification** — Given/When/Then only. No data models, no API shapes in specs
3. **Organic Architecture** — Models, services, helpers emerge from behavior needs, never pre-planned
4. **Test-Behavior Parity** — Each behavior = one test. Full behavior coverage = full test coverage
5. **Progressive Context** — Each phase loads only what it needs

## PR Review Iteration

After `/bk.implement`, push your branch and open a PR. When reviewers leave feedback, run `/bk.iterate` to address it:

- Fetches all review comments via `gh`
- Categorizes each as actionable, question, or acknowledgment
- Makes code changes one comment at a time (test-first when needed)
- Replies on GitHub and resolves threads
- Commits as `R1.01: [description]`, `R1.02: ...`
- Tracks everything in `specs/NNN-feature-name/review.md`

Re-run `/bk.iterate` for each new round of feedback. The round number auto-increments.

## What this is NOT

- No data model templates (models emerge from behaviors)
- No API contract phase (endpoints emerge from behaviors)
- No agent personas or role-play
- No epic/story/task hierarchy (flat: Story → Behaviors)
- No separate clarify/analyze/checklist commands (behaviors ARE the checklist)

## Behavior Format

```markdown
## B001: Authenticate user with valid credentials
**From**: AC-1 | **Depends on**: —
**Action**: Submit login form with valid credentials
**Input**: email: string, password: string
**Output**: Authenticated session, redirect to dashboard
**Test**: Given valid credentials, when form submitted, then session created and redirected

### Branches
- **B001a: Invalid email format**
  Input: email: 'not-an-email' | Output: Validation error | Test: [...]
- **B001b: Wrong password**
  Input: valid email, wrong password | Output: Auth error | Test: [...]
```

## Uninstall

Remove the installed files:

```bash
rm -rf .claude/commands/bk.*.md .cursor/rules/bk-*.mdc .behavior-kit/
```
