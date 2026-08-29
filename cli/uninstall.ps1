<#
.SYNOPSIS
    Antigravity RTL Ultra — 1-Click Rollback Script for Windows
#>

[CmdletBinding()]
param ()

$ErrorActionPreference = "Stop"
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Antigravity RTL Ultra — Rollback / Uninstaller         " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

$localAppData = $env:LOCALAPPDATA
$candidates = @(
    "$localAppData\Programs\Antigravity IDE\resources\app\out\vs\workbench\workbench.desktop.main.css",
    "$localAppData\Programs\Antigravity\resources\app\out\vs\workbench\workbench.desktop.main.css",
    "$localAppData\Programs\Cursor\resources\app\out\vs\workbench\workbench.desktop.main.css",
    "$localAppData\Programs\Windsurf\resources\app\out\vs\workbench\workbench.desktop.main.css",
    "$localAppData\Programs\Microsoft VS Code\resources\app\out\vs\workbench\workbench.desktop.main.css"
)

foreach ($target in $candidates) {
    $backup = "$target.rtlbak"
    if (Test-Path $backup) {
        Copy-Item $backup $target -Force
        Remove-Item $backup -Force
        Write-Host "Restored original file from backup: $target" -ForegroundColor Green
    }
}

Write-Host "Rollback completed. Please restart your IDE." -ForegroundColor Green
