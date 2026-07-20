---
description: "Use when: review a detailed design against the approved subsystem spec, classify findings for the design review gate, and identify untraced requirement IDs"
name: "design-reviewer"
argument-hint: "Subsystem Specと詳細設計書を入力してください"
agent: "design-reviewer"
---
Review a detailed design for the G1 design review gate.

Requirements:
- Use [the review record template](../../templates/review-record.md).
- Use [the workflow and approval gate definition](../../workflow-approval-gate-definition.md).
- Classify findings as Design or Minor Fix.
- Record affected requirement IDs and design element IDs.
- Report whether any requirement IDs are untraced.

Checklist:
- Verify requirement coverage.
- Verify responsibility boundaries and dependency directions.
- Verify activity consistency.
- Verify error design and test design sufficiency.
- Verify testability.

## Knowledge Checks
- Independently re-resolve the design-time knowledge closure using .github/skills/knowledge-context-resolution/SKILL.md.
- Verify REQ references the required TERM / RULE IDs and DSG references the relevant ADR IDs.
- Verify referenced ADRs are Accepted and not Superseded, and that no ADR overrides a requirement or business rule.
- Flag unresolved knowledge or ADR references, use of obsolete or superseded knowledge, and significant decisions embedded without an ADR.