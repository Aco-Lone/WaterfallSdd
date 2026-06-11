# Skill Template

## Purpose

- Use this template when adding a workspace skill under .github/skills/.
- Keep the description focused on triggering conditions so the agent reads the full body.
- Preserve WaterfallSdd workflow boundaries and traceability rules in Procedure and Checks.

## Directory Layout

```text
.github/
  skills/
    your-skill-name/
      SKILL.md
```

## SKILL.md Template

```markdown
---
name: your-skill-name
description: "Use when [specific triggering conditions only, not the workflow summary]"
user-invocable: false
---

# Your Skill Title

## When to Use

- [Situation or symptom that should trigger this skill]
- [Another trigger condition written from the user's task context]
- [Boundary that tells the agent to use this skill before acting]

## Procedure

1. Read the controlling artifact for this phase.
2. Apply the phase-specific rules without changing upstream decisions.
3. Maintain the required IDs and traceability links for this step.
4. Record unresolved items and the required return target when closure is not allowed here.
5. Stop after producing the expected artifact or review result for this skill.

## Checks

- The output is tied to the correct phase artifact.
- Required IDs and traceability links are present and not contradictory.
- This skill does not overwrite decisions owned by an upstream artifact.
- Open issues, assumptions, and return targets are explicit.

## References

- [Relevant template](../../../templates/example.md)
- [Workflow and gate definition](../../../workflow-approval-gate-definition.md)
- [Related guide or spec](../../../docs/superpowers/specs/example.md)
```

## WaterfallSdd Authoring Notes

- Use a hyphenated skill name that is easy to search.
- Keep description under control: write only when to use the skill, not the step sequence.
- In Procedure, make the owning artifact explicit: Subsystem Spec, Detailed Design, Implementation and Test Plan, or Review Record.
- In Checks, state the IDs that must remain traceable, such as REQ, DSG, PLN, TST, and REV.
- If the skill supports a review gate, state what must be returned upstream instead of being closed locally.
- Add References only to stable workspace assets that the skill should routinely consult.