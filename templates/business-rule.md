---
type: business-rule
id: AUTH-RULE-001
status: Draft
owner: ""
subsystem: ""
effective_from: ""
effective_until: ""
related_reqs:
  - REQ-001
---

# Business Rule Template

- OKF `type: business-rule`. Metadata lives in the YAML frontmatter above; there is no Markdown control table.
- `status` allows one of: Draft / Active / Obsolete.
- `id` must match the file name without the extension, for example AUTH-RULE-001.

## Condition

- Describe the condition under which the rule applies.

## Result

- Describe the outcome when the condition holds.

## Exceptions

- 

## Boundary Values and Examples

- 

## Rationale

- Record why this rule exists.

## Notes

- One rule per file. The file name should match the `id`, for example AUTH-RULE-001.md.
- This file is a knowledge source of truth. Do not duplicate its body into specs, designs, or skills; reference the Rule ID instead.
