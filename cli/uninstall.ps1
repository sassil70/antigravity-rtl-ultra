<#
.SYNOPSIS
    Antigravity RTL Ultra v2.1 -- 1-Click Safe Rollback / Uninstaller (Windows)
.DESCRIPTION
    Restores original unpatched app.asar (from app.asar.rtlbak) in-place with zero downtime,
    removes the live RTL engine from open windows via CDP, and restores classic IDE CSS backups.
#>

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Antigravity RTL Ultra v2.1 -- Safe 1-Click Rollback    " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

$localAppData = $env:LOCALAPPDATA
$anyRestored = $false

function Read-AllBytesShared([string]$path) {
    $fs = [System.IO.File]::Open($path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
    try {
        $bytes = New-Object byte[] $fs.Length
        $read = 0
        while ($read -lt $bytes.Length) {
            $n = $fs.Read($bytes, $read, $bytes.Length - $read)
            if ($n -le 0) { break }
            $read += $n
        }
        return $bytes
    } finally {
        $fs.Close()
    }
}

function Write-AllBytesShared([string]$path, [byte[]]$bytes) {
    $fs = [System.IO.File]::Open($path, [System.IO.FileMode]::OpenOrCreate, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::ReadWrite)
    try {
        $fs.SetLength(0)
        $fs.Write($bytes, 0, $bytes.Length)
        $fs.Flush()
    } finally {
        $fs.Close()
    }
}

function Invoke-LiveCdpCleanup() {
    $devPortFile = "$env:APPDATA\Antigravity\DevToolsActivePort"
    if (-not (Test-Path $devPortFile)) { return $false }
    try {
        $lines = Get-Content $devPortFile -ErrorAction Stop
        if ($lines.Count -lt 2) { return $false }
        $port = $lines[0].Trim()
        $wsPath = $lines[1].Trim()
        $uri = [Uri]("ws://127.0.0.1:$port$wsPath")

        $ws = New-Object System.Net.WebSockets.ClientWebSocket
        $cts = New-Object System.Threading.CancellationTokenSource(4000)
        $ws.ConnectAsync($uri, $cts.Token).GetAwaiter().GetResult() | Out-Null

        function Send-WsJson($obj) {
            $json = $obj | ConvertTo-Json -Depth 10 -Compress
            $buf = [System.Text.Encoding]::UTF8.GetBytes($json)
            $seg = New-Object System.ArraySegment[byte]($buf, 0, $buf.Length)
            $ws.SendAsync($seg, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, $cts.Token).GetAwaiter().GetResult() | Out-Null
        }

        function Receive-WsJson() {
            $ms = New-Object System.IO.MemoryStream
            $buf = New-Object byte[] 16384
            do {
                $seg = New-Object System.ArraySegment[byte]($buf, 0, $buf.Length)
                $res = $ws.ReceiveAsync($seg, $cts.Token).GetAwaiter().GetResult()
                $ms.Write($buf, 0, $res.Count)
            } while (-not $res.EndOfMessage)
            $str = [System.Text.Encoding]::UTF8.GetString($ms.ToArray())
            return ($str | ConvertFrom-Json)
        }

        Send-WsJson @{ id = 1; method = "Target.getTargets" }
        $targetsResp = Receive-WsJson
        $pages = @($targetsResp.result.targetInfos | Where-Object { $_.type -eq "page" })
        $msgId = 10
        $cleanupJs = "(() => { if (window.__antigravityRtlUltraCleanup) window.__antigravityRtlUltraCleanup(); const s = document.getElementById('antigravity-rtl-ultra-style'); if (s) s.remove(); document.querySelectorAll('[data-rtl-ultra]').forEach(el => { el.removeAttribute('dir'); el.removeAttribute('data-rtl-ultra'); }); })()"

        foreach ($page in $pages) {
            $msgId++
            Send-WsJson @{
                id = $msgId
                method = "Target.attachToTarget"
                params = @{ targetId = $page.targetId; flatten = $true }
            }
            $attachResp = $null
            while ($true) {
                $r = Receive-WsJson
                if ($r.id -eq $msgId) { $attachResp = $r; break }
            }
            $sessionId = $attachResp.result.sessionId
            if ($sessionId) {
                $msgId++
                Send-WsJson @{
                    id = $msgId
                    sessionId = $sessionId
                    method = "Runtime.evaluate"
                    params = @{ expression = $cleanupJs; returnByValue = $true }
                }
                while ($true) {
                    $r = Receive-WsJson
                    if ($r.id -eq $msgId) { break }
                }
            }
        }

        $ws.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, "done", $cts.Token).GetAwaiter().GetResult() | Out-Null
        return $true
    } catch {
        return $false
    }
}

# 1. Restore Antigravity Desktop 2.x app.asar
$desktopAsar = "$localAppData\Programs\Antigravity\resources\app.asar"
$desktopBak = "$desktopAsar.rtlbak"
if (Test-Path $desktopBak) {
    $anyRestored = $true
    Write-Host "`n[+] Restoring Antigravity Desktop 2.x from golden backup..." -ForegroundColor Yellow
    $bakBytes = Read-AllBytesShared $desktopBak
    Write-AllBytesShared $desktopAsar $bakBytes
    Remove-Item $desktopBak -Force -ErrorAction SilentlyContinue
    Write-Host "  [OK] Restored original app.asar byte-for-byte!" -ForegroundColor Green
}

if (Invoke-LiveCdpCleanup) {
    $anyRestored = $true
    Write-Host "  [OK] Removed RTL Ultra live from open Antigravity windows!" -ForegroundColor Green
}

# 2. Restore Classic IDE CSS files
$candidates = @(
    "$localAppData\Programs\Antigravity IDE\resources\app\out\vs\workbench\workbench.desktop.main.css",
    "$localAppData\Programs\Cursor\resources\app\out\vs\workbench\workbench.desktop.main.css",
    "$localAppData\Programs\Windsurf\resources\app\out\vs\workbench\workbench.desktop.main.css",
    "$localAppData\Programs\Microsoft VS Code\resources\app\out\vs\workbench\workbench.desktop.main.css"
)

foreach ($target in $candidates) {
    $backup = "$target.rtlbak"
    if (Test-Path $backup) {
        $anyRestored = $true
        Copy-Item $backup $target -Force
        Remove-Item $backup -Force
        Write-Host "  [OK] Restored original file: $target" -ForegroundColor Green
    }
}

Write-Host "`n==========================================================" -ForegroundColor Green
if ($anyRestored) {
    Write-Host " [OK] 100% Factory Rollback Completed Successfully!       " -ForegroundColor Green
} else {
    Write-Host " [i]  System is already in clean factory state.           " -ForegroundColor Cyan
}
Write-Host "==========================================================" -ForegroundColor Green
