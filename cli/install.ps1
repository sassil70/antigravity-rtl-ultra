<#
.SYNOPSIS
    Antigravity RTL Ultra — Universal Dual-Engine Installer (Windows)
.DESCRIPTION
    Injects clean, dual-pane RTL BiDi engine into:
    1. Antigravity Desktop 2.x (Electron app.asar architecture)
    2. Antigravity IDE / VS Code / Cursor / Windsurf (workbench.desktop.main.css)
#>

[CmdletBinding()]
param (
    [switch]$RestartDesktop
)

$ErrorActionPreference = "Stop"
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Antigravity RTL Ultra — Universal Installer            " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$bundlePath = Join-Path (Split-Path -Parent $scriptDir) "src\styles\bundle.css"

if (-not (Test-Path $bundlePath)) {
    Write-Error "Could not find bundle.css at $bundlePath"
    exit 1
}

$bundleCss = Get-Content $bundlePath -Raw
$localAppData = $env:LOCALAPPDATA

# ─────────────────────────────────────────────────────────────────────────────
# ENGINE 1: Antigravity Desktop 2.x (Electron / app.asar)
# ─────────────────────────────────────────────────────────────────────────────
$antigravityDesktopDir = "$localAppData\Programs\Antigravity"
$desktopAsar = "$antigravityDesktopDir\resources\app.asar"

if (Test-Path $desktopAsar) {
    Write-Host "`n[+] Detected Antigravity Desktop 2.x (Electron Architecture)" -ForegroundColor Yellow
    Write-Host "    Path: $desktopAsar" -ForegroundColor Gray

    $tempExtract = "$env:TEMP\antigravity_rtl_asar_build"
    if (Test-Path $tempExtract) { Remove-Item -Recurse -Force $tempExtract }
    New-Item -ItemType Directory -Path $tempExtract -Force | Out-Null

    Write-Host "  [1/4] Extracting app.asar package..." -ForegroundColor Gray
    npx asar extract $desktopAsar $tempExtract

    $preloadPath = "$tempExtract\dist\preload.js"
    if (Test-Path $preloadPath) {
        Write-Host "  [2/4] Injecting Dual-Pane RTL Engine into preload.js..." -ForegroundColor Gray
        $escapedCss = $bundleCss.Replace('\', '\\').Replace('`', '\`').Replace('$', '\$')
        
        $injection = @"

// [ANTIGRAVITY-RTL-ULTRA-START]
(() => {
    const RTL_STYLE_ID = 'antigravity-rtl-ultra-style';
    const RTL_CSS = `$escapedCss`;
    function injectRTL() {
        try {
            if (!document || !document.documentElement) return;
            if (document.getElementById(RTL_STYLE_ID)) return;
            const style = document.createElement('style');
            style.id = RTL_STYLE_ID;
            style.textContent = RTL_CSS;
            (document.head || document.documentElement).appendChild(style);
        } catch (e) {}
    }
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', injectRTL);
    } else {
        injectRTL();
    }
    setInterval(injectRTL, 1500);
})();
// [ANTIGRAVITY-RTL-ULTRA-END]
"@
        Add-Content -Path $preloadPath -Value $injection
    }

    Write-Host "  [3/4] Repacking app.asar with RTL Ultra..." -ForegroundColor Gray
    $patchedAsar = "$antigravityDesktopDir\resources\app.asar.patched"
    npx asar pack $tempExtract $patchedAsar --unpack "**/node_modules/chrome-devtools-mcp/**"
    Remove-Item -Recurse -Force $tempExtract

    Write-Host "  [4/4] Finalizing installation..." -ForegroundColor Gray
    $backupAsar = "$desktopAsar.rtlbak"

    $isRunning = Get-Process -Name "Antigravity" -ErrorAction SilentlyContinue
    if ($isRunning) {
        Write-Host "  [!] Antigravity Desktop is currently running." -ForegroundColor Yellow
        Write-Host "      Patched bundle is ready at: $patchedAsar" -ForegroundColor Cyan
        if ($RestartDesktop) {
            Write-Host "      Restarting Antigravity Desktop to apply..." -ForegroundColor Cyan
            Stop-Process -Name "Antigravity" -Force
            Start-Sleep -Seconds 2
            if (-not (Test-Path $backupAsar)) { Copy-Item $desktopAsar $backupAsar -Force }
            Move-Item $patchedAsar $desktopAsar -Force
            Start-Process "$antigravityDesktopDir\Antigravity.exe"
            Write-Host "  [✓] Antigravity Desktop restarted with RTL Ultra!" -ForegroundColor Green
        } else {
            Write-Host "      Run: .\cli\apply-desktop.ps1 or re-run with -RestartDesktop to activate." -ForegroundColor Yellow
        }
    } else {
        if (-not (Test-Path $backupAsar)) { Copy-Item $desktopAsar $backupAsar -Force }
        Move-Item $patchedAsar $desktopAsar -Force
        Write-Host "  [✓] Antigravity Desktop patched successfully!" -ForegroundColor Green
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# ENGINE 2: Antigravity IDE / VS Code / Cursor (CSS Workbench)
# ─────────────────────────────────────────────────────────────────────────────
$CSS_MARKER_START = "/* RTL-PATCH-START */"
$CSS_MARKER_END   = "/* RTL-PATCH-END */"

$cssTargets = @(
    "$localAppData\Programs\Antigravity IDE\resources\app\out\vs\workbench\workbench.desktop.main.css",
    "$localAppData\Programs\Cursor\resources\app\out\vs\workbench\workbench.desktop.main.css",
    "$localAppData\Programs\Windsurf\resources\app\out\vs\workbench\workbench.desktop.main.css",
    "$localAppData\Programs\Microsoft VS Code\resources\app\out\vs\workbench\workbench.desktop.main.css"
)

function Update-Checksum($cssPath, $newContent) {
    $appDir = Split-Path (Split-Path (Split-Path (Split-Path $cssPath)))
    $productJsonPath = Join-Path $appDir "product.json"
    if (Test-Path $productJsonPath) {
        try {
            $json = Get-Content $productJsonPath -Raw | ConvertFrom-Json
            if ($json.checksums -and $json.checksums.'vs/workbench/workbench.desktop.main.css') {
                $sha256 = [System.Security.Cryptography.SHA256]::Create()
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($newContent)
                $hash = [Convert]::ToBase64String($sha256.ComputeHash($bytes)).Replace("=", "")
                $json.checksums.'vs/workbench/workbench.desktop.main.css' = $hash
                $json | ConvertTo-Json -Depth 10 | Set-Content $productJsonPath -Encoding utf8
                Write-Host "  [+] product.json checksum updated." -ForegroundColor Gray
            }
        } catch {}
    }
}

foreach ($target in $cssTargets) {
    if (Test-Path $target) {
        Write-Host "`n[+] Detected IDE Installation: $target" -ForegroundColor Yellow
        $backup = "$target.rtlbak"
        if (-not (Test-Path $backup)) { Copy-Item $target $backup -Force }

        $content = Get-Content $target -Raw
        if ($content.Contains($CSS_MARKER_START) -and $content.Contains($CSS_MARKER_END)) {
            $startIdx = $content.IndexOf($CSS_MARKER_START)
            $endIdx = $content.IndexOf($CSS_MARKER_END) + $CSS_MARKER_END.Length
            $content = $content.Substring(0, $startIdx) + $content.Substring($endIdx)
        }

        $newContent = $content + "`n`n" + $bundleCss
        [System.IO.File]::WriteAllText($target, $newContent, [System.Text.Encoding]::UTF8)
        Update-Checksum $target $newContent
        Write-Host "  [✓] Applied successfully to workbench CSS!" -ForegroundColor Green
    }
}

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host " Universal Installation Finished!                         " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
