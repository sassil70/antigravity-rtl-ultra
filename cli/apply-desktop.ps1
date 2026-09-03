<#
.SYNOPSIS
    Antigravity RTL Ultra — 1-Click Desktop Applier / Restarter
#>

$ErrorActionPreference = "Stop"
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Antigravity RTL Ultra — Activating Desktop App...      " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan

$antigravityDir = "$env:LOCALAPPDATA\Programs\Antigravity"
$resourcesDir = "$antigravityDir\resources"
$asarPath = "$resourcesDir\app.asar"
$patchedPath = "$resourcesDir\app.asar.patched"
$backupPath = "$resourcesDir\app.asar.rtlbak"

if (-not (Test-Path $patchedPath)) {
    Write-Host "Compiling patched bundle first..." -ForegroundColor Yellow
    & "$PSScriptRoot\install.ps1"
}

Write-Host "Closing Antigravity Desktop safely..." -ForegroundColor Cyan
Stop-Process -Name "Antigravity" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

if (-not (Test-Path $backupPath)) {
    Copy-Item $asarPath $backupPath -Force
}

Move-Item $patchedPath $asarPath -Force
Write-Host "RTL Ultra applied to app.asar!" -ForegroundColor Green

Write-Host "Relaunching Antigravity Desktop..." -ForegroundColor Cyan
Start-Process "$antigravityDir\Antigravity.exe"
Write-Host "Done! Antigravity Desktop is now running with RTL Ultra." -ForegroundColor Green
