$repoRoot = Split-Path -Parent $PSScriptRoot
$archiveScriptPath = Join-Path $repoRoot 'scripts' 'openspec-archive.ps1'

if (-not (Test-Path $archiveScriptPath)) {
    throw "Archive script not found: $archiveScriptPath"
}

. $archiveScriptPath

function New-SampleChange {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root,

        [Parameter(Mandatory = $true)]
        [string]$ChangeId,

        [string]$ProposalStatus = 'Approved'
    )

    $specDirectory = Join-Path $Root 'openspec/specs'
    New-Item -ItemType Directory -Path $specDirectory -Force | Out-Null
    @'
# Baseline Subsystem Spec

## Requirements

| Requirement ID | Type | Requirement | Rationale | Acceptance Criteria | Priority | Status | Source |
| --- | --- | --- | --- | --- | --- | --- | --- |
| REQ-001 | Functional | Existing requirement | Reason | Criteria | Must | Approved |  |
| REQ-003 | Functional | Another requirement | Reason | Criteria | Must | Approved |  |

## Change History

| Date | Version | Change Summary | Related Requirement IDs |
| --- | --- | --- | --- |
'@ | Set-Content -Path (Join-Path $specDirectory 'subsystem-spec.md') -Encoding UTF8

    $changeDirectory = Join-Path $Root (Join-Path 'openspec/changes' $ChangeId)
    New-Item -ItemType Directory -Path $changeDirectory -Force | Out-Null

    @"
# Change Proposal

## Document Control

| Field | Value |
| --- | --- |
| Change ID | $ChangeId |
| Status | $ProposalStatus |
"@ | Set-Content -Path (Join-Path $changeDirectory 'proposal.md') -Encoding UTF8

    @'
# Spec Delta

## Spec Delta

| Delta ID | Operation | Requirement ID | Requirement | Acceptance Criteria | Rationale |
| --- | --- | --- | --- | --- | --- |
| DLT-001 | ADDED | REQ-010 | New requirement | New criteria | New reason |
| DLT-002 | MODIFIED | REQ-003 | Updated requirement | Updated criteria | Update reason |
| DLT-003 | REMOVED | REQ-001 |  |  | Retire reason |
'@ | Set-Content -Path (Join-Path $changeDirectory 'spec-delta.md') -Encoding UTF8

    @'
# Impact Map

## Impact Map

| Impact ID | Requirement ID | Operation | Affected csproj | Affected Design Element IDs | Affected Plan Item IDs | Affected Test IDs | Re-review Required | Gate Record |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| IMP-001 | REQ-010 | ADDED | Sample.Core | DSG-010 | PLN-010 | TST-010 | Yes | reviews/REV-001.md |
| IMP-002 | REQ-003 | MODIFIED | Sample.Core | DSG-003 | PLN-003 | TST-003 | Yes | reviews/REV-002.md |
| IMP-003 | REQ-001 | REMOVED | Sample.Core | DSG-001 | PLN-001 | TST-001 | Yes | reviews/REV-003.md |
'@ | Set-Content -Path (Join-Path $changeDirectory 'impact-map.md') -Encoding UTF8

    return $changeDirectory
}

Describe 'Invoke-OpenSpecArchive' {
    It 'applies the spec delta to the baseline and moves the change to the archive' {
        New-SampleChange -Root $TestDrive -ChangeId 'change-a' | Out-Null

        $result = Invoke-OpenSpecArchive -ChangeId 'change-a' -WorkspaceRoot $TestDrive

        $result.Archived | Should Be $true

        $baseline = Get-Content -Path (Join-Path $TestDrive 'openspec/specs/subsystem-spec.md') -Raw -Encoding UTF8

        $baseline | Should Match 'REQ-010'
        $baseline | Should Match 'Updated requirement'
        ($baseline -split "`r?`n" | Where-Object { $_ -match '^\|\s*REQ-001\s*\|' }) | Should Match 'Obsolete'
        $baseline | Should Match 'Archived change change-a'

        $datePrefix = (Get-Date).ToString('yyyyMMdd')
        $archivePath = Join-Path $TestDrive ("openspec/changes/archive/{0}-change-a" -f $datePrefix)
        (Test-Path $archivePath) | Should Be $true
        (Test-Path (Join-Path $TestDrive 'openspec/changes/change-a')) | Should Be $false
    }

    It 'blocks archiving when the proposal is not approved' {
        New-SampleChange -Root $TestDrive -ChangeId 'change-b' -ProposalStatus 'In Review' | Out-Null

        $result = Invoke-OpenSpecArchive -ChangeId 'change-b' -WorkspaceRoot $TestDrive

        $result.Archived | Should Be $false
        ($result.Errors -join "`n") | Should Match 'must be Approved'
        (Test-Path (Join-Path $TestDrive 'openspec/changes/change-b')) | Should Be $true
    }

    It 'blocks archiving when an artifact fails traceability validation' {
        $changeDirectory = New-SampleChange -Root $TestDrive -ChangeId 'change-c'
        @'
# Spec Delta

## Spec Delta

| Delta ID | Operation | Requirement ID | Requirement | Acceptance Criteria | Rationale |
| --- | --- | --- | --- | --- | --- |
| DLT-001 | ADDED | REQ-001 | Duplicate add | Criteria | Reason |
'@ | Set-Content -Path (Join-Path $changeDirectory 'spec-delta.md') -Encoding UTF8

        $result = Invoke-OpenSpecArchive -ChangeId 'change-c' -WorkspaceRoot $TestDrive

        $result.Archived | Should Be $false
        ($result.Errors -join "`n") | Should Match 'Traceability validation failed'
    }
}

Describe 'Invoke-OpenSpecArchive knowledge' {
    It 'applies the knowledge delta, promotes accepted ADRs, and regenerates the index' {
        $changeDirectory = New-SampleChange -Root $TestDrive -ChangeId 'change-k'

        $glossaryDir = Join-Path $TestDrive 'openspec/knowledge/glossary'
        New-Item -ItemType Directory -Path $glossaryDir -Force | Out-Null
        @'
---
type: glossary-term
id: AUTH-TERM-001
status: Active
---
# Glossary Term
'@ | Set-Content -Path (Join-Path $glossaryDir 'AUTH-TERM-001.md') -Encoding UTF8

        @'
---
type: knowledge-delta
change_id: change-k
status: Draft
---
# Knowledge Delta

## Knowledge Delta

| Delta ID | Operation | Knowledge ID | Kind | Summary | Related Requirement IDs | Rationale |
| --- | --- | --- | --- | --- | --- | --- |
| KDL-001 | ADDED | AUTH-TERM-020 | TERM | New added term | REQ-010 | New term reason |
| KDL-002 | REMOVED | AUTH-TERM-001 | TERM |  | REQ-001 | Retire reason |
'@ | Set-Content -Path (Join-Path $changeDirectory 'knowledge-delta.md') -Encoding UTF8

        $changeDecisionsDir = Join-Path $changeDirectory 'decisions'
        New-Item -ItemType Directory -Path $changeDecisionsDir -Force | Out-Null
        @'
---
type: decision-record
id: ADR-0001
title: Use token auth
status: Accepted
supersedes: ""
superseded_by: ""
---
# Decision Record
'@ | Set-Content -Path (Join-Path $changeDecisionsDir 'ADR-0001-token.md') -Encoding UTF8

        $result = Invoke-OpenSpecArchive -ChangeId 'change-k' -WorkspaceRoot $TestDrive

        $result.Archived | Should Be $true

        $addedTermPath = Join-Path $TestDrive 'openspec/knowledge/glossary/AUTH-TERM-020.md'
        (Test-Path $addedTermPath) | Should Be $true

        $removedTerm = Get-Content -Path (Join-Path $TestDrive 'openspec/knowledge/glossary/AUTH-TERM-001.md') -Raw -Encoding UTF8
        $removedTerm | Should Match 'Obsolete'

        $promotedAdrPath = Join-Path $TestDrive 'openspec/decisions/ADR-0001-token.md'
        (Test-Path $promotedAdrPath) | Should Be $true

        $index = Get-Content -Path (Join-Path $TestDrive 'openspec/knowledge/index.md') -Raw -Encoding UTF8
        $index | Should Match 'AUTH-TERM-020'
        $index | Should Match 'ADR-0001'
    }

    It 'sets superseded by on a baseline ADR replaced by a promoted ADR' {
        $changeDirectory = New-SampleChange -Root $TestDrive -ChangeId 'change-k-super'

        $baselineDecisionsDir = Join-Path $TestDrive 'openspec/decisions'
        New-Item -ItemType Directory -Path $baselineDecisionsDir -Force | Out-Null
        @'
---
type: decision-record
id: ADR-0001
title: Old decision
status: Accepted
supersedes: ""
superseded_by: ""
---
# Decision Record
'@ | Set-Content -Path (Join-Path $baselineDecisionsDir 'ADR-0001-old.md') -Encoding UTF8

        $changeDecisionsDir = Join-Path $changeDirectory 'decisions'
        New-Item -ItemType Directory -Path $changeDecisionsDir -Force | Out-Null
        @'
---
type: decision-record
id: ADR-0002
title: New decision
status: Accepted
supersedes: ADR-0001
superseded_by: ""
---
# Decision Record
'@ | Set-Content -Path (Join-Path $changeDecisionsDir 'ADR-0002-new.md') -Encoding UTF8

        $result = Invoke-OpenSpecArchive -ChangeId 'change-k-super' -WorkspaceRoot $TestDrive

        $result.Archived | Should Be $true

        $oldAdr = Get-Content -Path (Join-Path $baselineDecisionsDir 'ADR-0001-old.md') -Raw -Encoding UTF8
        $oldAdr | Should Match 'Superseded'
        $oldAdr | Should Match 'ADR-0002'
    }
}

