---
description: "Use when: review an implementation plan and test plan against approved design, classify findings for the plan review gate, and identify untraced requirement or design element IDs"
name: "plan-reviewer"
argument-hint: "承認済み詳細設計書と実装プランおよびテストプランを入力してください"
agent: "plan-reviewer"
---
Review an implementation plan and test plan for the G2 plan review gate.

Requirements:
- Use [the review record template](../../templates/review-record.md).
- Use [the workflow and approval gate definition](../../workflow-approval-gate-definition.md).
- Classify findings as Design, Plan, or Minor Fix.
- Record affected requirement IDs, design element IDs, implementation plan item IDs, and test IDs.
- Report whether any requirement IDs or design element IDs are untraced.

Checklist:
- Verify neither plan overrides approved design.
- Verify sequence, preparation, and granularity across both plans.
- Verify parallel execution assumptions.
- Verify full traceability from requirement to both plans.

## Knowledge Checks
- Verify the plan preserves the approved knowledge references and introduces no new business rule or design decision.
- Flag any knowledge or ADR issue closed inside the plan and return it to design instead.