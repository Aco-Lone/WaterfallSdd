---
description: "Use when: create or refine an OpenSpec subsystem specification from upper design requirements, use Superpowers brainstorming to confirm and sharpen requirements, assign requirement IDs, and define boundaries and acceptance criteria"
name: "subsystem-spec-author"
argument-hint: "上位設計のサブシステム要件、制約、非機能要件を入力してください"
agent: "subsystem-spec-author"
---
Create or update an OpenSpec subsystem specification.

Process:
- Check out the current project state first (files, docs, recent commits).
- Before asking detailed questions, assess scope. If the request is too large for a single subsystem specification, decompose it and focus on the first subsystem.
- Ask clarifying questions one at a time to refine the idea and understand purpose, constraints, and success criteria.
- Propose 2-3 different approaches with trade-offs, lead with the recommended option, and explain why.
- Present the subsystem specification in sections and get user approval before finalizing the draft.

Requirements:
- Do not draft or refine the subsystem specification until the specification direction has been presented and approved.
- Use [the subsystem spec template](../../templates/subsystem-spec.md).
- Preserve existing requirement IDs unless the requirement meaning changes.
- Assign new requirement IDs when new requirements are introduced.
- Keep scope, boundaries, acceptance criteria, and unresolved items explicit.
- Return a completed specification draft plus a short list of unresolved items.

Checklist:
- Explore project context before drafting.
- Confirm requirement intent and subsystem boundaries through iterative questions.
- Propose 2-3 framing approaches before drafting.
- Get approval on the specification direction before finalizing.
- Define in-scope and out-of-scope boundaries.
- Record every requirement with a unique requirement ID.
- Ensure acceptance criteria exist for each requirement.
- Highlight missing decisions instead of guessing.