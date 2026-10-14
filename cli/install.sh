#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "   Antigravity RTL Ultra v2.1 -- 1-Click Installer (Unix) "
echo "   https://github.com/sassil70/antigravity-rtl-ultra      "
echo "=========================================================="

BUNDLE_URL="https://raw.githubusercontent.com/sassil70/antigravity-rtl-ultra/main/src/styles/bundle.css"
PATCH_CSS=""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
if [ -n "$SCRIPT_DIR" ] && [ -f "${SCRIPT_DIR}/../src/styles/bundle.css" ]; then
    PATCH_CSS=$(cat "${SCRIPT_DIR}/../src/styles/bundle.css")
else
    echo "[*] Fetching bundle.css from GitHub..."
    if command -v curl >/dev/null 2>&1; then
        PATCH_CSS=$(curl -fsSL "$BUNDLE_URL")
    elif command -v wget >/dev/null 2>&1; then
        PATCH_CSS=$(wget -qO- "$BUNDLE_URL")
    else
        echo "Error: Neither curl nor wget found."
        exit 1
    fi
fi

if [ -z "$PATCH_CSS" ]; then
    echo "Error: Failed to load bundle.css"
    exit 1
fi

FOUND=0

# ─────────────────────────────────────────────────────────────────────────────
# ENGINE 1: Antigravity 2.x Desktop (macOS / Linux app.asar)
# ─────────────────────────────────────────────────────────────────────────────
ASAR_TARGETS=(
    "/Applications/Antigravity.app/Contents/Resources/app.asar"
    "$HOME/Applications/Antigravity.app/Contents/Resources/app.asar"
    "/opt/antigravity/resources/app.asar"
    "/usr/share/antigravity/resources/app.asar"
    "$HOME/.local/share/antigravity/resources/app.asar"
)

for ASAR in "${ASAR_TARGETS[@]}"; do
    if [ -f "$ASAR" ] && command -v python3 >/dev/null 2>&1; then
        FOUND=1
        echo "[+] Detected Antigravity Desktop 2.x ASAR: $ASAR"
        python3 - "$ASAR" << 'EOF'
import sys, os, re, struct, hashlib

asar_path = sys.argv[1]
bak_path = asar_path + ".rtlbak"

with open(asar_path, "rb") as f:
    cur_bytes = f.read()

header_size = struct.unpack("<I", cur_bytes[4:8])[0]
str_len = struct.unpack("<I", cur_bytes[12:16])[0]
base_offset = 8 + header_size
header_json = cur_bytes[16:16+str_len].decode("utf-8")

pat = r'"preload\.js"\s*:\s*\{\s*"size"\s*:\s*(\d+)\s*,\s*"offset"\s*:\s*"(\d+)"\s*,\s*"integrity"\s*:\s*\{\s*"algorithm"\s*:\s*"SHA256"\s*,\s*"hash"\s*:\s*"([a-f0-9]+)"\s*,\s*"blockSize"\s*:\s*(\d+)\s*,\s*"blocks"\s*:\s*\[\s*"([a-f0-9]+)"\s*\]\s*\}\s*\}'
m = None
for cand in re.finditer(pat, header_json):
    csz, coff = int(cand.group(1)), int(cand.group(2))
    ctxt = cur_bytes[base_offset+coff:base_offset+coff+csz].decode("utf-8", errors="ignore")
    if "contextBridge" in ctxt:
        m = cand
        p_text = ctxt
        break

if m:
    if "[ANTIGRAVITY-RTL-ULTRA-START]" not in p_text:
        with open(bak_path, "wb") as bf:
            bf.write(cur_bytes)
        src_bytes = cur_bytes
        print("  [1/2] Created golden backup: " + bak_path)
    elif os.path.exists(bak_path):
        with open(bak_path, "rb") as bf:
            src_bytes = bf.read()
        print("  [1/2] Using existing clean backup: " + bak_path)
    else:
        src_bytes = cur_bytes

    sh_size = struct.unpack("<I", src_bytes[4:8])[0]
    s_len = struct.unpack("<I", src_bytes[12:16])[0]
    s_base = 8 + sh_size
    s_json = src_bytes[16:16+s_len].decode("utf-8")

    sm = None
    for cand in re.finditer(pat, s_json):
        csz, coff = int(cand.group(1)), int(cand.group(2))
        ctxt = src_bytes[s_base+coff:s_base+coff+csz].decode("utf-8", errors="ignore")
        if "contextBridge" in ctxt:
            sm = cand
            orig_preload = ctxt
            break

    if sm:
        blk_size = sm.group(4)
        if "// [ANTIGRAVITY-RTL-ULTRA-START]" in orig_preload:
            orig_preload = orig_preload.split("// [ANTIGRAVITY-RTL-ULTRA-START]")[0].rstrip() + "\n"

        rtl_js = """
// [ANTIGRAVITY-RTL-ULTRA-START]
(() => {
  if (typeof window === 'undefined') return;
  const STYLE_ID = 'antigravity-rtl-ultra-style';
  const RTL_CSS = ':is(p,li,h1,h2,h3,h4,h5,h6,blockquote,td,th,dt,dd,.markdown-alert)[dir="rtl"]{direction:rtl!important;unicode-bidi:normal!important;text-align:right!important;}:is(p,li,h1,h2,h3,h4,h5,h6,td,th,dt,dd):not([dir="rtl"]):not(.select-none):not(.sr-only){unicode-bidi:plaintext!important;text-align:start!important;}textarea,input[type="text"],[contenteditable="true"]{unicode-bidi:plaintext!important;text-align:start!important;}:not(pre)>code,code.whitespace-pre-wrap,.context-scope-mention,.inline-pill,a.text-link[data-rtl-ltr-link="true"]{unicode-bidi:isolate!important;direction:ltr!important;display:inline-block!important;vertical-align:baseline!important;max-width:100%!important;}:not(pre)>code{padding:0.1em 0.35em!important;margin:0 0.12em!important;border-radius:4px!important;}pre,pre code,pre *,.code-block,.code-block *,.code-line,.code-line *,.line-content,.line-content *,.line-number,.monaco-editor,.monaco-editor *,.view-lines,.view-line,.code-snippet,.terminal,.terminal *,.xterm,.xterm *{direction:ltr!important;unicode-bidi:embed!important;text-align:left!important;}:is(ul,ol)[dir="rtl"],.md-divider-spacing :is(ul,ol)[dir="rtl"]{direction:rtl!important;text-align:right!important;padding-right:1.5rem!important;padding-left:0!important;margin-right:0!important;margin-left:0!important;}blockquote[dir="rtl"],.md-divider-spacing blockquote[dir="rtl"],.markdown-alert[dir="rtl"],[class*="alert-"][dir="rtl"]{direction:rtl!important;unicode-bidi:normal!important;text-align:right!important;border-left:none!important;border-right:4px solid var(--border,rgba(255,255,255,0.25))!important;padding-right:1rem!important;padding-left:0.75rem!important;margin-right:0!important;margin-left:0!important;}table[dir="rtl"],.md-divider-spacing table[dir="rtl"]{direction:rtl!important;border-collapse:collapse!important;}';
  const ARABIC_RE = /[\\u0600-\\u06FF\\u0750-\\u077F\\u08A0-\\u08FF\\uFB50-\\uFDFF\\uFE70-\\uFEFF]/;
  const BLOCK_SEL = 'p, li, h1, h2, h3, h4, h5, h6, ul, ol, blockquote, table, td, th, dt, dd, .markdown-alert';
  const QUARANTINE_SEL = 'pre, .code-block, .code-line, .line-content, .monaco-editor, .terminal, .xterm, [data-lexical-editor="true"], [contenteditable="true"]';
  function ensureStyle() {
    if (!document || !document.documentElement) return;
    let s = document.getElementById(STYLE_ID);
    if (!s) { s = document.createElement('style'); s.id = STYLE_ID; (document.head || document.documentElement).appendChild(s); }
    if (s.textContent !== RTL_CSS) s.textContent = RTL_CSS;
  }
  function processEl(el) {
    if (!el || el.nodeType !== 1 || (el.closest && el.closest(QUARANTINE_SEL))) return;
    const tag = el.tagName;
    if ((tag === 'H1' || tag === 'H2') && (el.classList.contains('sr-only') || el.classList.contains('select-none'))) return;
    if (ARABIC_RE.test(el.textContent || '')) {
      if (el.getAttribute('dir') !== 'rtl') { el.setAttribute('dir', 'rtl'); el.setAttribute('data-rtl-ultra', '1'); }
    } else if (el.getAttribute('data-rtl-ultra') === '1') {
      el.removeAttribute('dir'); el.removeAttribute('data-rtl-ultra');
    }
  }
  function scan(root) {
    if (!root || !root.querySelectorAll) return;
    ensureStyle();
    const els = root.querySelectorAll(BLOCK_SEL);
    for (let i = 0; i < els.length; i++) processEl(els[i]);
    const links = root.querySelectorAll('a.text-link');
    for (let i = 0; i < links.length; i++) {
      if (!ARABIC_RE.test(links[i].textContent || '')) links[i].setAttribute('data-rtl-ltr-link', 'true');
    }
  }
  let obs = null;
  function init() {
    ensureStyle();
    if (document && document.body) {
      scan(document.body);
      if (!obs) { obs = new MutationObserver(() => requestAnimationFrame(() => document.body && scan(document.body))); obs.observe(document.body, { childList: true, subtree: true, characterData: true }); }
    }
  }
  if (typeof document !== 'undefined') {
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init); else init();
  }
  setInterval(init, 1500);
})();
// [ANTIGRAVITY-RTL-ULTRA-END]
"""
        new_preload = (orig_preload + rtl_js).encode("utf-8")
        new_hash = hashlib.sha256(new_preload).hexdigest()
        payload = src_bytes[s_base:]
        new_off = str(len(payload))
        new_sz = str(len(new_preload))
        new_entry = f'"preload.js":{{"size":{new_sz},"offset":"{new_off}","integrity":{{"algorithm":"SHA256","hash":"{new_hash}","blockSize":{blk_size},"blocks":["{new_hash}"]}}}}'
        new_json = (s_json[:sm.start()] + new_entry + s_json[sm.end():]).encode("utf-8")
        n_slen = len(new_json)
        aligned = ((n_slen + 3) // 4) * 4
        pad = b"\x00" * (aligned - n_slen)
        pickle_sz = 4 + aligned
        hdr_sz = 4 + pickle_sz
        out = struct.pack("<IIII", 4, hdr_sz, pickle_sz, n_slen) + new_json + pad + payload + new_preload
        with open(asar_path, "wb") as out_f:
            out_f.write(out)
        print("  [2/2] Patched app.asar successfully!")
EOF
    fi
done

# ─────────────────────────────────────────────────────────────────────────────
# ENGINE 2: Classic Workbench CSS IDEs
# ─────────────────────────────────────────────────────────────────────────────
TARGETS=()

if [[ "$OSTYPE" == "darwin"* ]]; then
    TARGETS+=(
        "/Applications/Antigravity IDE.app/Contents/Resources/app/out/vs/workbench/workbench.desktop.main.css"
        "/Applications/Antigravity.app/Contents/Resources/app/out/vs/workbench/workbench.desktop.main.css"
        "/Applications/Cursor.app/Contents/Resources/app/out/vs/workbench/workbench.desktop.main.css"
        "/Applications/Windsurf.app/Contents/Resources/app/out/vs/workbench/workbench.desktop.main.css"
        "/Applications/Visual Studio Code.app/Contents/Resources/app/out/vs/workbench/workbench.desktop.main.css"
        "$HOME/Applications/Antigravity.app/Contents/Resources/app/out/vs/workbench/workbench.desktop.main.css"
    )
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    TARGETS+=(
        "/opt/antigravity-ide/resources/app/out/vs/workbench/workbench.desktop.main.css"
        "/opt/antigravity/resources/app/out/vs/workbench/workbench.desktop.main.css"
        "/opt/cursor/resources/app/out/vs/workbench/workbench.desktop.main.css"
        "/opt/windsurf/resources/app/out/vs/workbench/workbench.desktop.main.css"
        "/usr/share/code/resources/app/out/vs/workbench/workbench.desktop.main.css"
        "$HOME/.local/share/antigravity/resources/app/out/vs/workbench/workbench.desktop.main.css"
    )
fi

for TARGET in "${TARGETS[@]}"; do
    if [ -f "$TARGET" ]; then
        FOUND=1
        echo "[+] Detected Workbench CSS Target: $TARGET"
        BACKUP="${TARGET}.rtlbak"
        if [ ! -f "$BACKUP" ]; then
            cp "$TARGET" "$BACKUP"
            echo "  [+] Created backup at: $BACKUP"
        fi

        sed -i.tmp '/\/\* RTL-PATCH-START \*\//,/\/\* RTL-PATCH-END \*\//d' "$TARGET" 2>/dev/null || true
        rm -f "${TARGET}.tmp"

        echo "" >> "$TARGET"
        echo "$PATCH_CSS" >> "$TARGET"
        echo "  [OK] Antigravity RTL Ultra v2.1 applied successfully!"
    fi
done

if [ $FOUND -eq 1 ]; then
    echo "=========================================================="
    echo " ✅ Installation Complete! Please restart Antigravity.    "
    echo "=========================================================="
else
    echo "No supported installations found in standard paths."
fi
