---
description: "Use when: convert an approved detailed design into a csproj-based implementation and test plan with requirement and design traceability"
name: "implementation-planner"
argument-hint: "承認済みの詳細設計書と対象csprojを入力してください"
agent: "implementation-planner"
---
Create or update an implementation and test plan from an approved detailed design.

Requirements:
- Use [the implementation and test plan template](../../templates/implementation-test-plan.md).
- Do not change approved design decisions.
- Keep plan item IDs, requirement IDs, design element IDs, and test IDs explicit.
- Build the sequence by dependency order and execution feasibility.
- Return the completed plan and any blockers that require review.

Checklist:
- Every plan item traces back to requirements and design.
- Test order and preparation are explicit.
- Work granularity is executable.
- Parallel work assumptions are stated.