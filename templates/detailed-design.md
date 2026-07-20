# Detailed Design Template

## Document Control

| Field | Value |
| --- | --- |
| Target csproj |  |
| Subsystem Name |  |
| Related Spec |  |
| Version |  |
| Status | Draft / In Review / Approved / Obsolete |
| Author |  |
| Reviewer |  |
| Created Date |  |
| Updated Date |  |

## Design Overview

- Describe the design intent for the target csproj.
- Do not define work sequence here. This document defines structure and behavior only.

## Traceability Summary

| Requirement ID | Design Element ID | Class / Component | Activity ID | Error ID | Test Design ID | Coverage Status |
| --- | --- | --- | --- | --- | --- | --- |
| REQ-001 | DSG-001 |  | ACT-001 | ERR-001 | TST-001 | Covered / Partial / Missing |

## Class and Component Structure

| Design Element ID | Class / Component | Responsibility | Inputs | Outputs | Dependencies | Related Requirement IDs |
| --- | --- | --- | --- | --- | --- | --- |
| DSG-001 |  |  |  |  |  | REQ-001 |

## Actor and Activity Design

### Actor Mapping

| Activity ID | Actor / Class | Responsibility | Trigger | Related Requirement IDs |
| --- | --- | --- | --- | --- |
| ACT-001 |  |  |  | REQ-001 |

### Activity Diagram

- Insert activity diagram here.
- The activity diagram must be partitioned by actor or class-level responsibility.

## Error Design

| Error ID | Related Requirement IDs | Related Design Element IDs | Trigger Condition | Handling Strategy | Propagation | Recovery / Logging |
| --- | --- | --- | --- | --- | --- | --- |
| ERR-001 | REQ-001 | DSG-001 |  |  |  |  |

## Test Design

| Test Design ID | Related Requirement IDs | Related Design Element IDs | Scenario | Expected Result | Test Type |
| --- | --- | --- | --- | --- | --- |
| TST-001 | REQ-001 | DSG-001 |  |  | Unit / Integration / E2E |

## Design Decisions and Open Issues

- This table is an index into Accepted ADRs and open issues. It does not restate decision bodies.
- For a significant design decision, reference the ADR ID under Decision Record IDs and keep the decision body in the ADR.

| ID | Type | Description | Decision Record IDs | Impacted Requirement IDs | Status |
| --- | --- | --- | --- | --- | --- |
| DD-001 | Decision / Open Issue |  | ADR-0001 | REQ-001 | Open / Closed |

## Related Knowledge

- Reference knowledge sources of truth by ID only. Do not copy glossary, business rule, or ADR bodies here.
- Only reference ADRs whose Status is Accepted and not Superseded.

| Design Element ID | Related Term IDs | Related Rule IDs | Decision Record IDs |
| --- | --- | --- | --- |
| DSG-001 | AUTH-TERM-001 | AUTH-RULE-001 | ADR-0001 |

## Approval

| Role | Name | Decision | Date | Notes |
| --- | --- | --- | --- | --- |
| Author |  | Approved / Rework |  |  |
| Reviewer |  | Approved / Rework |  |  |