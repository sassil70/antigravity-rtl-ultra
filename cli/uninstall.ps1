<#
.SYNOPSIS
    Antigravity RTL Ultra -- 1-Click Rollback Script for Windows
.DESCRIPTION
    Safely reverts Antigravity IDE, Cursor, and VS Code forks to their factory original state.
    Restores from backup (.rtlbak) or surgically strips RTL patch tags and recalculates product.json checksums.
#>

[CmdletBinding()]
param (
    [switch]$KeepBackup
)

$ErrorActionPreference = "Stop"
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Antigravity RTL Ultra -- Safe Rollback / Uninstaller   " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

$CSS_MARKER_START = "/* RTL-PATCH-START */"
$CSS_MARKER_END   = "/* RTL-PATCH-END */"

$localAppData = $env:LOCALAPPDATA
$candidates = @(
    "$localAppData\Programs\Antigravity IDE\resources\app\out\vs\workbench\workbench.desktop.main.css",
    "$localAppData\Programs\Antigravity\resources\app\out\vs\workbench\workbench.desktop.main.css",
    "$localAppData\Programs\Cursor\resources\app\out\vs\workbench\workbench.desktop.main.css",
    "$localAppData\Programs\Windsurf\resources\app\out\vs\workbench\workbench.desktop.main.css",
    "$localAppData\Programs\Qoder\resources\app\out\vs\workbench\workbench.desktop.main.css",
    "$localAppData\Programs\Microsoft VS Code\resources\app\out\vs\workbench\workbench.desktop.main.css"
)

function Update-Checksum {
    param (
        [string]$cssPath,
        [string]$newContent
    )
    $appDir = Split-Path (Split-Path (Split-Path (Split-Path $cssPath)))
    $productJsonPath = Join-Path $appDir "product.json"
    if (Test-Path $productJsonPath) {
        try {
            $rawJson = [System.IO.File]::ReadAllText($productJsonPath, [System.Text.Encoding]::UTF8)
            $json = ConvertFrom-Json $rawJson
            if ($null -ne $json.checksums) {
                $sha256 = [System.Security.Cryptography.SHA256]::Create()
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($newContent)
                $hash = [Convert]::ToBase64String($sha256.ComputeHash($bytes)).Replace("=", "")
                if ($json.checksums.PSObject.Properties["vs/workbench/workbench.desktop.main.css"]) {
                    $json.checksums."vs/workbench/workbench.desktop.main.css" = $hash
                    $updatedJson = $json | ConvertTo-Json -Depth 10
                    [System.IO.File]::WriteAllText($productJsonPath, $updatedJson, [System.Text.Encoding]::UTF8)
                    Write-Host "  [+] product.json checksum updated successfully." -ForegroundColor Gray
                }
            }
        } catch {
            Write-Warning "Failed to update checksum in product.json: $_"
        }
    }
}

$foundAny = $false

foreach ($target in $candidates) {
    $backup = "$target.rtlbak"
    if (Test-Path $backup) {
        $foundAny = $true
        Write-Host "`nTarget: $target" -ForegroundColor Yellow
        $restoredContent = [System.IO.File]::ReadAllText($backup, [System.Text.Encoding]::UTF8)
        [System.IO.File]::WriteAllText($target, $restoredContent, [System.Text.Encoding]::UTF8)
        if (-not $KeepBackup) {
            Remove-Item $backup -Force
            Write-Host "  [OK] Restored original from backup and cleaned up .rtlbak" -ForegroundColor Green
        } else {
            Write-Host "  [OK] Restored original from backup (backup preserved)." -ForegroundColor Green
        }
        Update-Checksum -cssPath $target -newContent $restoredContent
    } elseif (Test-Path $target) {
        # Fallback: Surgically strip patch if backup was missing
        $content = [System.IO.File]::ReadAllText($target, [System.Text.Encoding]::UTF8)
        if ($content.Contains($CSS_MARKER_START) -and $content.Contains($CSS_MARKER_END)) {
            $foundAny = $true
            Write-Host "`nTarget: $target" -ForegroundColor Yellow
            $startIdx = $content.IndexOf($CSS_MARKER_START)
            $endIdx = $content.IndexOf($CSS_MARKER_END) + $CSS_MARKER_END.Length
            $cleanContent = ($content.Substring(0, $startIdx) + $content.Substring($endIdx)).TrimEnd()
            [System.IO.File]::WriteAllText($target, $cleanContent, [System.Text.Encoding]::UTF8)
            Write-Host "  [OK] Surgically stripped RTL patch from workbench CSS." -ForegroundColor Green
            Update-Checksum -cssPath $target -newContent $cleanContent
        }
    }
}

if (-not $foundAny) {
    Write-Host "`nNo patched IDE files or backups found." -ForegroundColor Yellow
} else {
    Write-Host "`n==========================================================" -ForegroundColor Green
    Write-Host " Rollback Complete! Please restart your IDE.             " -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green
}

