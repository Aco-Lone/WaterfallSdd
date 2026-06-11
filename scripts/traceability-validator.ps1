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

function Test-TraceabilityDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    $content = Get-Content -Path $FilePath -Raw -Encoding UTF8
    $lines = $content -split "`r?`n"
    $errors = New-Object System.Collections.Generic.List[string]
    $documentType = 'Unknown'

    if (Test-MarkdownSection -Content $content -SectionHeading 'Requirements') {
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