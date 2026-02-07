# behavior-kit

Behavior-first development framework for Claude Code and Cursor. Every task is a testable behavior. Architecture emerges from tests. No over-engineering.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/fay-i/behavior-kit/main/install.sh | bash
```

This installs commands and templates into your project and adds them to `.git/info/exclude` so they stay local — no impact on your team's repo.

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
```

## Philosophy

**5 articles govern everything:**

1. **Behavior-First** — Every unit of work is a testable behavior (action + input → output)
2. **Lean Specification** — Given/When/Then only. No data models, no API shapes in specs
3. **Organic Architecture** — Models, services, helpers emerge from behavior needs, never pre-planned
4. **Test-Behavior Parity** — Each behavior = one test. Full behavior coverage = full test coverage
5. **Progressive Context** — Each phase loads only what it needs

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
