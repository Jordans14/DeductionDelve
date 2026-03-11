param(
    [string]$GodotExe = "",
    [int]$Seed = 1337,
    [int]$TimeoutSec = 75
)

$ErrorActionPreference = "Stop"

function Resolve-GodotExe([string]$Requested) {
    if ($Requested) {
        try {
            if (Test-Path $Requested) { return (Resolve-Path $Requested).Path }
        } catch {}
    }
    foreach ($pattern in @(
        "D:\Godot\Godot_v4*_console.exe",
        "D:\Godot\Godot_v4*.exe",
        "D:\Tools\Godot*.exe",
        "D:\Apps\Godot*.exe"
    )) {
        $match = Get-ChildItem -Path $pattern -File -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
        if ($match) { return $match.FullName }
    }
    foreach ($name in @("godot4", "godot")) {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($cmd) { return $cmd.Source }
    }
    throw "Godot executable not found. Pass -GodotExe <path>."
}

function Test-PortFree {
    param([int]$Port)
    $pattern = "[:\.]$Port\s"
    $tcp = netstat -ano -p tcp | Select-String -Pattern $pattern -SimpleMatch:$false
    $udp = netstat -ano -p udp | Select-String -Pattern $pattern -SimpleMatch:$false
    return ($null -eq $tcp -and $null -eq $udp)
}

function Get-FreePort {
    param([int]$StartPort = 45670)
    for ($candidate = $StartPort; $candidate -lt ($StartPort + 100); $candidate++) {
        if (Test-PortFree -Port $candidate) {
            return $candidate
        }
    }
    throw "Failed to find a free local port."
}

function Read-Text([string]$Path) {
    if (-not (Test-Path $Path)) { return "" }
    $text = Get-Content $Path -Raw -ErrorAction SilentlyContinue
    if ($null -eq $text) { return "" }
    return [string]$text
}

function Wait-ForPattern {
    param(
        [string]$Path,
        [string]$Pattern,
        [int]$TimeoutSec = 15
    )
    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    $regex = [regex]::new($Pattern)
    while ((Get-Date) -lt $deadline) {
        $text = Read-Text $Path
        $match = $regex.Match($text)
        if ($match.Success) {
            return $match
        }
        Start-Sleep -Milliseconds 250
    }
    throw "Timed out waiting for pattern '$Pattern' in $Path"
}

function Wait-ForPortBound {
    param(
        [int]$Port,
        [int]$TimeoutSec = 15
    )
    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    while ((Get-Date) -lt $deadline) {
        if (-not (Test-PortFree -Port $Port)) {
            return $true
        }
        Start-Sleep -Milliseconds 250
    }
    throw "Timed out waiting for port $Port to bind"
}

function Assert-Contains {
    param(
        [string]$Path,
        [string]$Pattern,
        [string]$Label
    )
    $text = Read-Text $Path
    if ($text -notmatch $Pattern) {
        throw "$Label missing pattern '$Pattern' in $Path"
    }
}

function Assert-EmptyFile {
    param(
        [string]$Path,
        [string]$Label
    )
    $text = Read-Text $Path
    if (-not [string]::IsNullOrWhiteSpace($text)) {
        throw "$Label expected empty stderr but found:`n$text"
    }
}

function Resolve-ReportFile {
    param(
        [string]$UserPath,
        [string]$FallbackDir,
        [string]$ProjectName
    )
    $leaf = Split-Path $UserPath -Leaf
    $candidates = @(
        (Join-Path $FallbackDir $leaf),
        (Join-Path (Join-Path $env:APPDATA "Godot\app_userdata\$ProjectName\reports") $leaf),
        (Join-Path (Join-Path $env:LOCALAPPDATA "Godot\app_userdata\$ProjectName\reports") $leaf)
    )
    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) {
            return (Resolve-Path $candidate).Path
        }
    }
    throw "Failed to resolve report file for $UserPath"
}

function Invoke-ProofAttempt {
    param(
        [string]$Exe,
        [string]$GodotPath,
        [string]$LogDir,
        [string]$ReportDir,
        [string]$ProjectName,
        [int]$SeedValue,
        [int]$TimeoutSecValue
    )

    $hostOut = Join-Path $LogDir "host.out.log"
    $hostErr = Join-Path $LogDir "host.err.log"
    $clientOut = Join-Path $LogDir "client.out.log"
    $clientErr = Join-Path $LogDir "client.err.log"
    Remove-Item $hostOut, $hostErr, $clientOut, $clientErr -Force -ErrorAction SilentlyContinue
    Get-ChildItem $ReportDir -Filter "run_${SeedValue}_*.txt" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

    $requestedPort = Get-FreePort
    Write-Host "Requested headless proof port: $requestedPort"

    $hostArgs = @(
        "--headless",
        "--path", $GodotPath,
        "--",
        "--mode=host",
        "--port=$requestedPort",
        "--seed=$SeedValue",
        "--auto-ready",
        "--auto-start",
        "--auto-pickup",
        "--auto-role-action",
        "--auto-bomb",
        "--auto-rope"
    )

    $hostProcess = $null
    $clientProcess = $null

    try {
        $hostProcess = Start-Process -FilePath $Exe -WorkingDirectory $GodotPath -ArgumentList $hostArgs -RedirectStandardOutput $hostOut -RedirectStandardError $hostErr -PassThru
        Start-Sleep -Seconds 2
        $chosenPort = $requestedPort
        try {
            $hostMatch = Wait-ForPattern -Path $hostOut -Pattern "HOST_ONLINE .*chosen_port=(\d+)" -TimeoutSec 30
            $chosenPort = [int]$hostMatch.Groups[1].Value
        } catch {
            Wait-ForPortBound -Port $requestedPort -TimeoutSec 60 | Out-Null
        }
        Write-Host "Host chosen port: $chosenPort"

        $clientArgs = @(
            "--headless",
            "--path", $GodotPath,
            "--",
            "--mode=client",
            "--address=127.0.0.1",
            "--port=$chosenPort",
            "--auto-ready",
            "--auto-pickup",
            "--auto-role-action",
            "--auto-bomb",
            "--auto-rope"
        )
        $clientProcess = Start-Process -FilePath $Exe -WorkingDirectory $GodotPath -ArgumentList $clientArgs -RedirectStandardOutput $clientOut -RedirectStandardError $clientErr -PassThru
        Start-Sleep -Seconds 2

        Wait-ForPattern -Path $hostOut -Pattern "START_RUN_REQUEST" -TimeoutSec 25 | Out-Null
        Wait-ForPattern -Path $hostOut -Pattern "GAME_READY" -TimeoutSec 25 | Out-Null
        Wait-ForPattern -Path $clientOut -Pattern "GAME_READY" -TimeoutSec 25 | Out-Null
        Wait-ForPattern -Path $hostOut -Pattern "RUN_VERIFY ok=true checks=\d+ failures=0" -TimeoutSec $TimeoutSecValue | Out-Null
        $hostReportMatch = Wait-ForPattern -Path $hostOut -Pattern "RUN_REPORT_WRITTEN path=(.+) seed=$SeedValue local=(\d+)" -TimeoutSec $TimeoutSecValue
        $clientReportMatch = Wait-ForPattern -Path $clientOut -Pattern "RUN_REPORT_WRITTEN path=(.+) seed=$SeedValue local=(\d+)" -TimeoutSec $TimeoutSecValue

        Assert-Contains -Path $hostOut -Pattern "READY_RPC_ACCEPT" -Label "host output"
        Assert-Contains -Path $hostOut -Pattern "START_RUN_REQUEST" -Label "host output"
        Assert-Contains -Path $hostOut -Pattern "TIMELINE_EVENT .*type=run_started" -Label "host output"
        Assert-Contains -Path $hostOut -Pattern "TIMELINE_EVENT .*type=sabotage_camera_jam" -Label "host output"
        Assert-Contains -Path $hostOut -Pattern "TIMELINE_EVENT .*type=extraction_window_started" -Label "host output"
        Assert-Contains -Path $hostOut -Pattern "TIMELINE_EVENT .*type=bomb_thrown" -Label "host output"
        Assert-Contains -Path $hostOut -Pattern "TIMELINE_EVENT .*type=bomb_exploded" -Label "host output"
        Assert-Contains -Path $hostOut -Pattern "TIMELINE_EVENT .*type=rope_thrown" -Label "host output"
        Assert-Contains -Path $hostOut -Pattern "TIMELINE_EVENT .*type=rope_deployed" -Label "host output"
        Assert-Contains -Path $clientOut -Pattern "GAME_READY" -Label "client output"
        Assert-EmptyFile -Path $hostErr -Label "host"
        Assert-EmptyFile -Path $clientErr -Label "client"

        $hostReportUserPath = $hostReportMatch.Groups[1].Value.Trim()
        $clientReportUserPath = $clientReportMatch.Groups[1].Value.Trim()
        $hostReportFile = Resolve-ReportFile -UserPath $hostReportUserPath -FallbackDir $ReportDir -ProjectName $ProjectName
        $clientReportFile = Resolve-ReportFile -UserPath $clientReportUserPath -FallbackDir $ReportDir -ProjectName $ProjectName

        if (-not (Test-Path $hostReportFile)) {
            throw "Resolved host report file missing: $hostReportFile"
        }
        if (-not (Test-Path $clientReportFile)) {
            throw "Resolved client report file missing: $clientReportFile"
        }

        $diffScript = Join-Path $PSScriptRoot "diff_run_reports.ps1"
        $diffOutput = & $diffScript -HostReport $hostReportFile -ClientReport $clientReportFile
        if ($LASTEXITCODE -ne 0) {
            throw "Report diff failed: $diffOutput"
        }
        if ($diffOutput -notmatch "REPORT_DIFF ok=true mismatches=0") {
            throw "Unexpected report diff output: $diffOutput"
        }

        return @{
            Seed = $SeedValue
            HostOut = $hostOut
            ClientOut = $clientOut
            ReportDir = $ReportDir
            HostReport = $hostReportFile
            ClientReport = $clientReportFile
            DiffOutput = $diffOutput
        }
    } catch {
        $exception = $_
        Write-Host "CATCH IN INVOKE-PROOFATTEMPT: $($exception.ToString())"
        throw $exception
    } finally {
        foreach ($proc in @($clientProcess, $hostProcess)) {
            if ($proc -and -not $proc.HasExited) {
                try { Stop-Process -Id $proc.Id -Force } catch {}
            }
        }
        if ($LastExitCode -ne 0 -or $null -ne $exception) {
             if (Test-Path $hostOut) {
                Write-Host "--- TAIL OF HOST.OUT.LOG ---"
                Get-Content $hostOut -Tail 50 -ErrorAction SilentlyContinue
                Write-Host "----------------------------"
            }
            if (Test-Path $clientOut) {
                Write-Host "--- TAIL OF CLIENT.OUT.LOG ---"
                Get-Content $clientOut -Tail 50 -ErrorAction SilentlyContinue
                Write-Host "----------------------------"
            }
        }
    }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$godotPath = Join-Path $repoRoot "godot"
$userHome = Join-Path $repoRoot ".godot_user"
$reportDir = Join-Path $userHome "reports"
$logDir = Join-Path $repoRoot "tmp_logs\headless_proof"
$projectName = "DeductionDelve"
New-Item -ItemType Directory -Force $userHome | Out-Null
New-Item -ItemType Directory -Force $reportDir | Out-Null
New-Item -ItemType Directory -Force $logDir | Out-Null
$env:GODOT_USER_HOME = $userHome

$exe = Resolve-GodotExe $GodotExe
Write-Host "Using Godot: $exe"
Write-Host "GODOT_USER_HOME: $userHome"

$seedCandidates = @($Seed) | Select-Object -Unique
$proofResult = $null
$attemptFailures = New-Object System.Collections.Generic.List[string]

foreach ($candidateSeed in $seedCandidates) {
    Write-Host "Trying proof seed: $candidateSeed"
    try {
        $proofResult = Invoke-ProofAttempt -Exe $exe -GodotPath $godotPath -LogDir $logDir -ReportDir $reportDir -ProjectName $projectName -SeedValue $candidateSeed -TimeoutSecValue $TimeoutSec
        break
    } catch {
        $attemptFailures.Add("seed=$candidateSeed :: $($_.Exception.Message)")
    }
}

if ($null -eq $proofResult) {
    Write-Host "Final failures: $($attemptFailures -join ' || ')"
    throw ("Headless proof failed for all candidate seeds: {0}" -f ($attemptFailures -join " || "))
}

Write-Host "=== HEADLESS PROOF PASS ==="
Write-Host ("Proof seed: {0}" -f $proofResult.Seed)
Write-Host "RUN_VERIFY ok=true"
Write-Host ("Host report: {0}" -f $proofResult.HostReport)
Write-Host ("Client report: {0}" -f $proofResult.ClientReport)
Write-Host $proofResult.DiffOutput
Write-Host ("Host log: {0}" -f $proofResult.HostOut)
Write-Host ("Client log: {0}" -f $proofResult.ClientOut)
Write-Host ("Report dir: {0}" -f $proofResult.ReportDir)
