<#
.SYNOPSIS
    Antigravity RTL Ultra v2.1 -- Universal 1-Click Installer (Windows)
.DESCRIPTION
    100% Safe, Zero-Dependency Dual-Engine Installer for:
    1. Antigravity 2.x Desktop (Jetbox / Electron app.asar + Live CDP Hot-Injection)
    2. Antigravity IDE 1.x / Cursor / Windsurf / VS Code (workbench.desktop.main.css)
    Supports both 1-command remote execution (irm ... | iex) and local execution.
#>

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Antigravity RTL Ultra v2.1 -- Universal BiDi Engine    " -ForegroundColor Green
Write-Host "   https://github.com/sassil70/antigravity-rtl-ultra      " -ForegroundColor Gray
Write-Host "==========================================================" -ForegroundColor Cyan

# -----------------------------------------------------------------------------
# 1. Load CSS Bundle (Local Repo or Remote GitHub with Built-in Fallback)
# -----------------------------------------------------------------------------
$bundleCss = $null
$scriptDir = $null
if ($MyInvocation.MyCommand.Path) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
} elseif ($PSScriptRoot) {
    $scriptDir = $PSScriptRoot
}

if ($scriptDir) {
    $localBundle = Join-Path (Split-Path -Parent $scriptDir) "src\styles\bundle.css"
    if (Test-Path $localBundle) {
        $bundleCss = [System.IO.File]::ReadAllText($localBundle, [System.Text.Encoding]::UTF8)
        Write-Host "[*] Loaded bundle.css from local repository." -ForegroundColor Gray
    }
}

if (-not $bundleCss) {
    $bundleUrl = "https://raw.githubusercontent.com/sassil70/antigravity-rtl-ultra/main/src/styles/bundle.css"
    try {
        Write-Host "[*] Fetching latest bundle.css from GitHub..." -ForegroundColor Gray
        $bundleCss = Invoke-RestMethod -Uri $bundleUrl -UseBasicParsing -TimeoutSec 10
    } catch {
        Write-Host "[!] Using embedded v2.1 fallback CSS bundle." -ForegroundColor Yellow
    }
}

# Compact runtime CSS for Electron preload & live hot-injection (keeps ASAR header size stable)
$runtimeCss = @'
:is(p,li,h1,h2,h3,h4,h5,h6,blockquote,td,th,dt,dd,.markdown-alert)[dir="rtl"]{direction:rtl!important;unicode-bidi:normal!important;text-align:right!important;}
:is(p,li,h1,h2,h3,h4,h5,h6,td,th,dt,dd):not([dir="rtl"]):not(.select-none):not(.sr-only){unicode-bidi:plaintext!important;text-align:start!important;}
textarea,input[type="text"],[contenteditable="true"]{unicode-bidi:plaintext!important;text-align:start!important;}
:not(pre)>code,code.whitespace-pre-wrap,.context-scope-mention,.inline-pill,a.text-link[data-rtl-ltr-link="true"]{unicode-bidi:isolate!important;direction:ltr!important;display:inline-block!important;vertical-align:baseline!important;max-width:100%!important;}
:not(pre)>code{padding:0.1em 0.35em!important;margin:0 0.12em!important;border-radius:4px!important;}
pre,pre code,pre *,.code-block,.code-block *,.code-line,.code-line *,.line-content,.line-content *,.line-number,.monaco-editor,.monaco-editor *,.view-lines,.view-line,.code-snippet,.terminal,.terminal *,.xterm,.xterm *{direction:ltr!important;unicode-bidi:embed!important;text-align:left!important;}
:is(ul,ol)[dir="rtl"],.md-divider-spacing :is(ul,ol)[dir="rtl"]{direction:rtl!important;text-align:right!important;padding-right:1.5rem!important;padding-left:0!important;margin-right:0!important;margin-left:0!important;}
blockquote[dir="rtl"],.md-divider-spacing blockquote[dir="rtl"],.markdown-alert[dir="rtl"],[class*="alert-"][dir="rtl"]{direction:rtl!important;unicode-bidi:normal!important;text-align:right!important;border-left:none!important;border-right:4px solid var(--border,rgba(255,255,255,0.25))!important;padding-right:1rem!important;padding-left:0.75rem!important;margin-right:0!important;margin-left:0!important;}
table[dir="rtl"],.md-divider-spacing table[dir="rtl"]{direction:rtl!important;border-collapse:collapse!important;}
'@.Trim() -replace "\r?\n", ""

if (-not $bundleCss) {
    $bundleCss = "/* RTL-PATCH-START */`n$runtimeCss`n/* RTL-PATCH-END */"
}

# Build Smart RTL JS Engine (CSS + MutationObserver + Cleanup Hook)
$escapedRuntimeCss = $runtimeCss.Replace('\', '\\').Replace("'", "\'")
$smartRtlJs = @"

// [ANTIGRAVITY-RTL-ULTRA-START]
(() => {
  if (typeof window === 'undefined') return;
  if (window.__antigravityRtlUltraCleanup) {
    try { window.__antigravityRtlUltraCleanup(); } catch (e) {}
  }
  const STYLE_ID = 'antigravity-rtl-ultra-style';
  const RTL_CSS = '$escapedRuntimeCss';
  const ARABIC_RE = /[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]/;
  const BLOCK_SEL = 'p, li, h1, h2, h3, h4, h5, h6, ul, ol, blockquote, table, td, th, dt, dd, .markdown-alert';
  const QUARANTINE_SEL = 'pre, .code-block, .code-line, .line-content, .monaco-editor, .terminal, .xterm, [data-lexical-editor="true"], [contenteditable="true"]';

  function ensureStyle() {
    if (!document || !document.documentElement) return;
    let s = document.getElementById(STYLE_ID);
    if (!s) {
      s = document.createElement('style');
      s.id = STYLE_ID;
      (document.head || document.documentElement).appendChild(s);
    }
    if (s.textContent !== RTL_CSS) s.textContent = RTL_CSS;
  }

  function processEl(el) {
    if (!el || el.nodeType !== 1) return;
    if (el.closest && el.closest(QUARANTINE_SEL)) return;
    const tag = el.tagName;
    if ((tag === 'H1' || tag === 'H2') && (el.classList.contains('sr-only') || el.classList.contains('select-none'))) return;
    if (ARABIC_RE.test(el.textContent || '')) {
      if (el.getAttribute('dir') !== 'rtl') {
        el.setAttribute('dir', 'rtl');
        el.setAttribute('data-rtl-ultra', '1');
      }
    } else if (el.getAttribute('data-rtl-ultra') === '1') {
      el.removeAttribute('dir');
      el.removeAttribute('data-rtl-ultra');
    }
  }

  function scan(root) {
    if (!root || !root.querySelectorAll) return;
    ensureStyle();
    if (root.nodeType === 1 && root.matches && root.matches(BLOCK_SEL)) processEl(root);
    const els = root.querySelectorAll(BLOCK_SEL);
    for (let i = 0; i < els.length; i++) processEl(els[i]);
    const links = root.querySelectorAll('a.text-link');
    for (let i = 0; i < links.length; i++) {
      const a = links[i];
      if (!ARABIC_RE.test(a.textContent || '') && a.getAttribute('data-rtl-ltr-link') !== 'true') {
        a.setAttribute('data-rtl-ltr-link', 'true');
      }
    }
  }

  let raf = false;
  function schedule() {
    if (raf) return;
    raf = true;
    requestAnimationFrame(() => {
      raf = false;
      if (document && document.body) scan(document.body);
    });
  }

  let obs = null;
  function init() {
    ensureStyle();
    if (document && document.body) {
      scan(document.body);
      if (!obs) {
        obs = new MutationObserver(schedule);
        obs.observe(document.body, { childList: true, subtree: true, characterData: true });
      }
    }
  }

  if (typeof document !== 'undefined') {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', init);
    } else {
      init();
    }
  }
  const tmr = setInterval(init, 1500);

  window.__antigravityRtlUltraCleanup = () => {
    clearInterval(tmr);
    if (obs) { obs.disconnect(); obs = null; }
    const s = document.getElementById(STYLE_ID);
    if (s) s.remove();
    const els = document.querySelectorAll('[data-rtl-ultra="1"]');
    for (let i = 0; i < els.length; i++) {
      els[i].removeAttribute('dir');
      els[i].removeAttribute('data-rtl-ultra');
    }
    const lnks = document.querySelectorAll('[data-rtl-ltr-link="true"]');
    for (let i = 0; i < lnks.length; i++) lnks[i].removeAttribute('data-rtl-ltr-link');
  };
})();
// [ANTIGRAVITY-RTL-ULTRA-END]
"@

$localAppData = $env:LOCALAPPDATA
$anyInstalled = $false

# -----------------------------------------------------------------------------
# ENGINE 1: Antigravity 2.x Desktop (Native .NET ASAR Patcher + Live CDP Inject)
# -----------------------------------------------------------------------------
$antigravityDesktopDir = "$localAppData\Programs\Antigravity"
$desktopAsar = "$antigravityDesktopDir\resources\app.asar"

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

function Invoke-LiveCdpInjection([string]$jsCode) {
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
        $injectedCount = 0
        $msgId = 10

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
                    params = @{ expression = $jsCode; returnByValue = $true }
                }
                while ($true) {
                    $r = Receive-WsJson
                    if ($r.id -eq $msgId) { break }
                }
                $injectedCount++
            }
        }

        $ws.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, "done", $cts.Token).GetAwaiter().GetResult() | Out-Null
        return ($injectedCount -gt 0)
    } catch {
        return $false
    }
}

if (Test-Path $desktopAsar) {
    $anyInstalled = $true
    Write-Host "`n[+] Detected Antigravity Desktop 2.x (Jetbox Architecture)" -ForegroundColor Yellow
    Write-Host "    Target: $desktopAsar" -ForegroundColor Gray

    $backupAsar = "$desktopAsar.rtlbak"
    $currentBytes = Read-AllBytesShared $desktopAsar

    # Inspect current app.asar header & preload.js
    $headerSize = [BitConverter]::ToUInt32($currentBytes, 4)
    $strLen = [BitConverter]::ToUInt32($currentBytes, 12)
    $baseOffset = 8 + $headerSize
    $headerJson = [System.Text.Encoding]::UTF8.GetString($currentBytes, 16, $strLen)

    $preloadRegex = '"preload\.js"\s*:\s*\{\s*"size"\s*:\s*(\d+)\s*,\s*"offset"\s*:\s*"(\d+)"\s*,\s*"integrity"\s*:\s*\{\s*"algorithm"\s*:\s*"SHA256"\s*,\s*"hash"\s*:\s*"([a-f0-9]+)"\s*,\s*"blockSize"\s*:\s*(\d+)\s*,\s*"blocks"\s*:\s*\[\s*"([a-f0-9]+)"\s*\]\s*\}\s*\}'
    $allMatches = [regex]::Matches($headerJson, $preloadRegex)
    $preloadMatch = $null
    foreach ($m in $allMatches) {
        $sz = [int]$m.Groups[1].Value
        $off = [int64]$m.Groups[2].Value
        $txt = [System.Text.Encoding]::UTF8.GetString($currentBytes, [int]($baseOffset + $off), $sz)
        if ($txt.Contains("contextBridge")) {
            $preloadMatch = $m
            $preloadContent = $txt
            break
        }
    }
    if (-not $preloadMatch) {
        throw "Could not locate dist/preload.js entry in app.asar header."
    }

    # If current app.asar is clean/unpatched (first install or after an official app update), save it as the golden backup!
    if (-not $preloadContent.Contains("[ANTIGRAVITY-RTL-ULTRA-START]")) {
        Write-AllBytesShared $backupAsar $currentBytes
        Write-Host "  [1/3] Created verified golden backup: app.asar.rtlbak" -ForegroundColor Gray
        $sourceBytes = $currentBytes
    } elseif (Test-Path $backupAsar) {
        Write-Host "  [1/3] Using existing clean backup: app.asar.rtlbak" -ForegroundColor Gray
        $sourceBytes = Read-AllBytesShared $backupAsar
    } else {
        $sourceBytes = $currentBytes
    }

    # Parse clean source bytes
    $srcHeaderSize = [BitConverter]::ToUInt32($sourceBytes, 4)
    $srcStrLen = [BitConverter]::ToUInt32($sourceBytes, 12)
    $srcBaseOffset = 8 + $srcHeaderSize
    $srcHeaderJson = [System.Text.Encoding]::UTF8.GetString($sourceBytes, 16, $srcStrLen)

    $srcMatches = [regex]::Matches($srcHeaderJson, $preloadRegex)
    $srcPreloadMatch = $null
    foreach ($m in $srcMatches) {
        $sz = [int]$m.Groups[1].Value
        $off = [int64]$m.Groups[2].Value
        $txt = [System.Text.Encoding]::UTF8.GetString($sourceBytes, [int]($srcBaseOffset + $off), $sz)
        if ($txt.Contains("contextBridge")) {
            $srcPreloadMatch = $m
            $origPreloadText = $txt
            break
        }
    }
    if (-not $srcPreloadMatch) {
        throw "Could not parse dist/preload.js metadata in source app.asar."
    }

    $blockSize = $srcPreloadMatch.Groups[4].Value

    # Strip any older patch if present
    $markerStart = "// [ANTIGRAVITY-RTL-ULTRA-START]"
    if ($origPreloadText.Contains($markerStart)) {
        $origPreloadText = $origPreloadText.Substring(0, $origPreloadText.IndexOf($markerStart)).TrimEnd() + "`n"
    }

    Write-Host "  [2/3] Injecting Smart Dual-Pane BiDi Engine into preload.js..." -ForegroundColor Gray
    $newPreloadText = $origPreloadText + $smartRtlJs
    $newPreloadBytes = [System.Text.Encoding]::UTF8.GetBytes($newPreloadText)

    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $newHash = ([BitConverter]::ToString($sha256.ComputeHash($newPreloadBytes))).Replace("-", "").ToLowerInvariant()

    # Append patched preload.js at the end of the ASAR payload so ALL existing file offsets remain 100% untouched!
    $payloadLength = $sourceBytes.Length - $srcBaseOffset
    $newOffsetStr = "$payloadLength"
    $newSizeStr = "$($newPreloadBytes.Length)"

    $newPreloadEntry = "`"preload.js`":{`"size`":$newSizeStr,`"offset`":`"$newOffsetStr`",`"integrity`":{`"algorithm`":`"SHA256`",`"hash`":`"$newHash`",`"blockSize`":$blockSize,`"blocks`":[`"$newHash`"]}}"
    $newHeaderJson = $srcHeaderJson.Substring(0, $srcPreloadMatch.Index) + $newPreloadEntry + $srcHeaderJson.Substring($srcPreloadMatch.Index + $srcPreloadMatch.Length)

    $newHeaderStrBytes = [System.Text.Encoding]::UTF8.GetBytes($newHeaderJson)
    $newStrLen = $newHeaderStrBytes.Length
    $alignedStrSize = [int]([Math]::Ceiling($newStrLen / 4.0) * 4)
    $newPicklePayloadSize = 4 + $alignedStrSize
    $newHeaderSize = 4 + $newPicklePayloadSize
    $newBaseOffset = 8 + $newHeaderSize

    $outBytes = New-Object byte[] ($newBaseOffset + $payloadLength + $newPreloadBytes.Length)
    [Array]::Copy([BitConverter]::GetBytes([uint32]4), 0, $outBytes, 0, 4)
    [Array]::Copy([BitConverter]::GetBytes([uint32]$newHeaderSize), 0, $outBytes, 4, 4)
    [Array]::Copy([BitConverter]::GetBytes([uint32]$newPicklePayloadSize), 0, $outBytes, 8, 4)
    [Array]::Copy([BitConverter]::GetBytes([uint32]$newStrLen), 0, $outBytes, 12, 4)
    [Array]::Copy($newHeaderStrBytes, 0, $outBytes, 16, $newStrLen)
    [Array]::Copy($sourceBytes, $srcBaseOffset, $outBytes, $newBaseOffset, $payloadLength)
    [Array]::Copy($newPreloadBytes, 0, $outBytes, $newBaseOffset + $payloadLength, $newPreloadBytes.Length)

    Write-AllBytesShared $desktopAsar $outBytes
    Write-Host "  [OK] Patched app.asar in-place with zero downtime!" -ForegroundColor Green

    Write-Host "  [3/3] Activating live in open Antigravity windows..." -ForegroundColor Gray
    if (Invoke-LiveCdpInjection $smartRtlJs) {
        Write-Host "  [OK] Live RTL Engine activated immediately in open window (no restart needed)!" -ForegroundColor Green
    } else {
        Write-Host "  [OK] Ready! RTL Engine will activate automatically when Antigravity opens." -ForegroundColor Green
    }
}

# -----------------------------------------------------------------------------
# ENGINE 2: Antigravity IDE 1.x / Cursor / Windsurf / VS Code (CSS Workbench)
# -----------------------------------------------------------------------------
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
            }
        } catch {}
    }
}

foreach ($target in $cssTargets) {
    if (Test-Path $target) {
        $anyInstalled = $true
        Write-Host "`n[+] Detected Classic Workbench IDE: $target" -ForegroundColor Yellow
        $backup = "$target.rtlbak"
        if (-not (Test-Path $backup)) { Copy-Item $target $backup -Force }

        $content = [System.IO.File]::ReadAllText($target, [System.Text.Encoding]::UTF8)
        if ($content.Contains($CSS_MARKER_START) -and $content.Contains($CSS_MARKER_END)) {
            $startIdx = $content.IndexOf($CSS_MARKER_START)
            $endIdx = $content.IndexOf($CSS_MARKER_END) + $CSS_MARKER_END.Length
            $content = $content.Substring(0, $startIdx) + $content.Substring($endIdx)
        }

        $newContent = $content.TrimEnd() + "`n`n" + $bundleCss + "`n"
        [System.IO.File]::WriteAllText($target, $newContent, [System.Text.Encoding]::UTF8)
        Update-Checksum $target $newContent
        Write-Host "  [OK] Applied RTL Ultra to workbench CSS!" -ForegroundColor Green
    }
}

Write-Host "`n==========================================================" -ForegroundColor Green
if ($anyInstalled) {
    Write-Host " [OK] Antigravity RTL Ultra v2.1 Installed Successfully!  " -ForegroundColor Green
    Write-Host " [i]  To rollback anytime, run uninstall.ps1              " -ForegroundColor Cyan
} else {
    Write-Host " [!] No supported installations found in default paths.   " -ForegroundColor Yellow
}
Write-Host "==========================================================" -ForegroundColor Green
