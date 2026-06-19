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

Describe 'Test-TraceabilityDocument spec delta and impact map' {
    function New-BaselineSpec {
        param([string]$Root)

        $specDirectory = Join-Path $Root 'openspec/specs'
        New-Item -ItemType Directory -Path $specDirectory -Force | Out-Null
        $specPath = Join-Path $specDirectory 'subsystem-spec.md'
        @'
# Baseline Subsystem Spec

## Requirements

| Requirement ID | Type | Requirement | Rationale | Acceptance Criteria | Priority | Status | Source |
| --- | --- | --- | --- | --- | --- | --- | --- |
| REQ-001 | Functional | Existing requirement |  | Criteria | Must | Approved |  |
| REQ-003 | Functional | Another requirement |  | Criteria | Must | Approved |  |
'@ | Set-Content -Path $specPath -Encoding UTF8

        return $specPath
    }

    It 'accepts a spec delta with valid operations against the baseline' {
        $changeDirectory = Join-Path $TestDrive 'openspec/changes/change-a'
        New-Item -ItemType Directory -Path $changeDirectory -Force | Out-Null
        New-BaselineSpec -Root $TestDrive | Out-Null

        $filePath = Join-Path $changeDirectory 'spec-delta.md'
        @'
# Spec Delta

## Spec Delta

| Delta ID | Operation | Requirement ID | Requirement | Acceptance Criteria | Rationale |
| --- | --- | --- | --- | --- | --- |
| DLT-001 | ADDED | REQ-010 | New requirement | Criteria | Reason |
| DLT-002 | MODIFIED | REQ-003 | Updated requirement | Criteria | Reason |
| DLT-003 | REMOVED | REQ-001 |  |  | Reason |
'@ | Set-Content -Path $filePath -Encoding UTF8

        $result = Test-TraceabilityDocument -FilePath $filePath

        $result.DocumentType | Should Be 'SpecDelta'
        $result.IsValid | Should Be $true
    }

    It 'flags an ADDED requirement that already exists in the baseline' {
        $changeDirectory = Join-Path $TestDrive 'openspec/changes/change-b'
        New-Item -ItemType Directory -Path $changeDirectory -Force | Out-Null
        New-BaselineSpec -Root $TestDrive | Out-Null

        $filePath = Join-Path $changeDirectory 'spec-delta.md'
        @'
# Spec Delta

## Spec Delta

| Delta ID | Operation | Requirement ID | Requirement | Acceptance Criteria | Rationale |
| --- | --- | --- | --- | --- | --- |
| DLT-001 | ADDED | REQ-001 | Duplicate add | Criteria | Reason |
'@ | Set-Content -Path $filePath -Encoding UTF8

        $result = Test-TraceabilityDocument -FilePath $filePath

        $result.IsValid | Should Be $false
        ($result.Errors -join "`n") | Should Match 'ADDED requirement already exists'
    }

    It 'flags a MODIFIED requirement that is missing from the baseline' {
        $changeDirectory = Join-Path $TestDrive 'openspec/changes/change-c'
        New-Item -ItemType Directory -Path $changeDirectory -Force | Out-Null
        New-BaselineSpec -Root $TestDrive | Out-Null

        $filePath = Join-Path $changeDirectory 'spec-delta.md'
        @'
# Spec Delta

## Spec Delta

| Delta ID | Operation | Requirement ID | Requirement | Acceptance Criteria | Rationale |
| --- | --- | --- | --- | --- | --- |
| DLT-001 | MODIFIED | REQ-999 | Update missing | Criteria | Reason |
'@ | Set-Content -Path $filePath -Encoding UTF8

        $result = Test-TraceabilityDocument -FilePath $filePath

        $result.IsValid | Should Be $false
        ($result.Errors -join "`n") | Should Match 'MODIFIED requirement not found'
    }

    It 'flags an invalid delta operation value' {
        $changeDirectory = Join-Path $TestDrive 'openspec/changes/change-d'
        New-Item -ItemType Directory -Path $changeDirectory -Force | Out-Null
        New-BaselineSpec -Root $TestDrive | Out-Null

        $filePath = Join-Path $changeDirectory 'spec-delta.md'
        @'
# Spec Delta

## Spec Delta

| Delta ID | Operation | Requirement ID | Requirement | Acceptance Criteria | Rationale |
| --- | --- | --- | --- | --- | --- |
| DLT-001 | CHANGED | REQ-003 | Wrong operation | Criteria | Reason |
'@ | Set-Content -Path $filePath -Encoding UTF8

        $result = Test-TraceabilityDocument -FilePath $filePath

        $result.IsValid | Should Be $false
        ($result.Errors -join "`n") | Should Match 'Invalid delta operation'
    }

    It 'accepts an impact map that maps every delta requirement' {
        $changeDirectory = Join-Path $TestDrive 'openspec/changes/change-e'
        New-Item -ItemType Directory -Path $changeDirectory -Force | Out-Null

        @'
# Spec Delta

## Spec Delta

| Delta ID | Operation | Requirement ID | Requirement | Acceptance Criteria | Rationale |
| --- | --- | --- | --- | --- | --- |
| DLT-001 | ADDED | REQ-010 | New requirement | Criteria | Reason |
'@ | Set-Content -Path (Join-Path $changeDirectory 'spec-delta.md') -Encoding UTF8

        $filePath = Join-Path $changeDirectory 'impact-map.md'
        @'
# Impact Map

## Impact Map

| Impact ID | Requirement ID | Operation | Affected csproj | Affected Design Element IDs | Affected Plan Item IDs | Affected Test IDs | Re-review Required | Gate Record |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| IMP-001 | REQ-010 | ADDED | Sample.Core | DSG-001 | PLN-001 | TST-001 | Yes | reviews/REV-001.md |
'@ | Set-Content -Path $filePath -Encoding UTF8

        $result = Test-TraceabilityDocument -FilePath $filePath

        $result.DocumentType | Should Be 'ChangeImpactMap'
        $result.IsValid | Should Be $true
    }

    It 'flags an impact map that omits a delta requirement' {
        $changeDirectory = Join-Path $TestDrive 'openspec/changes/change-f'
        New-Item -ItemType Directory -Path $changeDirectory -Force | Out-Null

        @'
# Spec Delta

## Spec Delta

| Delta ID | Operation | Requirement ID | Requirement | Acceptance Criteria | Rationale |
| --- | --- | --- | --- | --- | --- |
| DLT-001 | ADDED | REQ-010 | New requirement | Criteria | Reason |
| DLT-002 | ADDED | REQ-011 | Another requirement | Criteria | Reason |
'@ | Set-Content -Path (Join-Path $changeDirectory 'spec-delta.md') -Encoding UTF8

        $filePath = Join-Path $changeDirectory 'impact-map.md'
        @'
# Impact Map

## Impact Map

| Impact ID | Requirement ID | Operation | Affected csproj | Affected Design Element IDs | Affected Plan Item IDs | Affected Test IDs | Re-review Required | Gate Record |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| IMP-001 | REQ-010 | ADDED | Sample.Core | DSG-001 | PLN-001 | TST-001 | Yes | reviews/REV-001.md |
'@ | Set-Content -Path $filePath -Encoding UTF8

        $result = Test-TraceabilityDocument -FilePath $filePath

        $result.IsValid | Should Be $false
        ($result.Errors -join "`n") | Should Match 'not mapped in impact map'
    }

    It 'flags an ADDED impact row without an affected csproj' {
        $changeDirectory = Join-Path $TestDrive 'openspec/changes/change-g'
        New-Item -ItemType Directory -Path $changeDirectory -Force | Out-Null

        $filePath = Join-Path $changeDirectory 'impact-map.md'
        @'
# Impact Map

## Impact Map

| Impact ID | Requirement ID | Operation | Affected csproj | Affected Design Element IDs | Affected Plan Item IDs | Affected Test IDs | Re-review Required | Gate Record |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| IMP-001 | REQ-010 | ADDED |  | DSG-001 | PLN-001 | TST-001 | Yes | reviews/REV-001.md |
'@ | Set-Content -Path $filePath -Encoding UTF8

        $result = Test-TraceabilityDocument -FilePath $filePath

        $result.IsValid | Should Be $false
        ($result.Errors -join "`n") | Should Match 'Affected csproj missing'
    }

    It 'flags a REMOVED impact row that does not require re-review' {
        $changeDirectory = Join-Path $TestDrive 'openspec/changes/change-h'
        New-Item -ItemType Directory -Path $changeDirectory -Force | Out-Null

        $filePath = Join-Path $changeDirectory 'impact-map.md'
        @'
# Impact Map

## Impact Map

| Impact ID | Requirement ID | Operation | Affected csproj | Affected Design Element IDs | Affected Plan Item IDs | Affected Test IDs | Re-review Required | Gate Record |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| IMP-001 | REQ-001 | REMOVED | Sample.Core | DSG-001 | PLN-001 | TST-001 | No |  |
'@ | Set-Content -Path $filePath -Encoding UTF8

        $result = Test-TraceabilityDocument -FilePath $filePath

        $result.IsValid | Should Be $false
        ($result.Errors -join "`n") | Should Match 'must require re-review'
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