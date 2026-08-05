$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDirectory 'traceability-validator.ps1')
. (Join-Path $scriptDirectory 'knowledge-index.ps1')

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

    $knowledgeDeltaPath = Join-Path $ChangeDirectory 'knowledge-delta.md'
    if (Test-Path $knowledgeDeltaPath) {
        $knowledgeResult = Test-TraceabilityDocument -FilePath $knowledgeDeltaPath
        if (-not $knowledgeResult.IsValid) {
            $errors.Add("Traceability validation failed for ${knowledgeDeltaPath}: $($knowledgeResult.Errors -join '; ')")
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

function Get-KnowledgeDeltaRows {
    param(
        [Parameter(Mandatory = $true)]
        [string]$KnowledgeDeltaPath
    )

    $content = Get-Content -Path $KnowledgeDeltaPath -Raw -Encoding UTF8
    $lines = $content -split "`r?`n"
    $rows = Get-MarkdownTableRows -Lines $lines -SectionHeading 'Knowledge Delta'

    $deltaRows = New-Object System.Collections.Generic.List[object]
    foreach ($row in $rows) {
        $deltaId = if ($row.Count -gt 0) { $row[0] } else { '' }
        if ([string]::IsNullOrWhiteSpace($deltaId)) {
            continue
        }

        $deltaRows.Add([pscustomobject]@{
            DeltaId = $deltaId
            Operation = if ($row.Count -gt 1) { $row[1] } else { '' }
            KnowledgeId = if ($row.Count -gt 2) { $row[2] } else { '' }
            Kind = if ($row.Count -gt 3) { $row[3] } else { '' }
            Summary = if ($row.Count -gt 4) { $row[4] } else { '' }
            RelatedRequirementIds = if ($row.Count -gt 5) { $row[5] } else { '' }
            Rationale = if ($row.Count -gt 6) { $row[6] } else { '' }
        })
    }

    return , $deltaRows.ToArray()
}

function Get-KnowledgeKindDir {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Kind
    )

    switch ($Kind.Trim().ToUpperInvariant()) {
        'TERM' { return 'glossary' }
        'RULE' { return 'business-rules' }
        default { return $null }
    }
}

function Set-KnowledgeFileField {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string]$FieldName,

        [Parameter(Mandatory = $true)]
        [string]$NewValue
    )

    $lines = @(Get-Content -Path $FilePath -Encoding UTF8)
    $fieldPattern = '^' + [regex]::Escape($FieldName) + ':\s*'
    $inFrontmatter = $false
    $updated = $false

    for ($index = 0; $index -lt $lines.Count; $index++) {
        if ($lines[$index].Trim() -eq '---') {
            if (-not $inFrontmatter) {
                $inFrontmatter = $true
                continue
            }
            else {
                break
            }
        }

        if ($inFrontmatter -and $lines[$index] -match $fieldPattern) {
            $lines[$index] = "${FieldName}: $NewValue"
            $updated = $true
            break
        }
    }

    if (-not $updated -and $inFrontmatter) {
        # Insert the field just after the opening frontmatter marker.
        for ($index = 0; $index -lt $lines.Count; $index++) {
            if ($lines[$index].Trim() -eq '---') {
                $lines = $lines[0..$index] + @("${FieldName}: $NewValue") + $lines[($index + 1)..($lines.Count - 1)]
                break
            }
        }
    }

    $lines | Set-Content -Path $FilePath -Encoding UTF8
}

function New-BaselineKnowledgeFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string]$Kind,

        [Parameter(Mandatory = $true)]
        $Delta
    )

    if ($Kind.Trim().ToUpperInvariant() -eq 'TERM') {
        $type = 'glossary-term'
        $bodyHeading = 'Glossary Term'
    }
    else {
        $type = 'business-rule'
        $bodyHeading = 'Business Rule'
    }

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add('---')
    $lines.Add("type: $type")
    $lines.Add("id: $($Delta.KnowledgeId)")
    $lines.Add('status: Active')
    $lines.Add('related_reqs:')
    foreach ($reqId in ($Delta.RelatedRequirementIds -split ',')) {
        $trimmed = $reqId.Trim()
        if (-not [string]::IsNullOrWhiteSpace($trimmed)) {
            $lines.Add("  - $trimmed")
        }
    }
    $lines.Add('---')
    $lines.Add('')
    $lines.Add("# $bodyHeading")
    $lines.Add('')
    $lines.Add('## Summary')
    $lines.Add('')
    $lines.Add("- $($Delta.Summary)")
    $lines.Add('')
    $lines.Add('## Rationale')
    $lines.Add('')
    $lines.Add("- $($Delta.Rationale)")

    New-Item -ItemType Directory -Path (Split-Path -Parent $FilePath) -Force | Out-Null
    $lines | Set-Content -Path $FilePath -Encoding UTF8
}

function Update-BaselineKnowledge {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ChangeDirectory,

        [Parameter(Mandatory = $true)]
        [string]$KnowledgeRoot,

        [Parameter(Mandatory = $true)]
        $KnowledgeDeltaRows
    )

    foreach ($delta in $KnowledgeDeltaRows) {
        $kindDir = Get-KnowledgeKindDir -Kind $delta.Kind
        if ($null -eq $kindDir) {
            continue
        }

        $fileName = "$($delta.KnowledgeId).md"
        $baselineFile = Join-Path $KnowledgeRoot (Join-Path 'knowledge' (Join-Path $kindDir $fileName))
        $changeLocalFile = Join-Path $ChangeDirectory (Join-Path 'knowledge' (Join-Path $kindDir $fileName))

        switch ($delta.Operation) {
            'ADDED' {
                New-Item -ItemType Directory -Path (Split-Path -Parent $baselineFile) -Force | Out-Null
                if (Test-Path $changeLocalFile) {
                    Copy-Item -Path $changeLocalFile -Destination $baselineFile -Force
                }
                else {
                    New-BaselineKnowledgeFile -FilePath $baselineFile -Kind $delta.Kind -Delta $delta
                }
            }
            'MODIFIED' {
                if (Test-Path $changeLocalFile) {
                    New-Item -ItemType Directory -Path (Split-Path -Parent $baselineFile) -Force | Out-Null
                    Copy-Item -Path $changeLocalFile -Destination $baselineFile -Force
                }
                elseif (Test-Path $baselineFile) {
                    Set-KnowledgeFileField -FilePath $baselineFile -FieldName 'Status' -NewValue 'Active'
                }
            }
            'REMOVED' {
                if (Test-Path $baselineFile) {
                    Set-KnowledgeFileField -FilePath $baselineFile -FieldName 'Status' -NewValue 'Obsolete'
                }
            }
        }
    }
}

function Get-KnowledgeFileFieldValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string]$FieldName
    )

    $lines = (Get-Content -Path $FilePath -Raw -Encoding UTF8) -split "`r?`n"
    return Get-FrontmatterValue -Lines $lines -Key $FieldName
}

function Promote-DecisionRecords {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ChangeDirectory,

        [Parameter(Mandatory = $true)]
        [string]$KnowledgeRoot
    )

    $changeDecisionsDir = Join-Path $ChangeDirectory 'decisions'
    if (-not (Test-Path $changeDecisionsDir)) {
        return
    }

    $baselineDecisionsDir = Join-Path $KnowledgeRoot 'decisions'
    New-Item -ItemType Directory -Path $baselineDecisionsDir -Force | Out-Null

    foreach ($file in Get-ChildItem -Path $changeDecisionsDir -Filter '*.md' -File) {
        $status = Get-KnowledgeFileFieldValue -FilePath $file.FullName -FieldName 'status'
        if ($status -ne 'Accepted') {
            continue
        }

        $destination = Join-Path $baselineDecisionsDir $file.Name
        Copy-Item -Path $file.FullName -Destination $destination -Force

        $supersedes = Get-KnowledgeFileFieldValue -FilePath $file.FullName -FieldName 'supersedes'
        $newAdrId = Get-KnowledgeFileFieldValue -FilePath $file.FullName -FieldName 'id'
        if (-not [string]::IsNullOrWhiteSpace($supersedes)) {
            foreach ($existing in Get-ChildItem -Path $baselineDecisionsDir -Filter '*.md' -File) {
                $existingId = Get-KnowledgeFileFieldValue -FilePath $existing.FullName -FieldName 'id'
                if ($existingId -eq $supersedes) {
                    Set-KnowledgeFileField -FilePath $existing.FullName -FieldName 'status' -NewValue 'Superseded'
                    Set-KnowledgeFileField -FilePath $existing.FullName -FieldName 'superseded_by' -NewValue $newAdrId
                }
            }
        }
    }
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

    $knowledgeRoot = Join-Path $WorkspaceRoot 'openspec'
    $knowledgeDeltaPath = Join-Path $changeDirectory 'knowledge-delta.md'
    if (Test-Path $knowledgeDeltaPath) {
        $knowledgeDeltaRows = Get-KnowledgeDeltaRows -KnowledgeDeltaPath $knowledgeDeltaPath
        Update-BaselineKnowledge -ChangeDirectory $changeDirectory -KnowledgeRoot $knowledgeRoot -KnowledgeDeltaRows $knowledgeDeltaRows
    }

    Promote-DecisionRecords -ChangeDirectory $changeDirectory -KnowledgeRoot $knowledgeRoot
    Invoke-KnowledgeIndex -WorkspaceRoot $WorkspaceRoot | Out-Null

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
