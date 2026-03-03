#!/usr/bin/env pwsh

# DeductionDelve - Two-Instance Local Test Runner
# This script starts both host and client instances for manual GUI testing

$ErrorActionPreference = 'Stop'

# Set Godot executable path
$godotExe = "D:\Godot\Godot_v4.6.1-stable_win64.exe"

# Check for Godot executable
if (-not (Test-Path $godotExe)) {
    Write-Host "ERROR: Godot executable not found at: $godotExe" -ForegroundColor Red
    exit 1
}

# Setup paths
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$godotPath = Join-Path $repoRoot "godot"
$logDir = Join-Path $repoRoot "tmp_logs"

# Create log directory
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

$hostLog = Join-Path $logDir "host.log"
$clientLog = Join-Path $logDir "client.log"

# Clear existing logs
if (Test-Path $hostLog) { Remove-Item $hostLog }
if (Test-Path $clientLog) { Remove-Item $clientLog }

Write-Host "Starting DeductionDelve two-instance test..." -ForegroundColor Green
Write-Host "Host log: $hostLog" -ForegroundColor Cyan
Write-Host "Client log: $clientLog" -ForegroundColor Cyan
Write-Host ""

# Start Host Instance
Write-Host "Starting Host instance..." -ForegroundColor Yellow
$hostArgs = @(
    "--path", $godotPath,
    "--port=2456",
    "--seed=1337"
)

$hostProcess = Start-Process -FilePath $godotExe -ArgumentList $hostArgs -RedirectStandardOutput $hostLog -PassThru -NoNewWindow

Start-Sleep -Seconds 3

# Start Client Instance
Write-Host "Starting Client instance..." -ForegroundColor Yellow
$clientArgs = @(
    "--path", $godotPath,
    "--address=127.0.0.1",
    "--port=2456"
)

$clientProcess = Start-Process -FilePath $godotExe -ArgumentList $clientArgs -RedirectStandardOutput $clientLog -PassThru -NoNewWindow

Write-Host ""
Write-Host "Manual Test Instructions:" -ForegroundColor Magenta
Write-Host "1. In Host window: Click 'Host Local' -> Wait for 'Host online' -> Click 'Ready'" -ForegroundColor White
Write-Host "2. In Client window: Click 'Join Local' -> Wait for 'Connected' -> Click 'Ready'" -ForegroundColor White
Write-Host "3. In Host window: Click 'Start Run'" -ForegroundColor White
Write-Host ""
Write-Host "Watch the log files for the following sequence:" -ForegroundColor Magenta
Write-Host "- action=start_gate ... allowed=true" -ForegroundColor Cyan
Write-Host "- START_RUN_REQUEST ..." -ForegroundColor Cyan
Write-Host "- action=run_started_transition (host and client)" -ForegroundColor Cyan
Write-Host "- GAME_READY ... (host and client)" -ForegroundColor Cyan
Write-Host ""
Write-Host "After the test, check the logs and report any errors." -ForegroundColor Yellow
Write-Host "To stop: Close both Godot windows manually." -ForegroundColor Yellow

# Wait a bit to ensure processes are running
Start-Sleep -Seconds 2