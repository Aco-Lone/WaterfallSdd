---
description: "Use when: convert an approved detailed design into a csproj-based implementation plan with requirement and design traceability"
name: "implementation-planner"
argument-hint: "承認済みの詳細設計書と対象csprojを入力してください"
agent: "implementation-planner"
---
Create or update an implementation plan from an approved detailed design.

Requirements:
- Use [the implementation plan template](../../templates/implementation-plan.md).
- Do not change approved design decisions.
- Keep plan item IDs, requirement IDs, and design element IDs explicit.
- Build the sequence by dependency order and execution feasibility.
- Return the completed plan and any blockers that require review.

Checklist:
- Every plan item traces back to requirements and design.
- Environment and preparation are explicit.
- Work granularity is executable.
- Parallel work assumptions are stated.