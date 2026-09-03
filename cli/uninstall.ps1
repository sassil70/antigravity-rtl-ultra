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

# 1. Restore Antigravity Desktop app.asar
$desktopAsar = "$localAppData\Programs\Antigravity\resources\app.asar"
$desktopBak = "$desktopAsar.rtlbak"
if (Test-Path $desktopBak) {
    Stop-Process -Name "Antigravity" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Copy-Item $desktopBak $desktopAsar -Force
    Remove-Item $desktopBak -Force
    Write-Host "Restored original app.asar for Antigravity Desktop." -ForegroundColor Green
    Start-Process "$localAppData\Programs\Antigravity\Antigravity.exe"
}

# 2. Restore IDE CSS files
$candidates = @(
    "$localAppData\Programs\Antigravity IDE\resources\app\out\vs\workbench\workbench.desktop.main.css",
    "$localAppData\Programs\Cursor\resources\app\out\vs\workbench\workbench.desktop.main.css",
    "$localAppData\Programs\Windsurf\resources\app\out\vs\workbench\workbench.desktop.main.css",
    "$localAppData\Programs\Microsoft VS Code\resources\app\out\vs\workbench\workbench.desktop.main.css"
)

foreach ($target in $candidates) {
    $backup = "$target.rtlbak"
    if (Test-Path $backup) {
        Copy-Item $backup $target -Force
        Remove-Item $backup -Force
        Write-Host "Restored original file: $target" -ForegroundColor Green
    }
}

Write-Host "Rollback completed." -ForegroundColor Green
