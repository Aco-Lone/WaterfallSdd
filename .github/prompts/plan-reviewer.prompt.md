---
description: "Use when: review an implementation and test plan against approved design, classify findings for the plan review gate, and identify untraced requirement or design element IDs"
name: "plan-reviewer"
argument-hint: "承認済み詳細設計書と実装・テストプランを入力してください"
agent: "plan-reviewer"
---
Review an implementation and test plan for the G2 plan review gate.

Requirements:
- Use [the review record template](../../templates/review-record.md).
- Use [the workflow and approval gate definition](../../workflow-approval-gate-definition.md).
- Classify findings as Design, Plan, or Minor Fix.
- Record affected requirement IDs, design element IDs, and plan item IDs.
- Report whether any requirement IDs or design element IDs are untraced.

Checklist:
- Verify the plan does not override approved design.
- Verify sequence, preparation, and granularity.
- Verify parallel execution assumptions.
- Verify full traceability from requirement to plan.