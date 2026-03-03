#!/usr/bin/env pwsh
# DeductionDelve Godot 4.6.1 — One-command smoke test
# Usage: ./scripts/smoke.ps1
# Exits 0 on PASS, non-zero on FAIL

$ErrorActionPreference = 'Stop'

$godot_exe = 'D:\Godot\Godot_v4.6.1-stable_win64_console.exe'
$project_path = 'd:\DeductionDelve\godot'
$load_check_script = 'res://src/tests/load_check.gd'
$host_log = Join-Path $env:TEMP 'deductiondelve_host.log'
$client_log = Join-Path $env:TEMP 'deductiondelve_client.log'
$host_pid_file = Join-Path $env:TEMP 'deductiondelve_host.pid'

function Log-Info { param($msg); Write-Host "[INFO] $msg" }
function Log-Error { param($msg); Write-Host "[ERROR] $msg" -ForegroundColor Red }

function Fail-Test { param($msg); Log-Error $msg; exit 1 }

function Check-ExitCode {
    param(
        [Parameter(Mandatory=$true)]$Result,
        [Parameter(Mandatory=$true)]$Description
    )
    if ($Result.ExitCode -ne 0) {
        Log-Error "$Description failed with exit code $($Result.ExitCode)"
        if ($Result.StandardError) { Write-Host $Result.StandardError }
        Fail-Test "Smoke test failed"
    }
}

function Run-LoadCheck {
    Log-Info "Running headless load check..."
    $cmd = "& '$godot_exe' --headless --path '$project_path' --script '$load_check_script'"
    $res = Invoke-Expression $cmd
    if ($LASTEXITCODE -ne 0) {
        Log-Error "Load check failed"
        if ($res) { Write-Host $res }
        Fail-Test "Load check failed"
    }
    Log-Info "Load check passed"
}

function Start-Host {
    Log-Info "Starting host in background..."
    # Ensure previous host is stopped
    Stop-Host
    # Start host with logging
    $cmd = "& '$godot_exe' --headless --path '$project_path' --script 'res://src/tests/smoke_test.gd' --address=127.0.0.1 --port=2456"
    $job = Start-Job -ScriptBlock { Invoke-Expression $using:cmd } -Name 'DeductionDelveHost'
    # Write PID file for cleanup
    $job.Id | Out-File -FilePath $host_pid_file -Encoding utf8
    Start-Sleep -Seconds 2
    # Check if job is still running
    if (-not (Get-Job -Id $job.Id -ErrorAction SilentlyContinue).State -eq 'Running') {
        Log-Error "Host failed to start"
        $err = Receive-Job -Job $job -ErrorAction SilentlyContinue
        if ($err) { Write-Host $err }
        Stop-Host
        Fail-Test "Host failed to start"
    }
    Log-Info "Host started"
}

function Stop-Host {
    if (Test-Path $host_pid_file) {
        $host_pid = Get-Content $host_pid_file -ErrorAction SilentlyContinue
        if ($host_pid) {
            try { Stop-Job -Id $host_pid -ErrorAction SilentlyContinue } catch {}
            try { Remove-Job -Id $host_pid -ErrorAction SilentlyContinue } catch {}
        }
        Remove-Item $host_pid_file -Force -ErrorAction SilentlyContinue
    }
    # Fallback kill by name
    Get-Job -Name 'DeductionDelveHost' -ErrorAction SilentlyContinue | ForEach-Object { try { Stop-Job $_; Remove-Job $_ } catch {} }
}

function Run-ClientOnce {
    Log-Info "Running client once..."
    $cmd = "& '$godot_exe' --headless --path '$project_path' --script 'res://src/tests/smoke_client.gd' --address=127.0.0.1 --port=2456 --client"
    $res = Invoke-Expression $cmd
    if ($LASTEXITCODE -ne 0) {
        Log-Error "Client failed"
        if ($res) { Write-Host $res }
        Fail-Test "Client failed"
    }
    Log-Info "Client completed"
}

function Tail-HostLog {
    if (-not (Test-Path $host_log)) { return "" }
    Get-Content $host_log -Tail 200 -ErrorAction SilentlyContinue
}

function Check-HostLogForErrors {
    param(
        [Parameter(Mandatory=$true)]$LogContent
    )
    $errors = @(
        'Parse Error',
        'SCRIPT ERROR',
        'Invalid assignment',
        'Trying to call an RPC via a multiplayer peer which is not connected',
        'Failed to load script'
    )
    foreach ($err in $errors) {
        if ($LogContent -match $err) {
            Log-Error "Found error in host log: $err"
            Fail-Test "Host log contains errors"
        }
    }
}

function Check-HostLogForSuccess {
    param(
        [Parameter(Mandatory=$true)]$LogContent
    )
    if ($LogContent -notmatch 'GAME_READY') {
        Log-Error "Host log missing 'GAME_READY'"
        Fail-Test "Host log missing GAME_READY"
    }
    if ($LogContent -notmatch 'run_started_transition') {
        Log-Error "Host log missing 'run_started_transition'"
        Fail-Test "Host log missing run_started_transition"
    }
    Log-Info "Host log contains expected success markers"
}

function Run-SmokeTest {
    try {
        Run-LoadCheck
        Start-Host
        # Wait for host to be ready
        Start-Sleep -Seconds 3
        Run-ClientOnce
        # Wait for logs to flush
        Start-Sleep -Seconds 2
        $log = Tail-HostLog
        Check-HostLogForErrors -LogContent $log
        Check-HostLogForSuccess -LogContent $log
        Log-Info "=== SMOKE TEST PASS ==="
        exit 0
    } finally {
        Stop-Host
    }
}

Run-SmokeTest