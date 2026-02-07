# Project Constitution

## Article I — Behavior-First
Every unit of work is a testable behavior: an action with defined input and expected output. Implementation details (models, services, helpers) emerge from making behaviors pass. Never pre-plan architecture.

## Article II — Lean Specification
Specs use Given/When/Then acceptance criteria. They describe WHAT the system does and WHY, never HOW. No data models, no API shapes, no technology choices in specs.

## Article III — Organic Architecture
YAGNI, DRY, SRP. Create abstractions only when a behavior demands them. Three similar lines are better than a premature abstraction. Models, services, and helpers emerge from behavior needs.

## Article IV — Test-Behavior Parity
Each behavior maps to exactly one test. Full behavior coverage guarantees full test coverage. If a behavior can't be tested, it's not a behavior — decompose it further.

## Article V — Progressive Context
Each phase loads only what it needs. Specify loads the constitution. Plan loads the spec + codebase. Behaviors loads the plan. Implement loads one behavior at a time.

---

_Add project-specific articles below (Article VI+):_
