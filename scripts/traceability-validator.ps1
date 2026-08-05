function Split-MarkdownTableRow {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Line
    )

    $trimmedLine = $Line.Trim()
    if (-not $trimmedLine.StartsWith('|')) {
        return @()
    }

    $cells = $trimmedLine -split '\|'
    if ($cells.Count -lt 3) {
        return @()
    }

    return $cells[1..($cells.Count - 2)] | ForEach-Object { $_.Trim() }
}

function Get-MarkdownTableRows {
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
        return @()
    }

    $tableRows = New-Object System.Collections.Generic.List[string[]]
    $tableStarted = $false

    for ($index = $sectionIndex + 1; $index -lt $Lines.Count; $index++) {
        $line = $Lines[$index]

        if ([string]::IsNullOrWhiteSpace($line)) {
            if ($tableStarted) {
                break
            }

            continue
        }

        if (-not $line.Trim().StartsWith('|')) {
            if ($tableStarted) {
                break
            }

            continue
        }

        $tableStarted = $true
        $cells = Split-MarkdownTableRow -Line $line
        if ($cells.Count -gt 0) {
            $tableRows.Add($cells)
        }
    }

    if ($tableRows.Count -le 2) {
        return @()
    }

    $dataRows = New-Object System.Collections.Generic.List[object]
    for ($index = 2; $index -lt $tableRows.Count; $index++) {
        $dataRows.Add($tableRows[$index])
    }

    return ,($dataRows.ToArray())
}

function Add-DuplicateIdErrors {
    param(
        $Ids,

        [string]$Label,

        $Errors
    )

    $duplicateIds = @($Ids) |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
        Group-Object |
        Where-Object { $_.Count -gt 1 } |
        Select-Object -ExpandProperty Name

    foreach ($duplicateId in $duplicateIds) {
        $Errors.Add("Duplicate $Label ID detected: $duplicateId")
    }
}

function Add-KnowledgeFrontmatterErrors {
    param(
        [string]$KnowledgeId,

        [string]$FileBaseName,

        [string]$Label,

        $Errors
    )

    if ([string]::IsNullOrWhiteSpace($KnowledgeId)) {
        $Errors.Add("Missing $Label id in frontmatter: $FileBaseName")
        return
    }

    if ($KnowledgeId -ne $FileBaseName) {
        $Errors.Add("$Label id '$KnowledgeId' does not match file name: $FileBaseName")
    }
}

function Test-MarkdownSection {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Content,

        [Parameter(Mandatory = $true)]
        [string]$SectionHeading
    )

    $headingPattern = '(?m)^##\s+' + [regex]::Escape($SectionHeading) + '\s*$'
    return $Content -match $headingPattern
}

function Resolve-BaselineSpecPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    $resolved = Resolve-Path -Path $FilePath -ErrorAction SilentlyContinue
    $directory = if ($resolved) { Split-Path -Parent $resolved.Path } else { Split-Path -Parent $FilePath }

    while (-not [string]::IsNullOrEmpty($directory)) {
        $candidates = @(
            (Join-Path $directory 'openspec/specs/subsystem-spec.md'),
            (Join-Path $directory 'specs/subsystem-spec.md')
        )

        foreach ($candidate in $candidates) {
            if (Test-Path $candidate) {
                return $candidate
            }
        }

        $parent = Split-Path -Parent $directory
        if ($parent -eq $directory) {
            break
        }

        $directory = $parent
    }

    return $null
}

function Get-RequirementIdsFromSpec {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SpecFilePath
    )

    $content = Get-Content -Path $SpecFilePath -Raw -Encoding UTF8
    $lines = $content -split "`r?`n"
    $rows = Get-MarkdownTableRows -Lines $lines -SectionHeading 'Requirements'

    return @($rows |
        ForEach-Object { if ($_.Count -gt 0) { $_[0] } } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Get-SiblingDeltaRequirementIds {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    $directory = Split-Path -Parent $FilePath
    $deltaPath = Join-Path $directory 'spec-delta.md'
    if (-not (Test-Path $deltaPath)) {
        return $null
    }

    $content = Get-Content -Path $deltaPath -Raw -Encoding UTF8
    $lines = $content -split "`r?`n"
    $rows = Get-MarkdownTableRows -Lines $lines -SectionHeading 'Spec Delta'

    return @($rows |
        ForEach-Object { if ($_.Count -gt 2) { $_[2] } } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Get-ControlFieldValue {
    param(
        [Parameter(Mandatory = $true)]
        $Lines,

        [Parameter(Mandatory = $true)]
        [string]$SectionHeading,

        [Parameter(Mandatory = $true)]
        [string]$FieldName
    )

    $rows = Get-MarkdownTableRows -Lines $Lines -SectionHeading $SectionHeading
    foreach ($row in $rows) {
        if ($row.Count -ge 2 -and $row[0] -eq $FieldName) {
            return $row[1]
        }
    }

    return ''
}

function Get-Frontmatter {
    param(
        [Parameter(Mandatory = $true)]
        $Lines
    )

    $frontmatter = @{}

    if ($Lines.Count -eq 0 -or $Lines[0].Trim() -ne '---') {
        return $frontmatter
    }

    $currentKey = $null

    for ($index = 1; $index -lt $Lines.Count; $index++) {
        $line = $Lines[$index]

        if ($line.Trim() -eq '---') {
            break
        }

        # List item under the current key, for example:
        #   - REQ-001
        if ($line -match '^\s*-\s+(.*)$' -and $null -ne $currentKey) {
            $item = ($Matches[1].Trim()).Trim('"').Trim("'")
            if (-not [string]::IsNullOrWhiteSpace($item)) {
                ([System.Collections.Generic.List[string]]$frontmatter[$currentKey]).Add($item)
            }

            continue
        }

        # key: value
        if ($line -match '^([A-Za-z0-9_-]+):\s*(.*)$') {
            $key = $Matches[1].Trim()
            $value = $Matches[2].Trim()

            if ([string]::IsNullOrWhiteSpace($value)) {
                # Value may be an empty scalar or the start of a list on following lines.
                $frontmatter[$key] = New-Object System.Collections.Generic.List[string]
                $currentKey = $key
            }
            else {
                $frontmatter[$key] = $value.Trim('"').Trim("'")
                $currentKey = $null
            }
        }
    }

    return $frontmatter
}

function Get-FrontmatterValue {
    param(
        [Parameter(Mandatory = $true)]
        $Lines,

        [Parameter(Mandatory = $true)]
        [string]$Key
    )

    $frontmatter = Get-Frontmatter -Lines $Lines
    if (-not $frontmatter.ContainsKey($Key)) {
        return ''
    }

    $value = $frontmatter[$Key]
    if ($value -is [System.Collections.Generic.List[string]]) {
        return ($value -join ', ')
    }

    return [string]$value
}

function Get-FrontmatterType {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Content
    )

    $lines = $Content -split "`r?`n"
    return Get-FrontmatterValue -Lines $lines -Key 'type'
}

function Resolve-BaselineKnowledgeDir {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    $resolved = Resolve-Path -Path $FilePath -ErrorAction SilentlyContinue
    $directory = if ($resolved) { Split-Path -Parent $resolved.Path } else { Split-Path -Parent $FilePath }

    while (-not [string]::IsNullOrEmpty($directory)) {
        $candidate = Join-Path $directory 'openspec/knowledge'
        if (Test-Path $candidate) {
            return $candidate
        }

        $parent = Split-Path -Parent $directory
        if ($parent -eq $directory) {
            break
        }

        $directory = $parent
    }

    return $null
}

function Get-BaselineKnowledgeIds {
    param(
        [Parameter(Mandatory = $true)]
        [string]$KnowledgeDir
    )

    $ids = New-Object System.Collections.Generic.List[string]

    $glossaryDir = Join-Path $KnowledgeDir 'glossary'
    if (Test-Path $glossaryDir) {
        foreach ($file in Get-ChildItem -Path $glossaryDir -Filter '*.md' -File) {
            $lines = (Get-Content -Path $file.FullName -Raw -Encoding UTF8) -split "`r?`n"
            $termId = Get-FrontmatterValue -Lines $lines -Key 'id'
            if (-not [string]::IsNullOrWhiteSpace($termId)) {
                $ids.Add($termId)
            }
        }
    }

    $ruleDir = Join-Path $KnowledgeDir 'business-rules'
    if (Test-Path $ruleDir) {
        foreach ($file in Get-ChildItem -Path $ruleDir -Filter '*.md' -File) {
            $lines = (Get-Content -Path $file.FullName -Raw -Encoding UTF8) -split "`r?`n"
            $ruleId = Get-FrontmatterValue -Lines $lines -Key 'id'
            if (-not [string]::IsNullOrWhiteSpace($ruleId)) {
                $ids.Add($ruleId)
            }
        }
    }

    return $ids.ToArray()
}

function Test-TraceabilityDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    $content = Get-Content -Path $FilePath -Raw -Encoding UTF8
    $lines = $content -split "`r?`n"
    $errors = New-Object System.Collections.Generic.List[string]
    $documentType = 'Unknown'

    $frontmatterType = Get-FrontmatterType -Content $content
    $fileBaseName = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)

    if ($frontmatterType -eq 'glossary-term') {
        $documentType = 'GlossaryTerm'
        $termId = Get-FrontmatterValue -Lines $lines -Key 'id'
        $status = Get-FrontmatterValue -Lines $lines -Key 'status'

        Add-KnowledgeFrontmatterErrors -KnowledgeId $termId -FileBaseName $fileBaseName -Label 'glossary term' -Errors $errors

        if (-not [string]::IsNullOrWhiteSpace($termId) -and $status -notmatch '^(Draft|Active|Obsolete)$') {
            $errors.Add("Invalid glossary term status for ${termId}: '$status'")
        }
    }
    elseif ($frontmatterType -eq 'business-rule') {
        $documentType = 'BusinessRule'
        $ruleId = Get-FrontmatterValue -Lines $lines -Key 'id'
        $status = Get-FrontmatterValue -Lines $lines -Key 'status'

        Add-KnowledgeFrontmatterErrors -KnowledgeId $ruleId -FileBaseName $fileBaseName -Label 'business rule' -Errors $errors

        if (-not [string]::IsNullOrWhiteSpace($ruleId) -and $status -notmatch '^(Draft|Active|Obsolete)$') {
            $errors.Add("Invalid business rule status for ${ruleId}: '$status'")
        }
    }
    elseif ($frontmatterType -eq 'decision-record') {
        $documentType = 'DecisionRecord'
        $adrId = Get-FrontmatterValue -Lines $lines -Key 'id'
        $status = Get-FrontmatterValue -Lines $lines -Key 'status'

        if ([string]::IsNullOrWhiteSpace($adrId)) {
            $errors.Add("Missing decision record id in frontmatter: $fileBaseName")
        }
        elseif ($fileBaseName -notlike "$adrId*") {
            $errors.Add("Decision record id '$adrId' does not match file name: $fileBaseName")
        }

        if (-not [string]::IsNullOrWhiteSpace($adrId) -and $status -notmatch '^(Draft|Proposed|Accepted|Superseded|Rejected)$') {
            $errors.Add("Invalid decision record status for ${adrId}: '$status'")
        }
    }
    elseif ($frontmatterType -eq 'knowledge-delta' -or (Test-MarkdownSection -Content $content -SectionHeading 'Knowledge Delta')) {
        $documentType = 'KnowledgeDelta'
        $rows = Get-MarkdownTableRows -Lines $lines -SectionHeading 'Knowledge Delta'
        $deltaIds = @($rows | ForEach-Object { if ($_.Count -gt 0) { $_[0] } })
        Add-DuplicateIdErrors -Ids $deltaIds -Label 'knowledge delta item' -Errors $errors

        $baselineKnowledgeDir = Resolve-BaselineKnowledgeDir -FilePath $FilePath
        $baselineKnowledgeIds = if ($baselineKnowledgeDir) { @(Get-BaselineKnowledgeIds -KnowledgeDir $baselineKnowledgeDir) } else { $null }

        foreach ($row in $rows) {
            $deltaId = if ($row.Count -gt 0) { $row[0] } else { '' }
            $operation = if ($row.Count -gt 1) { $row[1] } else { '' }
            $knowledgeId = if ($row.Count -gt 2) { $row[2] } else { '' }

            if ([string]::IsNullOrWhiteSpace($deltaId)) {
                continue
            }

            if ($operation -notmatch '^(ADDED|MODIFIED|REMOVED)$') {
                $errors.Add("Invalid knowledge delta operation for ${deltaId}: '$operation'")
                continue
            }

            if ([string]::IsNullOrWhiteSpace($knowledgeId)) {
                $errors.Add("Missing knowledge ID in delta item: $deltaId")
                continue
            }

            if ($null -ne $baselineKnowledgeIds) {
                $existsInBaseline = $baselineKnowledgeIds -contains $knowledgeId

                if ($operation -eq 'ADDED' -and $existsInBaseline) {
                    $errors.Add("ADDED knowledge already exists in baseline: $knowledgeId")
                }
                elseif (($operation -eq 'MODIFIED' -or $operation -eq 'REMOVED') -and -not $existsInBaseline) {
                    $errors.Add("$operation knowledge not found in baseline: $knowledgeId")
                }
            }
        }
    }
    elseif ($frontmatterType -eq 'bundle' -or (Test-MarkdownSection -Content $content -SectionHeading 'Knowledge Index')) {
        $documentType = 'KnowledgeIndex'
        $rows = Get-MarkdownTableRows -Lines $lines -SectionHeading 'Knowledge Index'
        $indexIds = @($rows | ForEach-Object { if ($_.Count -gt 0) { $_[0] } })
        Add-DuplicateIdErrors -Ids $indexIds -Label 'knowledge index' -Errors $errors
    }
    elseif (Test-MarkdownSection -Content $content -SectionHeading 'Spec Delta') {
        $documentType = 'SpecDelta'
        $rows = Get-MarkdownTableRows -Lines $lines -SectionHeading 'Spec Delta'
        $deltaIds = @($rows | ForEach-Object { if ($_.Count -gt 0) { $_[0] } })
        Add-DuplicateIdErrors -Ids $deltaIds -Label 'delta item' -Errors $errors

        $baselineSpecPath = Resolve-BaselineSpecPath -FilePath $FilePath
        $baselineRequirementIds = if ($baselineSpecPath) { @(Get-RequirementIdsFromSpec -SpecFilePath $baselineSpecPath) } else { $null }

        foreach ($row in $rows) {
            $deltaId = if ($row.Count -gt 0) { $row[0] } else { '' }
            $operation = if ($row.Count -gt 1) { $row[1] } else { '' }
            $requirementId = if ($row.Count -gt 2) { $row[2] } else { '' }

            if ([string]::IsNullOrWhiteSpace($deltaId)) {
                continue
            }

            if ($operation -notmatch '^(ADDED|MODIFIED|REMOVED)$') {
                $errors.Add("Invalid delta operation for ${deltaId}: '$operation'")
                continue
            }

            if ([string]::IsNullOrWhiteSpace($requirementId)) {
                $errors.Add("Missing requirement ID in delta item: $deltaId")
                continue
            }

            if ($null -ne $baselineRequirementIds) {
                $existsInBaseline = $baselineRequirementIds -contains $requirementId

                if ($operation -eq 'ADDED' -and $existsInBaseline) {
                    $errors.Add("ADDED requirement already exists in baseline: $requirementId")
                }
                elseif (($operation -eq 'MODIFIED' -or $operation -eq 'REMOVED') -and -not $existsInBaseline) {
                    $errors.Add("$operation requirement not found in baseline: $requirementId")
                }
            }
        }
    }
    elseif (Test-MarkdownSection -Content $content -SectionHeading 'Impact Map') {
        $documentType = 'ChangeImpactMap'
        $rows = Get-MarkdownTableRows -Lines $lines -SectionHeading 'Impact Map'
        $impactIds = @($rows | ForEach-Object { if ($_.Count -gt 0) { $_[0] } })
        Add-DuplicateIdErrors -Ids $impactIds -Label 'impact item' -Errors $errors

        $mappedRequirementIds = New-Object System.Collections.Generic.List[string]

        foreach ($row in $rows) {
            $impactId = if ($row.Count -gt 0) { $row[0] } else { '' }
            $requirementId = if ($row.Count -gt 1) { $row[1] } else { '' }
            $operation = if ($row.Count -gt 2) { $row[2] } else { '' }
            $affectedCsproj = if ($row.Count -gt 3) { $row[3] } else { '' }
            $reReviewRequired = if ($row.Count -gt 7) { $row[7] } else { '' }
            $gateRecord = if ($row.Count -gt 8) { $row[8] } else { '' }

            if ([string]::IsNullOrWhiteSpace($impactId)) {
                continue
            }

            if (-not [string]::IsNullOrWhiteSpace($requirementId)) {
                $mappedRequirementIds.Add($requirementId)
            }

            if (($operation -eq 'ADDED' -or $operation -eq 'MODIFIED') -and [string]::IsNullOrWhiteSpace($affectedCsproj)) {
                $errors.Add("Affected csproj missing for impact item: $impactId")
            }

            if ($operation -eq 'REMOVED' -and $reReviewRequired -notmatch '^(Yes|Required)$') {
                $errors.Add("REMOVED impact item must require re-review: $impactId")
            }

            if ($reReviewRequired -match '^(Yes|Required)$' -and [string]::IsNullOrWhiteSpace($gateRecord)) {
                $errors.Add("Re-review required but gate record missing: $impactId")
            }
        }

        $deltaRequirementIds = Get-SiblingDeltaRequirementIds -FilePath $FilePath
        if ($null -ne $deltaRequirementIds) {
            foreach ($deltaRequirementId in $deltaRequirementIds) {
                if ($mappedRequirementIds -notcontains $deltaRequirementId) {
                    $errors.Add("Requirement in spec delta is not mapped in impact map: $deltaRequirementId")
                }
            }
        }
    }
    elseif (Test-MarkdownSection -Content $content -SectionHeading 'Requirements') {
        $documentType = 'SubsystemSpec'
        $rows = Get-MarkdownTableRows -Lines $lines -SectionHeading 'Requirements'
        $requirementIds = @($rows | ForEach-Object { if ($_.Count -gt 0) { $_[0] } })
        Add-DuplicateIdErrors -Ids $requirementIds -Label 'requirement' -Errors $errors
    }
    elseif (Test-MarkdownSection -Content $content -SectionHeading 'Traceability Summary') {
        $documentType = 'DetailedDesign'
        $rows = Get-MarkdownTableRows -Lines $lines -SectionHeading 'Traceability Summary'
        $requirementIds = @($rows | ForEach-Object { if ($_.Count -gt 0) { $_[0] } })
        $designElementIds = @($rows | ForEach-Object { if ($_.Count -gt 1) { $_[1] } })

        Add-DuplicateIdErrors -Ids $requirementIds -Label 'requirement' -Errors $errors
        Add-DuplicateIdErrors -Ids $designElementIds -Label 'design element' -Errors $errors

        foreach ($row in $rows) {
            $requirementId = if ($row.Count -gt 0) { $row[0] } else { '' }
            $designElementId = if ($row.Count -gt 1) { $row[1] } else { '' }
            $coverageStatus = if ($row.Count -gt 6) { $row[6] } else { '' }

            if (-not [string]::IsNullOrWhiteSpace($requirementId) -and ([string]::IsNullOrWhiteSpace($designElementId) -or $coverageStatus -match '^(Missing|Partial)$')) {
                $errors.Add("Untraced requirement ID detected: $requirementId")
            }
        }
    }
    elseif (Test-MarkdownSection -Content $content -SectionHeading 'Traceability Matrix') {
        $hasImplementationSequence = Test-MarkdownSection -Content $content -SectionHeading 'Implementation Sequence'
        $hasTestExecutionSequence =
            (Test-MarkdownSection -Content $content -SectionHeading 'Test Execution Sequence') -or
            (Test-MarkdownSection -Content $content -SectionHeading 'Test Execution Plan')

        if ($hasImplementationSequence -and $hasTestExecutionSequence) {
            $documentType = 'CombinedPlan'
            $errors.Add('Combined implementation and test plan documents are no longer supported; use separate files.')
        }
        elseif ($hasImplementationSequence) {
            $documentType = 'ImplementationPlan'
            $rows = Get-MarkdownTableRows -Lines $lines -SectionHeading 'Traceability Matrix'
            $planItemIds = @($rows | ForEach-Object { if ($_.Count -gt 0) { $_[0] } })

            Add-DuplicateIdErrors -Ids $planItemIds -Label 'plan item' -Errors $errors

            foreach ($row in $rows) {
                $planItemId = if ($row.Count -gt 0) { $row[0] } else { '' }
                $requirementIds = if ($row.Count -gt 1) { $row[1] } else { '' }
                $designElementIds = if ($row.Count -gt 2) { $row[2] } else { '' }

                if (-not [string]::IsNullOrWhiteSpace($planItemId) -and ([string]::IsNullOrWhiteSpace($requirementIds) -or [string]::IsNullOrWhiteSpace($designElementIds))) {
                    $errors.Add("Untraced requirement ID detected: $planItemId")
                }
            }
        }
        elseif ($hasTestExecutionSequence) {
            $documentType = 'TestPlan'
            $rows = Get-MarkdownTableRows -Lines $lines -SectionHeading 'Traceability Matrix'
            $testIds = @($rows | ForEach-Object { if ($_.Count -gt 0) { $_[0] } })

            Add-DuplicateIdErrors -Ids $testIds -Label 'test' -Errors $errors

            foreach ($row in $rows) {
                $testId = if ($row.Count -gt 0) { $row[0] } else { '' }
                $requirementIds = if ($row.Count -gt 1) { $row[1] } else { '' }
                $designElementIds = if ($row.Count -gt 2) { $row[2] } else { '' }

                if (-not [string]::IsNullOrWhiteSpace($testId) -and ([string]::IsNullOrWhiteSpace($requirementIds) -or [string]::IsNullOrWhiteSpace($designElementIds))) {
                    $errors.Add("Untraced requirement ID detected: $testId")
                }
            }
        }
    }

    return [pscustomobject]@{
        FilePath = $FilePath
        DocumentType = $documentType
        IsApplicable = $documentType -ne 'Unknown'
        IsValid = $errors.Count -eq 0
        Errors = $errors
    }
}

function Get-HookFilePaths {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Value
    )

    if ($null -eq $Value) {
        return @()
    }

    if ($Value -is [string]) {
        return @($Value)
    }

    $filePaths = @()

    if ($Value -is [System.Collections.IDictionary]) {
        foreach ($key in $Value.Keys) {
            $filePaths += @(Get-HookFilePaths -Value $Value[$key])
        }

        return $filePaths
    }

    if ($Value -is [System.Collections.IEnumerable] -and -not ($Value -is [string])) {
        foreach ($item in $Value) {
            $filePaths += @(Get-HookFilePaths -Value $item)
        }

        return $filePaths
    }

    return @()
}

function Invoke-TraceabilityHook {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$HookInput
    )

    $candidatePaths = @(Get-HookFilePaths -Value $HookInput.tool_input) |
        Where-Object { $_ -is [string] -and $_ -match '\.md$' -and (Test-Path $_) } |
        Select-Object -Unique

    if ($candidatePaths.Count -eq 0) {
        return @{
            hookSpecificOutput = @{
                hookEventName = 'PostToolUse'
                additionalContext = 'No traceability artifacts changed.'
            }
        }
    }

    $results = @($candidatePaths | ForEach-Object { Test-TraceabilityDocument -FilePath $_ })
    $applicableResults = @($results | Where-Object { $_.IsApplicable })

    if ($applicableResults.Count -eq 0) {
        return @{
            hookSpecificOutput = @{
                hookEventName = 'PostToolUse'
                additionalContext = 'No traceability artifacts changed.'
            }
        }
    }

    $invalidResults = @($applicableResults | Where-Object { -not $_.IsValid })
    if ($invalidResults.Count -eq 0) {
        return @{
            hookSpecificOutput = @{
                hookEventName = 'PostToolUse'
                additionalContext = 'Traceability validation passed.'
            }
        }
    }

    $messages = foreach ($result in $invalidResults) {
        $relativePath = Resolve-Path -Path $result.FilePath -Relative
        '{0}: {1}' -f $relativePath, ($result.Errors -join '; ')
    }

    return @{
        decision = 'block'
        reason = 'Traceability validation failed.'
        hookSpecificOutput = @{
            hookEventName = 'PostToolUse'
            additionalContext = ($messages -join "`n")
        }
    }
}