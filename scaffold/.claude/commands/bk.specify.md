---
description: "Generate a behavior-first spec with Given/When/Then acceptance criteria"
---

# /bk.specify — The WHAT and WHY

You are writing a feature specification. The user will provide a feature description as $ARGUMENTS.

## Instructions

1. Read the constitution at `.behavior-kit/memory/constitution.md`
2. Run `.behavior-kit/scripts/init-feature.sh "$ARGUMENTS"` to create the feature branch and directory
3. Read the spec template at `.behavior-kit/templates/spec-template.md`
4. Ask the user up to 3 inline clarification questions if needed (do not stop to wait — batch them)
5. Write the spec to `specs/NNN-feature-name/spec.md`

## Rules
- User story format: As a [role], I want to [action], So that [outcome]
- Every acceptance criterion uses Given/When/Then
- Include edge cases and out-of-scope sections
- Max 3 inline clarification questions — no separate clarify phase

## Forbidden
- Technology mentions (frameworks, languages, databases)
- Data models or schemas
- API shapes or endpoint definitions
- FR-tables or numbered requirement lists
- Implementation checklists

## Output
`specs/NNN-feature-name/spec.md`
