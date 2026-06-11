$repoRoot = Split-Path -Parent $PSScriptRoot
$validatorPath = Join-Path $repoRoot 'scripts\traceability-validator.ps1'

if (-not (Test-Path $validatorPath)) {
    throw "Validator script not found: $validatorPath"
}

. $validatorPath

Describe 'Test-TraceabilityDocument' {
    It 'flags duplicate requirement ids in a subsystem spec requirements table' {
        $filePath = Join-Path $TestDrive 'subsystem-spec.md'
        @'
# Sample Subsystem Spec

## Requirements

| Requirement ID | Type | Requirement | Rationale | Acceptance Criteria | Priority | Status | Source |
| --- | --- | --- | --- | --- | --- | --- | --- |
| REQ-001 | Functional | First requirement |  |  | Must | Draft |  |
| REQ-001 | Functional | Duplicate requirement |  |  | Must | Draft |  |
'@ | Set-Content -Path $filePath -Encoding UTF8

        $result = Test-TraceabilityDocument -FilePath $filePath

        $result.IsValid | Should Be $false
        ($result.Errors -join "`n") | Should Match 'Duplicate requirement ID'
    }

    It 'flags untraced requirements in a detailed design traceability summary' {
        $filePath = Join-Path $TestDrive 'detailed-design.md'
        @'
# Sample Detailed Design

## Traceability Summary

| Requirement ID | Design Element ID | Class / Component | Activity ID | Error ID | Test Design ID | Coverage Status |
| --- | --- | --- | --- | --- | --- | --- |
| REQ-001 |  | DesignComponent | ACT-001 | ERR-001 | TST-001 | Missing |
'@ | Set-Content -Path $filePath -Encoding UTF8

        $result = Test-TraceabilityDocument -FilePath $filePath

        $result.IsValid | Should Be $false
        ($result.Errors -join "`n") | Should Match 'Untraced requirement ID'
    }

    It 'accepts a fully traced implementation plan matrix' {
        $filePath = Join-Path $TestDrive 'implementation-plan.md'
        @'
# Sample Implementation Plan

## Traceability Matrix

| Plan Item ID | Requirement IDs | Design Element IDs | Scope | Completion Criteria |
| --- | --- | --- | --- | --- |
| PLN-001 | REQ-001 | DSG-001 | Scope | Done |

## Implementation Sequence

| Order | Plan Item ID | Work Item | Depends On | Output | Related Requirement IDs | Related Design Element IDs |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | PLN-001 | Implement feature |  | Commit | REQ-001 | DSG-001 |
'@ | Set-Content -Path $filePath -Encoding UTF8

        $result = Test-TraceabilityDocument -FilePath $filePath

        $result.IsValid | Should Be $true
        $result.Errors.Count | Should Be 0
    }

    It 'accepts a fully traced test plan matrix' {
        $filePath = Join-Path $TestDrive 'test-plan.md'
        @'
# Sample Test Plan

## Traceability Matrix

| Test ID | Requirement IDs | Design Element IDs | Test Scope | Expected Result |
| --- | --- | --- | --- | --- |
| TST-001 | REQ-001 | DSG-001 | Unit | Success |

## Test Execution Sequence

| Order | Test ID | Preconditions | Test Data | Expected Result | Related Requirement IDs | Related Design Element IDs |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | TST-001 | Setup complete | Sample data | Success | REQ-001 | DSG-001 |
'@ | Set-Content -Path $filePath -Encoding UTF8

        $result = Test-TraceabilityDocument -FilePath $filePath

        $result.IsValid | Should Be $true
        $result.Errors.Count | Should Be 0
    }

    It 'rejects a combined implementation and test plan document' {
        $filePath = Join-Path $TestDrive 'implementation-test-plan.md'
        @'
# Sample Combined Plan

## Traceability Matrix

| Plan Item ID | Requirement IDs | Design Element IDs | Test IDs | Scope | Completion Criteria |
| --- | --- | --- | --- | --- | --- |
| PLN-001 | REQ-001 | DSG-001 | TST-001 | Scope | Done |

## Implementation Sequence

| Order | Plan Item ID | Work Item | Depends On | Output | Related Requirement IDs | Related Design Element IDs |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | PLN-001 | Implement feature |  | Commit | REQ-001 | DSG-001 |

## Test Execution Plan

| Order | Test ID | Test Scope | Preconditions | Expected Result | Related Requirement IDs |
| --- | --- | --- | --- | --- | --- |
| 1 | TST-001 | Unit | Setup complete | Success | REQ-001 |
'@ | Set-Content -Path $filePath -Encoding UTF8

        $result = Test-TraceabilityDocument -FilePath $filePath

        $result.IsValid | Should Be $false
        ($result.Errors -join "`n") | Should Match 'separate files'
    }
}

Describe 'Invoke-TraceabilityHook' {
    It 'blocks post tool processing when an edited markdown artifact has traceability errors' {
        $filePath = Join-Path $TestDrive 'detailed-design.md'
        @'
# Sample Detailed Design

## Traceability Summary

| Requirement ID | Design Element ID | Class / Component | Activity ID | Error ID | Test Design ID | Coverage Status |
| --- | --- | --- | --- | --- | --- | --- |
| REQ-001 |  | DesignComponent | ACT-001 | ERR-001 | TST-001 | Missing |
'@ | Set-Content -Path $filePath -Encoding UTF8

        $hookInput = @{
            hookEventName = 'PostToolUse'
            tool_name = 'apply_patch'
            tool_input = @{ filePath = $filePath }
        }

        $result = Invoke-TraceabilityHook -HookInput $hookInput

        $result.decision | Should Be 'block'
        $result.reason | Should Match 'Traceability validation failed'
    }

    It 'skips non markdown edits' {
        $filePath = Join-Path $TestDrive 'notes.txt'
        'plain text' | Set-Content -Path $filePath -Encoding UTF8

        $hookInput = @{
            hookEventName = 'PostToolUse'
            tool_name = 'apply_patch'
            tool_input = @{ filePath = $filePath }
        }

        $result = Invoke-TraceabilityHook -HookInput $hookInput

        $result.decision | Should Be $null
        $result.hookSpecificOutput.additionalContext | Should Match 'No traceability artifacts changed'
    }
}