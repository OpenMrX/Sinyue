#Requires -Version 5.1
<#
.SYNOPSIS
    Removes generated build directories.

.PARAMETER Cache
    Also drop .cpmcache (forces a fresh abcmake clone on the next configure).

.EXAMPLE
    ./scripts/clean.ps1
    ./scripts/clean.ps1 -Cache
#>
[CmdletBinding()]
param(
    [switch]$Cache
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot

$targets = @(
    (Join-Path $Root 'build-clang-debug'),
    (Join-Path $Root 'build-clang-release'),
    (Join-Path $Root 'install'),
    (Join-Path $Root 'compile_commands.json')
)
if ($Cache) { $targets += (Join-Path $Root '.cpmcache') }

foreach ($target in $targets) {
    if (Test-Path $target) {
        Remove-Item -Recurse -Force -Confirm:$false $target
        Write-Host "    removed  $target" -ForegroundColor Gray
    }
}

Write-Host "Clean finished." -ForegroundColor Green
