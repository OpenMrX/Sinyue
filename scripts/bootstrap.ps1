#Requires -Version 5.1
<#
.SYNOPSIS
    Verifies the local toolchain and prepares the CPM cache.

.DESCRIPTION
    1. checks cmake / ninja / sccache / clang++
    2. restores cmake/CPM.cmake when the vendored copy is missing
    3. inspects .cpmcache and only downloads abcmake when it is absent

.PARAMETER Config
    Preset used for the cache warm-up configure step: debug | release.

.PARAMETER SkipWarmup
    Report only - never run a configure step.

.EXAMPLE
    ./scripts/bootstrap.ps1
    ./scripts/bootstrap.ps1 -Config release -SkipWarmup
#>
[CmdletBinding()]
param(
    [ValidateSet('debug', 'release')]
    [string]$Config = 'debug',
    [switch]$SkipWarmup
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$Preset = "clang-$Config"

function Write-Step { param($Text) Write-Host "==> $Text" -ForegroundColor Cyan }
function Write-Ok   { param($Text) Write-Host "    [ok]   $Text" -ForegroundColor Green }
function Write-Note { param($Text) Write-Host "    [note] $Text" -ForegroundColor Gray }
function Write-Bad  { param($Text) Write-Host "    [fail] $Text" -ForegroundColor Red }

Write-Step "Toolchain"

$missing = @()
$tools = @(
    @{ Name = 'cmake';   Hint = 'winget install --id Kitware.CMake' },
    @{ Name = 'ninja';   Hint = 'winget install --id Ninja-build.Ninja' },
    @{ Name = 'sccache'; Hint = 'winget install --id Mozilla.sccache' }
)

foreach ($tool in $tools) {
    $cmd = Get-Command $tool.Name -ErrorAction SilentlyContinue
    if ($cmd) {
        Write-Ok ("{0,-9} {1}" -f $tool.Name, $cmd.Source)
    }
    else {
        Write-Bad ("{0,-9} not found - {1}" -f $tool.Name, $tool.Hint)
        $missing += $tool.Name
    }
}

$llvmBin = Join-Path $env:ProgramFiles 'LLVM\bin'
$clangxx = Join-Path $llvmBin 'clang++.exe'
if (Test-Path $clangxx) {
    Write-Ok ("{0,-9} {1}" -f 'clang++', $clangxx)
}
else {
    Write-Bad ("{0,-9} not found - install LLVM: winget install --id LLVM.LLVM" -f 'clang++')
    $missing += 'clang++'
}

Write-Step "CPM bootstrap file"

$cpmFile = Join-Path $Root 'cmake\CPM.cmake'
if (Test-Path $cpmFile) {
    Write-Ok "cmake/CPM.cmake present"
}
else {
    $url = 'https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.43.2/CPM.cmake'
    Write-Note "cmake/CPM.cmake missing - downloading $url"
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $cpmFile) | Out-Null
    Invoke-WebRequest -Uri $url -OutFile $cpmFile -UseBasicParsing
    Write-Ok "cmake/CPM.cmake restored"
}

Write-Step "CPM source cache"

$cacheRoot = Join-Path $Root '.cpmcache'
$abcmakeCache = Join-Path $cacheRoot 'abcmake'

if (-not (Test-Path $cacheRoot)) {
    New-Item -ItemType Directory -Force -Path $cacheRoot | Out-Null
    Write-Note "created $cacheRoot"
}

if (Test-Path $abcmakeCache) {
    Write-Ok "cache hit  - abcmake reused from $abcmakeCache"
    $cacheHit = $true
}
else {
    Write-Note "cache miss - abcmake will be cloned into $abcmakeCache"
    $cacheHit = $false
}

if (-not $cacheHit -and -not $SkipWarmup) {
    if ($missing.Count -gt 0) {
        throw "Missing tools ($($missing -join ', ')); cannot warm up the cache."
    }
    Write-Step "Warming up the cache with preset '$Preset'"
    & cmake --preset $Preset
    if ($LASTEXITCODE -ne 0) {
        throw "cmake --preset $Preset failed"
    }
    Write-Ok "cache populated"
}

Write-Step "Summary"
if ($missing.Count -eq 0) {
    Write-Host "    Toolchain ready. Next: ./scripts/build.ps1 -Config $Config -Run" -ForegroundColor Green
}
else {
    Write-Host "    Missing: $($missing -join ', ')" -ForegroundColor Yellow
    exit 1
}
