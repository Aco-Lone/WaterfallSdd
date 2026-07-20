---
description: "Use when: review completed implementation against approved design and implementation plan, classify post-G2 findings, and decide whether test execution can start"
name: "implementation-reviewer"
argument-hint: "承認済みDetailed Design、Implementation Plan、Test Plan、G2 review record、実装結果、変更ファイルを入力してください"
agent: "implementation-reviewer"
---
Review completed implementation after G2 approval.

Requirements:
- Use [the review record template](../../templates/review-record.md).
- Use [the workflow and approval gate definition](../../workflow-approval-gate-definition.md).
- Use `implementation-review` for implementation review checks.
- Classify findings with `implementation-execution-feedback-handling` as Design, Plan, Code, or Minor Fix.
- Record affected requirement IDs, design element IDs, implementation plan item IDs, and review IDs.
- Decide whether the next handoff is test-executor or a rework target.

Checklist:
- Verify all target PLN items are complete, blocked with reason, or explicitly not executed.
- Verify implementation does not override approved design decisions.
- Verify changed files and verification evidence are tied to REQ, DSG, and PLN IDs.
- Verify non-minor findings include REV, REQ, DSG, and PLN IDs.
- Verify Approved is used only when no open non-minor finding remains.

## Knowledge Checks
- Verify implementation and tests are based on the knowledge set approved at gate time and use no obsolete TERM / RULE / ADR.
- Flag new business knowledge left only in code, and classify reusable review insight as an improvement candidate.