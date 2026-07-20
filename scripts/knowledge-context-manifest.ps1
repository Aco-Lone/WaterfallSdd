$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDirectory 'traceability-validator.ps1')

function Get-KnowledgeFilePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$KnowledgeRoot,

        [Parameter(Mandatory = $true)]
        [string]$KnowledgeId
    )

    $searchDirs = @(
        (Join-Path $KnowledgeRoot 'knowledge/glossary'),
        (Join-Path $KnowledgeRoot 'knowledge/business-rules'),
        (Join-Path $KnowledgeRoot 'decisions')
    )

    foreach ($dir in $searchDirs) {
        if (-not (Test-Path $dir)) {
            continue
        }

        foreach ($file in Get-ChildItem -Path $dir -Filter '*.md' -File) {
            $lines = (Get-Content -Path $file.FullName -Raw -Encoding UTF8) -split "`r?`n"
            foreach ($section in @('Glossary Term', 'Business Rule', 'Decision Record')) {
                foreach ($field in @('Term ID', 'Rule ID', 'ADR ID')) {
                    $value = Get-ControlFieldValue -Lines $lines -SectionHeading $section -FieldName $field
                    if ($value -eq $KnowledgeId) {
                        return $file.FullName
                    }
                }
            }
        }
    }

    return $null
}

function Get-KnowledgeStatus {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    $lines = (Get-Content -Path $FilePath -Raw -Encoding UTF8) -split "`r?`n"
    foreach ($section in @('Glossary Term', 'Business Rule', 'Decision Record')) {
        $status = Get-ControlFieldValue -Lines $lines -SectionHeading $section -FieldName 'Status'
        if (-not [string]::IsNullOrWhiteSpace($status)) {
            return $status
        }
    }

    return ''
}

function New-KnowledgeContextManifest {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ChangeId,

        [Parameter(Mandatory = $true)]
        [string]$Phase,

        [Parameter(Mandatory = $false)]
        [AllowEmptyCollection()]
        [string[]]$OriginIds = @(),

        [Parameter(Mandatory = $false)]
        [AllowEmptyCollection()]
        [string[]]$KnowledgeIds = @(),

        [Parameter(Mandatory = $false)]
        [string]$WorkspaceRoot = (Get-Location).Path
    )

    $knowledgeRoot = Join-Path $WorkspaceRoot 'openspec'
    $resolved = New-Object System.Collections.Generic.List[object]
    $unresolved = New-Object System.Collections.Generic.List[string]

    foreach ($knowledgeId in $KnowledgeIds) {
        if ([string]::IsNullOrWhiteSpace($knowledgeId)) {
            continue
        }

        $filePath = Get-KnowledgeFilePath -KnowledgeRoot $knowledgeRoot -KnowledgeId $knowledgeId
        if ($null -eq $filePath) {
            $unresolved.Add($knowledgeId)
            continue
        }

        $relativePath = [System.IO.Path]::GetRelativePath($knowledgeRoot, $filePath) -replace '\\', '/'
        $hash = (Get-FileHash -Path $filePath -Algorithm SHA256).Hash

        $resolved.Add([pscustomobject]@{
            knowledgeId = $knowledgeId
            sourcePath = $relativePath
            status = Get-KnowledgeStatus -FilePath $filePath
            contentHash = $hash
        })
    }

    $manifest = [pscustomobject]@{
        changeId = $ChangeId
        phase = $Phase
        originIds = [string[]]$OriginIds
        resolvedKnowledge = [object[]]$resolved.ToArray()
        unresolvedReferences = [string[]]$unresolved.ToArray()
        conflicts = [object[]]@()
        generatedAt = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    }

    $changeDirectory = Join-Path $knowledgeRoot (Join-Path 'changes' $ChangeId)
    $reviewsDirectory = Join-Path $changeDirectory 'reviews'
    if (-not (Test-Path $reviewsDirectory)) {
        New-Item -ItemType Directory -Path $reviewsDirectory -Force | Out-Null
    }

    $manifestPath = Join-Path $reviewsDirectory ("context-manifest-{0}.json" -f $Phase)
    $manifest | ConvertTo-Json -Depth 6 | Set-Content -Path $manifestPath -Encoding UTF8

    return [pscustomobject]@{
        ManifestPath = $manifestPath
        ResolvedCount = $resolved.Count
        UnresolvedReferences = $unresolved.ToArray()
    }
}

if ($MyInvocation.InvocationName -ne '.' -and $args.Count -ge 2) {
    $changeIdArgument = $args[0]
    $phaseArgument = $args[1]
    $knowledgeIdArguments = if ($args.Count -ge 3) { $args[2..($args.Count - 1)] } else { @() }

    $result = New-KnowledgeContextManifest -ChangeId $changeIdArgument -Phase $phaseArgument -KnowledgeIds $knowledgeIdArguments -WorkspaceRoot (Get-Location).Path

    Write-Output "Generated context manifest at $($result.ManifestPath) with $($result.ResolvedCount) resolved references."
    if ($result.UnresolvedReferences.Count -gt 0) {
        Write-Output "Unresolved references:"
        foreach ($unresolvedReference in $result.UnresolvedReferences) {
            Write-Output " - $unresolvedReference"
        }

        exit 2
    }

    exit 0
}
