---
description: "Monitor a PR's automated review loop: address critical/major CodeRabbit findings (and sensible minors) until the review is clean and checks are green"
---

# /bk.monitor — PR Review Monitor Loop

You are monitoring a pull request until it is merge-ready. Input: a PR number (and repo, if not the current one).

## The loop

1. **Wait for the CodeRabbit review round.** Poll the PR — reviews and comments authored by `coderabbitai` / `coderabbitai[bot]` — until the round covering the latest push is posted. Watch status checks alongside (`gh pr checks`). Use bounded waits between polls (~60–90s). If no review activity appears within 15 minutes of the last push, post `@coderabbitai review` once to trigger a round; if still nothing after another 15 minutes, stop and escalate.
2. **Triage findings by severity.** CodeRabbit severities are **trivial / minor / major / critical**.
   - **Critical and major findings MUST all be addressed** — fixed, or rebutted with concrete evidence if wrong.
   - **Minor findings are at your discretion**: apply the sensible ones (safe, clearly an improvement); decline the rest in a reply with a short reason.
   - **Trivial findings** are optional; decline or acknowledge briefly.
3. **Fix on the PR branch.** Constitution rules hold: TDD for behavior changes (red → green), no skips/ignores/bypasses, single-line commits `type: subject` (no bodies, no trailers). Run the repo's full checks locally before pushing.
4. **Respond to every critical/major thread** (and every minor you acted on or declined). Reply describing the fix and referencing the commit — or, if the finding is wrong, a concrete technical rebuttal with evidence. No critical or major thread may be left unanswered.
5. **Push and wait for the follow-up round.** CodeRabbit re-reviews on push. Repeat from step 1.

## Exit conditions

- **Success:** a full review round produces zero new critical or major findings AND all status checks are green (SKIPPED is non-blocking). Report: rounds run, findings fixed (with commits), findings declined (with reasons), final check state.
- **Stop and escalate** (report to the orchestrator/owner; never loop forever): more than 5 review rounds; a finding demands a design change beyond the PR's scope; checks fail for reasons unrelated to the PR; CodeRabbit unresponsive per step 1.

## Rules

- NEVER merge the PR yourself — merging is the owner's decision.
- Never force-push over review history unless a rebase onto the base branch is required; when you must, say so in a PR comment.
- Never dismiss or resolve a review thread without a substantive reply.
