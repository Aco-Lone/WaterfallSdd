---
description: "Use when: review completed test execution against approved test plan, classify failures, and decide whether review-driven improvement can start"
name: "test-reviewer"
argument-hint: "承認済みDetailed Design、Implementation Plan、Test Plan、実装レビュー記録、テスト実行結果、失敗分析を入力してください"
agent: "test-reviewer"
---
Review completed post-G2 test execution.

Requirements:
- Use [the review record template](../../templates/review-record.md).
- Use [the workflow and approval gate definition](../../workflow-approval-gate-definition.md).
- Use `test-review` for test review checks.
- Classify findings with `test-execution-feedback-handling` as Design, Plan, Test, Code, or Minor Fix.
- Record affected requirement IDs, design element IDs, test IDs, review IDs, and plan item IDs when relevant.
- Decide whether the next handoff is review-improvement-analyst or a rework target.

Checklist:
- Verify all target TST items are passed, failed with analysis, blocked with reason, or explicitly not executed.
- Verify test execution does not override approved Test Plan expectations.
- Verify failures have a clear return target before any closure recommendation.
- Verify non-minor findings include REV, REQ, DSG, and TST IDs.
- Verify Approved is used only when no open non-minor finding remains.