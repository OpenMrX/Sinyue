#Requires -Version 5.1
<#
.SYNOPSIS
    Shows sccache counters for this project.

.PARAMETER Reset
    Zero the statistics before printing them.

.EXAMPLE
    ./scripts/sccache-stats.ps1
    ./scripts/sccache-stats.ps1 -Reset
#>
[CmdletBinding()]
param(
    [switch]$Reset
)

$ErrorActionPreference = 'Stop'

$sccache = Get-Command sccache -ErrorAction SilentlyContinue
if (-not $sccache) {
    Write-Host "sccache not found on PATH - install it with: winget install --id Mozilla.sccache" -ForegroundColor Yellow
    exit 1
}

if ($Reset) {
    & sccache --zero-stats | Out-Null
}

Write-Host "==> sccache statistics" -ForegroundColor Cyan
& sccache --show-stats
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
