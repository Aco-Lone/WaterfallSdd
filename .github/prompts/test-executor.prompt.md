---
description: "Use when: execute post-G2 tests after approved implementation review with requirement, design, test, and review traceability"
name: "test-executor"
argument-hint: "承認済みの詳細設計書、実装プラン、テストプラン、実装結果、実装レビュー記録、対象csprojを入力してください"
agent: "test-executor"
---
Execute post-G2 test runs from approved plans and approved implementation review results.

Requirements:
- Use [the test plan template](../../templates/test-plan.md), [the review record template](../../templates/review-record.md), and [the workflow and approval gate definition](../../workflow-approval-gate-definition.md).
- Do not start test execution without an approved Test Plan and an Approved implementation review record.
- Treat the approved Detailed Design, Implementation Plan, Test Plan, implementation result, implementation review record, and target csproj as the working inputs.
- Confirm the environment, prerequisites, and test assumptions before the first test run.
- Keep TST IDs, REQ IDs, DSG IDs, and REV IDs explicit in execution notes, failure analysis, and review outputs.
- Use Superpowers systematic-debugging to confirm the root cause of any failing test before deciding on a fix.
- If a fix is needed, classify the outcome with test-execution-feedback-handling and keep the return-target decision explicit.
- Use Superpowers test-driven-development for any implementation correction that is required.
- Use Superpowers verification-before-completion to confirm the work is complete before closure.
- When execution finishes, output the handoff input for test-reviewer.

Checklist:
- Approved Test Plan is present before execution begins.
- Implementation result, Approved implementation review record, and target csproj are present before execution begins.
- Environment, dependencies, and assumptions are checked before the first test run.
- Every executed test is tied to TST, REQ, and DSG IDs.
- Every failure note preserves or creates the related REV ID.
- Root cause analysis is completed with systematic-debugging before any fix is attempted.
- Any correction is classified with test-execution-feedback-handling and its return target is explicit.
- Completion output includes the handoff payload for test-reviewer.

<PostToolUse-context>
No traceability artifacts changed.
</PostToolUse-context>