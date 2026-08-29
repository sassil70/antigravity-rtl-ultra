<#
.SYNOPSIS
    Antigravity RTL Ultra -- 1-Click Universal Installer for Windows
.DESCRIPTION
    Injects clean, dual-pane RTL BiDi engine into Antigravity IDE and VS Code forks.
#>

[CmdletBinding()]
param (
    [switch]$Force
)

$ErrorActionPreference = "Stop"
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Antigravity RTL Ultra -- 1-Click Installer (Windows)   " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan

$CSS_MARKER_START = "/* RTL-PATCH-START */"
$CSS_MARKER_END   = "/* RTL-PATCH-END */"

# 1. Read the compiled bundle CSS
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$bundlePath = Join-Path (Split-Path -Parent $scriptDir) "src\styles\bundle.css"

if (-not (Test-Path $bundlePath)) {
    Write-Error "Could not find bundle.css at $bundlePath"
    exit 1
}

$patchCss = [System.IO.File]::ReadAllText($bundlePath, [System.Text.Encoding]::UTF8)

# 2. Find target IDE CSS files
$localAppData = $env:LOCALAPPDATA
$candidates = @(
    "$localAppData\Programs\Antigravity IDE\resources\app\out\vs\workbench\workbench.desktop.main.css",
    "$localAppData\Programs\Antigravity\resources\app\out\vs\workbench\workbench.desktop.main.css",
    "$localAppData\Programs\Cursor\resources\app\out\vs\workbench\workbench.desktop.main.css",
    "$localAppData\Programs\Windsurf\resources\app\out\vs\workbench\workbench.desktop.main.css",
    "$localAppData\Programs\Qoder\resources\app\out\vs\workbench\workbench.desktop.main.css",
    "$localAppData\Programs\Microsoft VS Code\resources\app\out\vs\workbench\workbench.desktop.main.css"
)

$foundTargets = @()
foreach ($path in $candidates) {
    if (Test-Path $path) {
        $foundTargets += $path
    }
}

if ($foundTargets.Count -eq 0) {
    Write-Warning "No supported IDE installations found in default locations."
    exit 0
}

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

foreach ($target in $foundTargets) {
    Write-Host "`nTarget: $target" -ForegroundColor Yellow
    
    # Create backup if not exists
    $backup = "$target.rtlbak"
    if (-not (Test-Path $backup)) {
        Copy-Item $target $backup -Force
        Write-Host "  [+] Created backup at: $backup" -ForegroundColor Gray
    }

    $content = [System.IO.File]::ReadAllText($target, [System.Text.Encoding]::UTF8)

    # Strip existing patch if present
    if ($content.Contains($CSS_MARKER_START) -and $content.Contains($CSS_MARKER_END)) {
        $startIdx = $content.IndexOf($CSS_MARKER_START)
        $endIdx = $content.IndexOf($CSS_MARKER_END) + $CSS_MARKER_END.Length
        $content = $content.Substring(0, $startIdx) + $content.Substring($endIdx)
        Write-Host "  [-] Removed legacy patch." -ForegroundColor Gray
    }

    # Inject new patch
    $newContent = $content.TrimEnd() + "`r`n`r`n" + $patchCss + "`r`n"
    [System.IO.File]::WriteAllText($target, $newContent, [System.Text.Encoding]::UTF8)
    Write-Host "  [OK] Antigravity RTL Ultra applied successfully!" -ForegroundColor Green

    Update-Checksum -cssPath $target -newContent $newContent
}

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host " Installation Complete! Please restart Antigravity IDE. " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green


