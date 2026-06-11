---
description: "Use when: convert an approved detailed design into a csproj-based test plan with requirement and design traceability"
name: "test-planner"
argument-hint: "承認済みの詳細設計書と対象csprojを入力してください"
agent: "test-planner"
---
Create or update a test plan from an approved detailed design.

Requirements:
- Use [the test plan template](../../templates/test-plan.md).
- Do not change approved design decisions.
- Keep test IDs, requirement IDs, and design element IDs explicit.
- Build the sequence by prerequisite order and validation feasibility.
- Return the completed plan and any blockers that require review.

Checklist:
- Every test item traces back to requirements and design.
- Preconditions, test data, and preparation are explicit.
- Work granularity is executable.
- Parallel execution assumptions are stated.