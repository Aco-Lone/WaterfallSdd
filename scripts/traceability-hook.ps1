$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDirectory 'traceability-validator.ps1')

function ConvertTo-PlainValue {
    param(
        [Parameter(Mandatory = $false)]
        $InputObject
    )

    if ($null -eq $InputObject) {
        return $null
    }

    if ($InputObject -is [string] -or $InputObject.GetType().IsPrimitive) {
        return $InputObject
    }

    if ($InputObject -is [System.Collections.IDictionary]) {
        $hash = @{}
        foreach ($key in $InputObject.Keys) {
            $hash[$key] = ConvertTo-PlainValue -InputObject $InputObject[$key]
        }

        return $hash
    }

    if ($InputObject -is [System.Collections.IEnumerable] -and -not ($InputObject -is [string])) {
        $items = @()
        foreach ($item in $InputObject) {
            $items += @(ConvertTo-PlainValue -InputObject $item)
        }

        return $items
    }

    if ($InputObject.PSObject -and $InputObject.PSObject.Properties.Count -gt 0) {
        $hash = @{}
        foreach ($property in $InputObject.PSObject.Properties) {
            $hash[$property.Name] = ConvertTo-PlainValue -InputObject $property.Value
        }

        return $hash
    }

    return $InputObject
}

$rawInput = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($rawInput)) {
    Write-Output (@{
            hookSpecificOutput = @{
                hookEventName = 'PostToolUse'
                additionalContext = 'No hook payload was provided.'
            }
        } | ConvertTo-Json -Depth 6 -Compress)
    exit 0
}

$hookInput = ConvertTo-PlainValue -InputObject (ConvertFrom-Json -InputObject $rawInput)
$result = Invoke-TraceabilityHook -HookInput $hookInput
$json = $result | ConvertTo-Json -Depth 6 -Compress
Write-Output $json

if ($result.decision -eq 'block') {
    exit 2
}

exit 0