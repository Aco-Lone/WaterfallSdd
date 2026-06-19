# Impact Map Template

## Document Control

| Field | Value |
| --- | --- |
| Change ID |  |
| Related Spec Delta | spec-delta.md |
| Status | Draft / In Review / Approved / Archived |
| Author |  |
| Reviewer |  |

## Mapping Principles

- This document points to the existing csproj baseline artifacts that this change affects.
- It does not duplicate design, plan, or test content. It only references their IDs.
- Every requirement ID in the spec delta must appear in this map.
- ADDED and MODIFIED rows must name at least one affected csproj.
- REMOVED rows must set Re-review Required to Yes so downstream references are cleaned up.

## Impact Map

| Impact ID | Requirement ID | Operation | Affected csproj | Affected Design Element IDs | Affected Plan Item IDs | Affected Test IDs | Re-review Required | Gate Record |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| IMP-001 | REQ-010 | ADDED | Sample.Core | DSG-001 | PLN-001 | TST-001 | Yes | reviews/REV-001.md |
| IMP-002 | REQ-003 | MODIFIED | Sample.Core | DSG-002 | PLN-002 | TST-002 | Yes | reviews/REV-001.md |
| IMP-003 | REQ-005 | REMOVED | Sample.Core | DSG-003 | PLN-003 | TST-003 | Yes | reviews/REV-001.md |

## Approval

| Role | Name | Decision | Date | Notes |
| --- | --- | --- | --- | --- |
| Author |  | Approved / Rework |  |  |
| Reviewer |  | Approved / Rework |  |  |
