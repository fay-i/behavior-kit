---
description: "Research existing codebase context for a feature spec"
---

# /bk.plan — The CONTEXT (Research Only)

You are researching the codebase to provide context for implementing a feature. The user will provide the feature directory as $ARGUMENTS (e.g., `specs/001-user-login`), or you should identify the current feature from the active branch.

## Instructions

1. Read the constitution at `.behavior-kit/memory/constitution.md`
2. Read the spec at `specs/NNN-feature-name/spec.md`
3. Read the plan template at `.behavior-kit/templates/plan-template.md`
4. Explore the existing codebase thoroughly:
   - Identify patterns and conventions already in use
   - Find code that the feature will interact with
   - Note external dependencies or contracts
5. Write the plan to `specs/NNN-feature-name/plan.md`

## Rules
- Document EXISTING patterns, not proposed ones
- Reference snippets come from EXISTING code only
- Open questions must include a proposed answer
- This is research, not design

## Forbidden
- Inventing data models or schemas
- Proposing API contracts or endpoint shapes
- Suggesting project structure or new directories
- Writing new code or pseudocode
- Making architectural decisions not already present in the codebase

## Output
`specs/NNN-feature-name/plan.md`
