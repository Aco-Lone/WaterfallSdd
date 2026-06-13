$additionalContext = @'
<EXTREMELY_IMPORTANT>
This workspace uses an OpenSpec Waterfall workflow.

Before handling requests about requirements, detailed design, G1 review, implementation planning, test planning, G2 review, traceability, implementation review, or test review, consult the closest matching workspace skill under .github/skills/.

Use the nearest match instead of loading every skill:
- Requirements and subsystem specification: subsystem-requirements-refinement
- Detailed design authoring: detailed-design-authoring
- G1 design review: design-gate-review
- Implementation planning: implementation-plan-authoring
- Test planning: test-plan-authoring
- G2 plan review: plan-gate-review
- Traceability repair or mapping: traceability-mapping
- Acceptance criteria validation: acceptance-criteria-check
- Implementation review feedback handling: implementation-execution-feedback-handling
- Test review or failure feedback handling: test-execution-feedback-handling
- Return-target decisions: return-target-classification or defect-classification
- Reusable review-driven process improvements: review-driven-improvement

Do not inject full skill contents by default. Read only the skill required for the current task.

Shared operating rules live in README.md and workflow-approval-gate-definition.md.
</EXTREMELY_IMPORTANT>
'@

$result = @{
    hookSpecificOutput = @{
        hookEventName = 'SessionStart'
        additionalContext = $additionalContext.Trim()
    }
}

Write-Output ($result | ConvertTo-Json -Depth 4 -Compress)
exit 0