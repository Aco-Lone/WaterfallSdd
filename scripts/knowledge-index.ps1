$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDirectory 'traceability-validator.ps1')

function Get-SectionFirstBullet {
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
        return ''
    }

    for ($index = $sectionIndex + 1; $index -lt $Lines.Count; $index++) {
        $line = $Lines[$index].Trim()
        if ($line -match '^##\s') {
            break
        }

        if ($line -match '^-\s+(.+)$') {
            return $Matches[1].Trim()
        }
    }

    return ''
}

function Get-KnowledgeEntry {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string]$Kind,

        [Parameter(Mandatory = $true)]
        [string]$KnowledgeRoot
    )

    $lines = (Get-Content -Path $FilePath -Raw -Encoding UTF8) -split "`r?`n"

    switch ($Kind) {
        'TERM' {
            $section = 'Glossary Term'
            $idField = 'Term ID'
            $summary = Get-ControlFieldValue -Lines $lines -SectionHeading $section -FieldName 'Term'
        }
        'RULE' {
            $section = 'Business Rule'
            $idField = 'Rule ID'
            $summary = Get-SectionFirstBullet -Lines $lines -SectionHeading 'Condition'
        }
        'ADR' {
            $section = 'Decision Record'
            $idField = 'ADR ID'
            $summary = Get-ControlFieldValue -Lines $lines -SectionHeading $section -FieldName 'Title'
        }
    }

    $knowledgeId = Get-ControlFieldValue -Lines $lines -SectionHeading $section -FieldName $idField
    if ([string]::IsNullOrWhiteSpace($knowledgeId)) {
        return $null
    }

    $status = Get-ControlFieldValue -Lines $lines -SectionHeading $section -FieldName 'Status'
    $owner = Get-ControlFieldValue -Lines $lines -SectionHeading $section -FieldName 'Owner'
    $subsystem = Get-ControlFieldValue -Lines $lines -SectionHeading $section -FieldName 'Subsystem'

    $relativePath = [System.IO.Path]::GetRelativePath($KnowledgeRoot, $FilePath) -replace '\\', '/'

    return [pscustomobject]@{
        KnowledgeId = $knowledgeId
        Kind = $Kind
        Summary = $summary
        Status = $status
        Owner = $owner
        SourcePath = $relativePath
        Subsystem = $subsystem
    }
}

function Get-KnowledgeEntries {
    param(
        [Parameter(Mandatory = $true)]
        [string]$KnowledgeRoot
    )

    $entries = New-Object System.Collections.Generic.List[object]

    $sources = @(
        @{ Dir = (Join-Path $KnowledgeRoot 'knowledge/glossary'); Kind = 'TERM' },
        @{ Dir = (Join-Path $KnowledgeRoot 'knowledge/business-rules'); Kind = 'RULE' },
        @{ Dir = (Join-Path $KnowledgeRoot 'decisions'); Kind = 'ADR' }
    )

    foreach ($source in $sources) {
        if (-not (Test-Path $source.Dir)) {
            continue
        }

        foreach ($file in Get-ChildItem -Path $source.Dir -Filter '*.md' -File | Sort-Object Name) {
            if ($file.Name -eq 'index.md') {
                continue
            }

            $entry = Get-KnowledgeEntry -FilePath $file.FullName -Kind $source.Kind -KnowledgeRoot $KnowledgeRoot
            if ($null -ne $entry) {
                $entries.Add($entry)
            }
        }
    }

    return , $entries.ToArray()
}

function Invoke-KnowledgeIndex {
    param(
        [Parameter(Mandatory = $false)]
        [string]$WorkspaceRoot = (Get-Location).Path
    )

    $knowledgeRoot = Join-Path $WorkspaceRoot 'openspec'
    $knowledgeDir = Join-Path $knowledgeRoot 'knowledge'

    if (-not (Test-Path $knowledgeDir)) {
        New-Item -ItemType Directory -Path $knowledgeDir -Force | Out-Null
    }

    $entries = Get-KnowledgeEntries -KnowledgeRoot $knowledgeRoot

    $duplicateIds = @($entries | Group-Object -Property KnowledgeId | Where-Object { $_.Count -gt 1 } | Select-Object -ExpandProperty Name)

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add('# Knowledge Index')
    $lines.Add('')
    $lines.Add('## Index Principles')
    $lines.Add('')
    $lines.Add('- This index is generated from the sources of truth. Do not edit it by hand.')
    $lines.Add('- Regenerate it with `scripts/knowledge-index.ps1` after knowledge or decision files change.')
    $lines.Add('')
    $lines.Add('## Knowledge Index')
    $lines.Add('')
    $lines.Add('| Knowledge ID | Kind | Summary | Status | Owner | Source Path | Subsystem |')
    $lines.Add('| --- | --- | --- | --- | --- | --- | --- |')

    foreach ($entry in $entries) {
        $lines.Add(('| {0} | {1} | {2} | {3} | {4} | {5} | {6} |' -f `
            $entry.KnowledgeId, $entry.Kind, $entry.Summary, $entry.Status, $entry.Owner, $entry.SourcePath, $entry.Subsystem))
    }

    $indexPath = Join-Path $knowledgeDir 'index.md'
    $lines | Set-Content -Path $indexPath -Encoding UTF8

    return [pscustomobject]@{
        IndexPath = $indexPath
        EntryCount = $entries.Count
        DuplicateIds = $duplicateIds
    }
}

if ($MyInvocation.InvocationName -ne '.' ) {
    $workspaceRootArgument = if ($args.Count -ge 1) { $args[0] } else { (Get-Location).Path }
    $result = Invoke-KnowledgeIndex -WorkspaceRoot $workspaceRootArgument

    Write-Output "Generated knowledge index at $($result.IndexPath) with $($result.EntryCount) entries."
    if ($result.DuplicateIds.Count -gt 0) {
        Write-Output "Duplicate knowledge IDs detected:"
        foreach ($duplicateId in $result.DuplicateIds) {
            Write-Output " - $duplicateId"
        }

        exit 2
    }

    exit 0
}
