param(
    [string]$GodotExe = "",
    [int]$Port = 2456,
    [int]$Seed = 1337
)

$ErrorActionPreference = "Stop"

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
New-Item -ItemType Directory -Force $userHome | Out-Null
$env:GODOT_USER_HOME = $userHome

$exe = Resolve-GodotExe $GodotExe
Write-Host "Using Godot: $exe"
Write-Host "GODOT_USER_HOME: $userHome"
& $exe --path $godotPath -- --mode=host --port=$Port --seed=$Seed
