#Requires -Version 5.1
<#
.SYNOPSIS
    Configures and builds one of the Clang presets.

.PARAMETER Config
    debug | release  (maps to the clang-debug / clang-release presets).

.PARAMETER Reconfigure
    Force a configure step even when the build directory already exists.

.PARAMETER Run
    Execute the freshly built binary afterwards.

.PARAMETER Target
    Optional Ninja target (default: everything).

.EXAMPLE
    ./scripts/build.ps1
    ./scripts/build.ps1 -Config release -Run
    ./scripts/build.ps1 -Reconfigure -Target Core
#>
[CmdletBinding()]
param(
    [ValidateSet('debug', 'release')]
    [string]$Config = 'debug',
    [switch]$Reconfigure,
    [switch]$Run,
    [string]$Target = ''
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$Preset = "clang-$Config"
$BuildDir = Join-Path $Root "build-$Preset"

Push-Location $Root
try {
    $needsConfigure = $Reconfigure -or -not (Test-Path (Join-Path $BuildDir 'CMakeCache.txt'))

    if ($needsConfigure) {
        Write-Host "==> configure ($Preset)" -ForegroundColor Cyan
        & cmake --preset $Preset
        if ($LASTEXITCODE -ne 0) { throw "configure failed" }
    }
    else {
        Write-Host "==> configure skipped (build-$Preset exists)" -ForegroundColor DarkGray
    }

    Write-Host "==> build ($Preset)" -ForegroundColor Cyan
    $buildArgs = @('--build', '--preset', $Preset)
    if ($Target) { $buildArgs += @('--target', $Target) }

    & cmake @buildArgs
    if ($LASTEXITCODE -ne 0) { throw "build failed" }

    $exe = Join-Path $BuildDir 'Sinyue.exe'
    Write-Host "==> binary: $exe" -ForegroundColor Green

    if ($Run) {
        if (-not (Test-Path $exe)) { throw "binary not found: $exe" }
        Write-Host "==> run" -ForegroundColor Cyan
        & $exe
    }
}
finally {
    Pop-Location
}
