---
description: "Use when: read the approved Detailed Design, Implementation Plan, Test Plan, and G2 review record after G2 approval, execute PLN by PLN with traceability preserved, and prepare the next handoff"
name: "implementation-executor"
argument-hint: "承認済みの詳細設計書、実装プラン、テストプラン、G2 review record、および対象csprojを入力してください"
agent: "implementation-executor"
---
Execute the approved implementation after G2 approval, then prepare the test-executor handoff.

Requirements:
- Treat the approved Detailed Design, Implementation Plan, Test Plan, G2 review record, and target csproj as the controlling inputs.
- Use [the implementation plan template](../../templates/implementation-plan.md), [the review record template](../../templates/review-record.md), and [the workflow and approval gate definition](../../workflow-approval-gate-definition.md).
- Preserve REQ, DSG, PLN, and REV traceability while executing and while handling feedback.
- Use Superpowers `using-git-worktrees` to isolate the run and confirm worktree setup before the first change.
- Capture baseline verification before editing any files.
- Use Superpowers `subagent-driven-development` for independent PLN slices and `executing-plans` for tightly coupled or sequence-sensitive PLN slices.
- Use Superpowers `test-driven-development` for test-first implementation and correction work.
- Use Superpowers `requesting-code-review` when a slice is ready for review.
- Use Superpowers `verification-before-completion` before declaring the work complete.
- Classify implementation feedback with `implementation-execution-feedback-handling` and return issues to Design, Plan, Code, or Minor Fix as required.
- Prepare the completion handoff payload for `test-executor`.

Checklist:
- Approved Detailed Design, Implementation Plan, Test Plan, G2 review record, and target csproj are present.
- Worktree isolation is in place before implementation starts.
- Baseline verification is captured before the first code change.
- The chosen execution mode matches the PLN coupling level.
- TDD is used where needed, and verification-before-completion is run before closure.
- Every changed item keeps REQ, DSG, PLN, and REV IDs explicit.
- Any feedback is classified with the correct return target before follow-up work.
- The completion handoff includes changed files, executed PLN items, verification results, open blockers, and the exact input `test-executor` needs.

Completion Handoff:
- Completed PLN items and their linked REQ, DSG, and REV IDs.
- Target csproj and changed files.
- Baseline verification and final verification results.
- Open blockers, unresolved feedback, and the selected return target if work is not complete.
- Any assumptions or environment notes needed by `test-executor`.

PostToolUse-context:
No traceability artifacts changed.