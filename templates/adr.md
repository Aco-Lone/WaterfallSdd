---
type: decision-record
id: ADR-0001
title: ""
status: Draft
owner: ""
approver: ""
decision_date: ""
supersedes: ""
superseded_by: ""
related_reqs:
  - REQ-001
related_rules:
  - AUTH-RULE-001
related_designs:
  - DSG-001
---

# Architecture Decision Record Template

- OKF `type: decision-record`. Metadata lives in the YAML frontmatter above; there is no Markdown control table.
- `status` allows one of: Draft / Proposed / Accepted / Superseded / Rejected.
- `id` must match the file name prefix, for example ADR-0001 in ADR-0001-example.md.

## Context

- Describe the situation, constraints, and forces that require a decision.

## Decision Drivers

- 

## Considered Options

- Option A: 
- Option B: 

## Decision

- State the chosen option and the decision clearly.

## Rejected Options and Reasons

| Option | Reason for Rejection |
| --- | --- |
|  |  |

## Consequences

### Positive

- 

### Negative

- 

## Notes

- Related Requirement / Rule / Design Element IDs and Supersedes / Superseded By are recorded in the frontmatter above.
- Create an ADR only when multiple options exist and the decision affects future change cost, quality attributes, responsibility boundaries, or external constraints.
- ADR IDs are numbered sequentially across the whole repository, for example ADR-0001.
- An Accepted ADR is an immutable record. Do not rewrite it. Record replacement from a new ADR using the `supersedes` / `superseded_by` frontmatter fields.
- An ADR cannot override a requirement or a business rule.
