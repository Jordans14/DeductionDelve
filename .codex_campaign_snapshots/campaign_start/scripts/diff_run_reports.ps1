param(
    [Parameter(Mandatory = $true)]
    [string]$HostReport,
    [Parameter(Mandatory = $true)]
    [string]$ClientReport
)

$ErrorActionPreference = "Stop"

function Get-FactLinesFromReport {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        throw "Report file missing: $Path"
    }
    $lines = Get-Content $Path
    $factsStart = -1
    $notesStart = $lines.Count
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i].Trim()
        if ($line -eq "FACTS" -and $factsStart -lt 0) {
            $factsStart = $i + 1
            continue
        }
        if ($line.StartsWith("YOUR NOTES")) {
            $notesStart = $i
            break
        }
    }
    if ($factsStart -lt 0) {
        throw "FACTS section missing in $Path"
    }
    $result = New-Object System.Collections.Generic.List[string]
    for ($i = $factsStart; $i -lt $notesStart; $i++) {
        $normalized = $lines[$i].Trim()
        if ([string]::IsNullOrWhiteSpace($normalized)) {
            continue
        }
        $result.Add($normalized)
    }
    return $result
}

$hostFacts = Get-FactLinesFromReport -Path $HostReport
$clientFacts = Get-FactLinesFromReport -Path $ClientReport

$mismatches = New-Object System.Collections.Generic.List[string]
$maxCount = [Math]::Max($hostFacts.Count, $clientFacts.Count)
for ($i = 0; $i -lt $maxCount; $i++) {
    $hostLine = if ($i -lt $hostFacts.Count) { $hostFacts[$i] } else { "<missing>" }
    $clientLine = if ($i -lt $clientFacts.Count) { $clientFacts[$i] } else { "<missing>" }
    if ($hostLine -ne $clientLine) {
        $mismatches.Add("index=$i host='$hostLine' client='$clientLine'")
    }
}

if ($mismatches.Count -eq 0) {
    Write-Output "REPORT_DIFF ok=true mismatches=0"
    exit 0
}

Write-Output ("REPORT_DIFF ok=false mismatches={0} first={1}" -f $mismatches.Count, $mismatches[0])
exit 1
