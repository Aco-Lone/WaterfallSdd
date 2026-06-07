---
description: "Use when: create a detailed design from an approved subsystem spec, including class structure, actor-partitioned activity diagrams, error design, test design, and requirement traceability"
name: "detailed-design-author"
argument-hint: "承認済みのSubsystem Specと対象csprojを入力してください"
agent: "detailed-design-author"
---
Create or update a detailed design document from an approved subsystem specification.

Requirements:
- Use [the detailed design template](../../templates/detailed-design.md).
- Use [the workflow and approval gate definition](../../workflow-approval-gate-definition.md) as the review baseline.
- Include class and component structure, actor-partitioned activity design, error design, and test design.
- Keep requirement IDs and design element IDs explicit.
- Do not include implementation order, effort, or ownership decisions.

Checklist:
- Every requirement ID maps to at least one design element ID.
- Activity diagrams match the design body.
- Error handling and test design are explicit.
- Open issues are listed without hiding uncertainty.