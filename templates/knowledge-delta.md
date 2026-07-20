# Knowledge Delta Template

## Document Control

| Field | Value |
| --- | --- |
| Change ID |  |
| Related Spec Delta | spec-delta.md |
| Status | Draft / In Review / Approved / Archived |
| Author |  |
| Reviewer |  |

## Delta Principles

- This document records only the difference against the baseline glossary and business rules.
- Do not edit the baseline knowledge directly. The baseline is updated only by the archive operation.
- Operation maps one-to-one to the knowledge ID rule:
  - ADDED: a new TERM / RULE ID that does not exist in the baseline.
  - MODIFIED: an existing baseline TERM / RULE ID whose content changes while keeping the meaning; keep the same ID.
  - REMOVED: an existing baseline TERM / RULE ID that becomes obsolete; do not delete the ID, mark it Obsolete.
- When the meaning becomes a different concept, do not reuse the existing ID. Assign a new ID.

## Knowledge Delta

| Delta ID | Operation | Knowledge ID | Kind | Summary | Related Requirement IDs | Rationale |
| --- | --- | --- | --- | --- | --- | --- |
| KDL-001 | ADDED | AUTH-TERM-010 | TERM | New term definition | REQ-010 | Why this is added |
| KDL-002 | MODIFIED | AUTH-RULE-003 | RULE | Updated rule content | REQ-003 | Why this changes |
| KDL-003 | REMOVED | AUTH-TERM-005 | TERM |  | REQ-005 | Why this is retired |

## Approval

| Role | Name | Decision | Date | Notes |
| --- | --- | --- | --- | --- |
| Author |  | Approved / Rework |  |  |
| Reviewer |  | Approved / Rework |  |  |
