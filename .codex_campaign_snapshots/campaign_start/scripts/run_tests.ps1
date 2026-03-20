param(
    [string]$GodotExe = ""
)

$ErrorActionPreference = "Stop"

function Read-Text([string]$Path) {
    if (-not (Test-Path $Path)) { return "" }
    $text = Get-Content $Path -Raw -ErrorAction SilentlyContinue
    if ($null -eq $text) { return "" }
    return [string]$text
}

function Assert-FileExists([string]$Path, [string]$Label) {
    if (-not (Test-Path $Path)) {
        throw "$Label missing: $Path"
    }
}

function Assert-Contains([string]$Path, [string]$Pattern, [string]$Label) {
    $text = Read-Text $Path
    if ($text -notmatch $Pattern) {
        throw "$Label missing pattern '$Pattern' in $Path"
    }
}

function Assert-NoCrashSignature([string[]]$Paths) {
    $crashPattern = "(CrashHandlerException|Program crashed with signal|ERROR:\s+Failed to open 'user://logs/)"
    foreach ($path in $Paths) {
        if (-not (Test-Path $path)) {
            continue
        }
        $text = Read-Text $path
        if ($text -match $crashPattern) {
            throw "Crash signature detected in $path"
        }
    }
}

function Show-Tail([string]$Path, [int]$LineCount = 60) {
    if (-not (Test-Path $Path)) {
        return
    }
    Write-Host ("--- TAIL {0} ---" -f $Path)
    Get-Content $Path -Tail $LineCount -ErrorAction SilentlyContinue
    Write-Host "-----------------"
}

function Resolve-GodotExe([string]$Requested) {
    if ($Requested) {
        try {
            if (Test-Path $Requested) { return (Resolve-Path $Requested).Path }
        } catch {}
    }
    foreach ($pattern in @(
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

$repoRoot = Split-Path -Parent $PSScriptRoot
$godotPath = Join-Path $repoRoot "godot"
$userHome = Join-Path $repoRoot ".godot_user"
$logDir = Join-Path $userHome "logs"
$reportDir = Join-Path $userHome "reports"
$runnerLogDir = Join-Path $repoRoot "tmp_logs"
[System.IO.Directory]::CreateDirectory($userHome) | Out-Null
[System.IO.Directory]::CreateDirectory($logDir) | Out-Null
[System.IO.Directory]::CreateDirectory($reportDir) | Out-Null
$env:GODOT_USER_HOME = $userHome
$stdoutLog = Join-Path $runnerLogDir "deterministic_runner.out.log"
$stderrLog = Join-Path $runnerLogDir "deterministic_runner.err.log"
Remove-Item $stdoutLog, $stderrLog -Force -ErrorAction SilentlyContinue

$exe = Resolve-GodotExe $GodotExe
Write-Host "Using Godot: $exe"
Write-Host "GODOT_USER_HOME: $userHome"
Write-Host "Running headless test runner..."
$previousLocation = Get-Location
Set-Location $godotPath
& $exe --headless --path $godotPath --script res://src/tests/test_runner.gd 1> $stdoutLog 2> $stderrLog
$processExitCode = $LASTEXITCODE
Set-Location $previousLocation

try {
    Assert-FileExists -Path $stdoutLog -Label "deterministic stdout log"
    Assert-FileExists -Path $stderrLog -Label "deterministic stderr log"
    Assert-Contains -Path $stdoutLog -Pattern "\[PASS\] Milestone tests passed\." -Label "deterministic stdout log"
    Assert-NoCrashSignature -Paths @($stdoutLog, $stderrLog)
    if ($processExitCode -ne 0) {
        throw "Godot test runner exited with code $processExitCode"
    }
} catch {
    Show-Tail -Path $stdoutLog
    Show-Tail -Path $stderrLog
    throw
}
