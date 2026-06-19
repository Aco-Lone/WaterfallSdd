$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDirectory 'traceability-validator.ps1')

function Get-TableBounds {
    param(
        [Parameter(Mandatory = $true)]
        $Lines,

        [Parameter(Mandatory = $true)]
        [string]$SectionHeading
    )

    $headingPattern = '^##\s+' + [regex]::Escape($SectionHeading) + '\s*$'
    $sectionIndex = -1

    for ($index = 0; $index -lt $Lines.Count; $index++) {
        if ($Lines[$index] -match $headingPattern) {
            $sectionIndex = $index
            break
        }
    }

    if ($sectionIndex -lt 0) {
        return $null
    }

    $headerIndex = -1
    for ($index = $sectionIndex + 1; $index -lt $Lines.Count; $index++) {
        $trimmed = $Lines[$index].Trim()
        if ([string]::IsNullOrWhiteSpace($trimmed)) {
            continue
        }

        if ($trimmed.StartsWith('|')) {
            $headerIndex = $index
        }

        break
    }

    if ($headerIndex -lt 0) {
        return $null
    }

    $separatorIndex = $headerIndex + 1
    $lastDataIndex = $separatorIndex

    for ($index = $separatorIndex + 1; $index -lt $Lines.Count; $index++) {
        if ($Lines[$index].Trim().StartsWith('|')) {
            $lastDataIndex = $index
        }
        else {
            break
        }
    }

    return [pscustomobject]@{
        HeaderIndex = $headerIndex
        SeparatorIndex = $separatorIndex
        LastDataIndex = $lastDataIndex
    }
}

function Format-TableRow {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]$Cells
    )

    return '| ' + ($Cells -join ' | ') + ' |'
}

function Get-DeltaRows {
    param(
        [Parameter(Mandatory = $true)]
        [string]$DeltaPath
    )

    $content = Get-Content -Path $DeltaPath -Raw -Encoding UTF8
    $lines = $content -split "`r?`n"
    $rows = Get-MarkdownTableRows -Lines $lines -SectionHeading 'Spec Delta'

    $deltaRows = New-Object System.Collections.Generic.List[object]
    foreach ($row in $rows) {
        $deltaId = if ($row.Count -gt 0) { $row[0] } else { '' }
        if ([string]::IsNullOrWhiteSpace($deltaId)) {
            continue
        }

        $deltaRows.Add([pscustomobject]@{
            DeltaId = $deltaId
            Operation = if ($row.Count -gt 1) { $row[1] } else { '' }
            RequirementId = if ($row.Count -gt 2) { $row[2] } else { '' }
            Requirement = if ($row.Count -gt 3) { $row[3] } else { '' }
            AcceptanceCriteria = if ($row.Count -gt 4) { $row[4] } else { '' }
            Rationale = if ($row.Count -gt 5) { $row[5] } else { '' }
        })
    }

    return , $deltaRows.ToArray()
}

function Get-ProposalStatus {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProposalPath
    )

    $lines = Get-Content -Path $ProposalPath -Encoding UTF8
    foreach ($line in $lines) {
        if ($line -match '^\|\s*Status\s*\|\s*(.+?)\s*\|') {
            return $Matches[1].Trim()
        }
    }

    return ''
}

function Test-ArchivePrecondition {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ChangeDirectory,

        [Parameter(Mandatory = $true)]
        [string]$BaselinePath
    )

    $errors = New-Object System.Collections.Generic.List[string]

    $proposalPath = Join-Path $ChangeDirectory 'proposal.md'
    $deltaPath = Join-Path $ChangeDirectory 'spec-delta.md'
    $impactPath = Join-Path $ChangeDirectory 'impact-map.md'

    if (-not (Test-Path $ChangeDirectory)) {
        $errors.Add("Change directory not found: $ChangeDirectory")
        return $errors
    }

    foreach ($required in @($proposalPath, $deltaPath, $impactPath)) {
        if (-not (Test-Path $required)) {
            $errors.Add("Required change artifact missing: $required")
        }
    }

    if (-not (Test-Path $BaselinePath)) {
        $errors.Add("Baseline subsystem spec not found: $BaselinePath")
    }

    if ($errors.Count -gt 0) {
        return $errors
    }

    $status = Get-ProposalStatus -ProposalPath $proposalPath
    if ($status -ne 'Approved') {
        $errors.Add("Change proposal status must be Approved before archiving. Current: '$status'")
    }

    foreach ($artifact in @($deltaPath, $impactPath)) {
        $result = Test-TraceabilityDocument -FilePath $artifact
        if (-not $result.IsValid) {
            $errors.Add("Traceability validation failed for ${artifact}: $($result.Errors -join '; ')")
        }
    }

    return $errors
}

function Update-BaselineRequirements {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaselinePath,

        [Parameter(Mandatory = $true)]
        $DeltaRows
    )

    $lines = [System.Collections.Generic.List[string]](Get-Content -Path $BaselinePath -Encoding UTF8)

    foreach ($delta in $DeltaRows) {
        $bounds = Get-TableBounds -Lines $lines -SectionHeading 'Requirements'
        if ($null -eq $bounds) {
            throw "Requirements table not found in baseline: $BaselinePath"
        }

        $rowIndex = -1
        for ($index = $bounds.SeparatorIndex + 1; $index -le $bounds.LastDataIndex; $index++) {
            $cells = Split-MarkdownTableRow -Line $lines[$index]
            if ($cells.Count -gt 0 -and $cells[0] -eq $delta.RequirementId) {
                $rowIndex = $index
                break
            }
        }

        switch ($delta.Operation) {
            'ADDED' {
                $newRow = Format-TableRow -Cells @(
                    $delta.RequirementId,
                    'Functional',
                    $delta.Requirement,
                    $delta.Rationale,
                    $delta.AcceptanceCriteria,
                    'Must',
                    'Approved',
                    ''
                )
                $lines.Insert($bounds.LastDataIndex + 1, $newRow)
            }
            'MODIFIED' {
                if ($rowIndex -ge 0) {
                    $cells = @(Split-MarkdownTableRow -Line $lines[$rowIndex])
                    while ($cells.Count -lt 8) { $cells += '' }
                    $cells[2] = $delta.Requirement
                    $cells[3] = $delta.Rationale
                    $cells[4] = $delta.AcceptanceCriteria
                    $cells[6] = 'Approved'
                    $lines[$rowIndex] = Format-TableRow -Cells $cells
                }
            }
            'REMOVED' {
                if ($rowIndex -ge 0) {
                    $cells = @(Split-MarkdownTableRow -Line $lines[$rowIndex])
                    while ($cells.Count -lt 8) { $cells += '' }
                    $cells[6] = 'Obsolete'
                    $lines[$rowIndex] = Format-TableRow -Cells $cells
                }
            }
        }
    }

    $lines | Set-Content -Path $BaselinePath -Encoding UTF8
}

function Add-ChangeHistoryRow {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaselinePath,

        [Parameter(Mandatory = $true)]
        [string]$ChangeId,

        [Parameter(Mandatory = $true)]
        $DeltaRows
    )

    $lines = [System.Collections.Generic.List[string]](Get-Content -Path $BaselinePath -Encoding UTF8)
    $bounds = Get-TableBounds -Lines $lines -SectionHeading 'Change History'
    if ($null -eq $bounds) {
        return
    }

    $requirementIds = @($DeltaRows | ForEach-Object { $_.RequirementId } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $row = Format-TableRow -Cells @(
        (Get-Date).ToString('yyyy-MM-dd'),
        '',
        "Archived change $ChangeId",
        ($requirementIds -join ', ')
    )

    $lines.Insert($bounds.LastDataIndex + 1, $row)
    $lines | Set-Content -Path $BaselinePath -Encoding UTF8
}

function Invoke-OpenSpecArchive {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ChangeId,

        [Parameter(Mandatory = $false)]
        [string]$WorkspaceRoot = (Get-Location).Path
    )

    $changeDirectory = Join-Path $WorkspaceRoot (Join-Path 'openspec/changes' $ChangeId)
    $baselinePath = Join-Path $WorkspaceRoot 'openspec/specs/subsystem-spec.md'
    $archiveRoot = Join-Path $WorkspaceRoot 'openspec/changes/archive'

    $preconditionErrors = Test-ArchivePrecondition -ChangeDirectory $changeDirectory -BaselinePath $baselinePath
    if ($preconditionErrors.Count -gt 0) {
        return [pscustomobject]@{
            ChangeId = $ChangeId
            Archived = $false
            ArchivePath = $null
            Errors = $preconditionErrors
        }
    }

    $deltaRows = Get-DeltaRows -DeltaPath (Join-Path $changeDirectory 'spec-delta.md')

    Update-BaselineRequirements -BaselinePath $baselinePath -DeltaRows $deltaRows
    Add-ChangeHistoryRow -BaselinePath $baselinePath -ChangeId $ChangeId -DeltaRows $deltaRows

    if (-not (Test-Path $archiveRoot)) {
        New-Item -ItemType Directory -Path $archiveRoot -Force | Out-Null
    }

    $datePrefix = (Get-Date).ToString('yyyyMMdd')
    $archiveTarget = Join-Path $archiveRoot ("{0}-{1}" -f $datePrefix, $ChangeId)
    Move-Item -Path $changeDirectory -Destination $archiveTarget

    return [pscustomobject]@{
        ChangeId = $ChangeId
        Archived = $true
        ArchivePath = $archiveTarget
        Errors = @()
    }
}

if ($MyInvocation.InvocationName -ne '.' -and $args.Count -ge 1) {
    $changeIdArgument = $args[0]
    $workspaceRootArgument = if ($args.Count -ge 2) { $args[1] } else { (Get-Location).Path }

    $result = Invoke-OpenSpecArchive -ChangeId $changeIdArgument -WorkspaceRoot $workspaceRootArgument

    if ($result.Archived) {
        Write-Output "Archived change '$($result.ChangeId)' to $($result.ArchivePath)."
        exit 0
    }

    Write-Output "Archive blocked for change '$($result.ChangeId)':"
    foreach ($archiveError in $result.Errors) {
        Write-Output " - $archiveError"
    }

    exit 2
}
