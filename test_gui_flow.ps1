#!/usr/bin/env pwsh
# Test script to validate manual GUI multiplayer flow
# This script launches two Godot instances and performs manual testing steps

$ErrorActionPreference = 'Stop'

# Configuration
$GodotExe = "C:\Path\To\Godot_v4.6.1-stable_win64_console.exe"
$Port = 2456
$Seed = 1337

Write-Host "=== DeductionDelve GUI Multiplayer Flow Test ===" -ForegroundColor Green
Write-Host "This script will launch two Godot instances for manual testing." -ForegroundColor Yellow
Write-Host "You will need to perform the following steps manually:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Window A (Host): Click 'Host Local'" -ForegroundColor Cyan
Write-Host "2. Window B (Client): Click 'Join Local'" -ForegroundColor Cyan
Write-Host "3. Both windows: Click 'Ready'" -ForegroundColor Cyan
Write-Host "4. Host window: Click 'Start Run'" -ForegroundColor Cyan
Write-Host "5. Verify both windows transition to Game.tscn" -ForegroundColor Cyan
Write-Host ""
Write-Host "Expected logs to look for:" -ForegroundColor Yellow
Write-Host "- UI ... action=start_gate gate=... allowed=true" -ForegroundColor Cyan
Write-Host "- NM_LOG ... START_RUN_REQUEST ..." -ForegroundColor Cyan
Write-Host "- UI ... action=run_started_transition" -ForegroundColor Cyan
Write-Host ""

# Check if Godot executable exists
if (-not (Test-Path $GodotExe)) {
    Write-Host "ERROR: Godot executable not found at $GodotExe" -ForegroundColor Red
    Write-Host "Please update the \$GodotExe variable in this script." -ForegroundColor Red
    exit 1
}

# Launch Host instance
Write-Host "Launching Host instance..." -ForegroundColor Green
$hostArgs = "--headless --path d:\DeductionDelve\godot -- --mode=host --port=$Port --seed=$Seed"
$hostProcess = Start-Process -FilePath $GodotExe -ArgumentList $hostArgs -PassThru -WindowStyle Hidden
Write-Host "Host launched with PID: $($hostProcess.Id)" -ForegroundColor Green

# Launch Client instance
Write-Host "Launching Client instance..." -ForegroundColor Green
$clientArgs = "--headless --path d:\DeductionDelve\godot -- --mode=client --address=127.0.0.1 --port=$Port"
$clientProcess = Start-Process -FilePath $GodotExe -ArgumentList $clientArgs -PassThru -WindowStyle Hidden
Write-Host "Client launched with PID: $($clientProcess.Id)" -ForegroundColor Green

Write-Host ""
Write-Host "Both instances are now running." -ForegroundColor Green
Write-Host "Please perform the manual steps listed above." -ForegroundColor Yellow
Write-Host "Check the console output for the expected log messages." -ForegroundColor Yellow
Write-Host ""
Write-Host "Press any key to terminate both instances when testing is complete..." -ForegroundColor Yellow

# Wait for user input to clean up
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

# Clean up processes
Write-Host "Terminating test instances..." -ForegroundColor Green
try {
    Stop-Process -Id $hostProcess.Id -Force -ErrorAction SilentlyContinue
    Stop-Process -Id $clientProcess.Id -Force -ErrorAction SilentlyContinue
    Write-Host "Test instances terminated." -ForegroundColor Green
} catch {
    Write-Host "Error terminating processes: $_" -ForegroundColor Red
}

Write-Host "GUI flow test completed." -ForegroundColor Green