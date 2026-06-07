---
description: "Use when: create or refine an OpenSpec subsystem specification from upper design requirements, assign requirement IDs, and define boundaries and acceptance criteria"
name: "subsystem-spec-author"
argument-hint: "上位設計のサブシステム要件、制約、非機能要件を入力してください"
agent: "subsystem-spec-author"
---
Create or update an OpenSpec subsystem specification.

Requirements:
- Use [the subsystem spec template](../../templates/subsystem-spec.md).
- Preserve existing requirement IDs unless the requirement meaning changes.
- Assign new requirement IDs when new requirements are introduced.
- Keep scope, boundaries, acceptance criteria, and unresolved items explicit.
- Return a completed specification draft plus a short list of unresolved items.

Checklist:
- Define in-scope and out-of-scope boundaries.
- Record every requirement with a unique requirement ID.
- Ensure acceptance criteria exist for each requirement.
- Highlight missing decisions instead of guessing.