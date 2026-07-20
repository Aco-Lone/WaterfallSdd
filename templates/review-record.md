# Review Record Template

## Review Control

| Field | Value |
| --- | --- |
| Gate Type | G1 Design Review / G2 Plan Review / Implementation Review / Test Review |
| Target Document |  |
| Target csproj |  |
| Review Date |  |
| Reviewer |  |
| Review Result | Approved / Rework |

## Traceability Check Summary

| Item | Count | Notes |
| --- | --- | --- |
| Untraced Requirement IDs | 0 |  |
| Untraced Design Element IDs | 0 |  |
| Unresolved Knowledge / ADR References | 0 |  |
| Superseded or Obsolete Knowledge Used | 0 |  |
| Post-G2 Notes |  |  |
| Total Findings | 0 |  |

## Findings

| Review ID | Severity | Return Target | Requirement IDs | Design Element IDs | Plan Item IDs | Test IDs | Cause Category | Root Cause | Finding | Action | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| REV-001 | Critical / Major / Minor | Design / Plan / Code / Test / Minor Fix | REQ-001 | DSG-001 | PLN-001 | TST-001 | Requirement Interpretation / Traceability / Process Deviation / Output Format / Review Coverage |  |  |  | Open / Closed |

## Gate Checklist

### G1 Design Review

- [ ] Requirements are fully reflected in design.
- [ ] Requirement IDs are unique and fully traced.
- [ ] Class responsibilities and dependency directions are valid.
- [ ] Activity diagram matches the document body.
- [ ] Error design is sufficient.
- [ ] Test design is sufficient.
- [ ] Testability is ensured.
- [ ] Requirements reference the required TERM / RULE IDs.
- [ ] Design elements reference the relevant ADR IDs.
- [ ] Referenced ADRs are Accepted and not Superseded.
- [ ] No ADR overrides a requirement or a business rule.
- [ ] Detailed design and knowledge delta are consistent.
- [ ] No significant design decision is embedded without an ADR.

### G2 Plan Review

- [ ] Plan does not override approved design.
- [ ] Requirement IDs are fully traced in the plan.
- [ ] Design element IDs are fully traced in the plan.
- [ ] Implementation sequence is executable.
- [ ] Test order and preparation are valid.
- [ ] Task granularity is appropriate.
- [ ] Parallel execution plan is valid.
- [ ] Plan preserves the approved knowledge references.
- [ ] Plan introduces no new business rule or design decision.
- [ ] Knowledge or ADR issues are not closed inside the plan.

### Implementation Review

- [ ] Implementation matches the approved implementation plan.
- [ ] Requirement, design, and plan traceability are preserved.
- [ ] Implementation is based on the knowledge set approved at gate time.
- [ ] No obsolete TERM / RULE / ADR is used.
- [ ] New business knowledge is not left only in code.
- [ ] Findings are classified with Design / Plan / Code / Minor Fix.
- [ ] Post-G2 return targets are summarized.
- [ ] Next handoff to test execution or rework target is explicit.

### Test Review

- [ ] Test execution or test changes match the approved test plan.
- [ ] Requirement, design, and test traceability are preserved.
- [ ] Tests are based on the knowledge set approved at gate time.
- [ ] No obsolete TERM / RULE / ADR is used.
- [ ] Reusable review insight is classified as an improvement candidate.
- [ ] Findings are classified with Design / Plan / Test / Code / Minor Fix.
- [ ] Post-G2 return targets are summarized.
- [ ] Next handoff to improvement analysis or rework target is explicit.

## Decision Summary

| Type | Count |
| --- | --- |
| Findings to return to design | 0 |
| Findings to return to plan | 0 |
| Findings to return to code | 0 |
| Findings to return to test | 0 |
| Minor fixes only | 0 |

## Approval

| Role | Name | Decision | Date | Notes |
| --- | --- | --- | --- | --- |
| Reviewer |  | Approved / Rework |  |  |
| Author |  | Acknowledged |  |  |