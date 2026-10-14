# Changelog — Antigravity RTL Ultra

All notable changes to this project are documented in this file.

---

## [2.1.0] — 2026-10-14

### 🔥 Breakthrough Release: Antigravity 2.23+ Jetbox Smart BiDi Engine & Zero-Downtime Live Patching
After the October 2026 update (**Antigravity v2.23.0 — Jetbox UI**), AI responses rendered via `CustomMarkdown` split words into animated `<span>` nodes without `dir` attributes, causing any embedded English word (e.g., `github`, `Bug`, `README.md`, `Eng. Saleem Asseel`) or `<br>` line break to drop to **Unicode BiDi Level 0 (`LTR`)** and invert the surrounding Arabic sentence, parentheses `()`, and colons `:`.

### ✨ What's New in v2.1.0
- **Smart Arabic DOM BiDi Observer + CSS Hybrid Engine:**
  - Automatically detects Arabic script (`[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]`) in `<p>`, `<li>`, `<h1>–<h6>`, `<ul>`, `<ol>`, `<blockquote>`, `<table>`, and `.markdown-alert` elements via a lightweight `MutationObserver` (`requestAnimationFrame`-throttled).
  - Applies `dir="rtl"` and `unicode-bidi: normal !important` to Arabic blocks so forced line breaks (`<br>`) and leading English tokens never reset line direction to `LTR`.
  - Leaves 100% English paragraphs and UI sidebar headers (`h2.select-none`, `h1.sr-only`) completely untouched (`LTR`).
  - Excludes `[data-lexical-editor="true"]` so the native Lexical user chat editor continues operating untouched.
- **Strict UAX #9 Inline Island Isolation:**
  - Isolates `:not(pre) > code`, `code.whitespace-pre-wrap`, `.context-scope-mention`, `.inline-pill`, and non-Arabic `a.text-link` elements with `unicode-bidi: isolate !important; direction: ltr !important;`.
  - Prevents English words, file pills, paths, and URLs from splitting Arabic sentences or flipping adjacent parentheses `()` and colons `:`.
- **Jetbox Code Block Quarantine:**
  - Strictly quarantines `.code-block`, `.code-line`, `.line-content`, `.line-number`, `pre`, `.monaco-editor`, `.terminal`, and `.xterm` to `direction: ltr !important; text-align: left !important;`.
- **Zero-Dependency, Zero-Downtime Native .NET ASAR Patcher + Live CDP Hot-Injector:**
  - Replaced `npx asar` with a **100% native .NET binary ASAR patcher** in `cli/install.ps1` (requires zero external dependencies, runs in <50ms, and works while Antigravity is running via `FileShare.ReadWrite`).
  - Appends the patched `dist/preload.js` at the end of `app.asar` while keeping all existing file byte offsets (`baseOffset`) 100% unchanged and recalculating the SHA-256 integrity hash.
  - **Live Instant Activation:** Connects to `$env:APPDATA\Antigravity\DevToolsActivePort` via `.NET` `ClientWebSocket` to activate (or rollback) the RTL engine **live on screen in 0.1s without closing or restarting Antigravity**.
  - **1-Command Remote Execution Fixed:** `irm https://raw.githubusercontent.com/sassil70/antigravity-rtl-ultra/main/cli/install.ps1 | iex` now works 100% standalone from anywhere.

---

## [2.0.0] — 2026-09-03

### 🚀 Major Architectural Breakthrough: Antigravity Desktop 2.12.0+ Support
In September 2026, Antigravity Desktop released version 2.12.0, completely restructuring the application architecture from an open VS Code workbench layout into a sealed, compiled **Electron ASAR package** (`resources\app.asar`), where UI is served locally via `language_server.exe` (`https://127.0.0.1:<port>`).

This version updates **Antigravity RTL Ultra** into a **Universal Dual-Engine Patcher** supporting both Electron ASAR packages and classic VS Code CSS files.

### ✨ What's New & Actions Taken
- **Electron ASAR Engine (Engine 1):**
  - Injects RTL Ultra BiDi engine directly into `dist/preload.js` before page initialization.
  - Monitors dynamic view transitions and injects `<style id="antigravity-rtl-ultra-style">` into the DOM.
- **Classic IDE Patcher Retained (Engine 2):**
  - Continues full support for `workbench.desktop.main.css` for Antigravity IDE, Cursor, Windsurf, and VS Code.
- **Automated Checksums:**
  - Dynamic recalculation of SHA256 base64 hashes in `product.json` to prevent "installation is corrupt" warnings.

---

## [1.0.0] — 2026-08-30

### 🎉 Initial Release
- **Dual-Pane BiDi Engine:** Simultaneous support for AI Chat and Artifacts / Reports viewer panels.
- **True BiDi Isolation:** Replaced destructive `display: inline-block` hacks with `unicode-bidi: isolate` for inline code spans.
- **Clean List Formatting:** Preserved native browser counters and list markers using logical CSS properties (`padding-inline-start`).
- **RTL Markdown Alerts:** Aligned GitHub-style callouts (`[!NOTE]`, `[!IMPORTANT]`, `[!TIP]`) to the right edge.
- **Monaco Editor Quarantine:** Strict `direction: ltr` containment for code editors and terminal sessions.
- **1-Click CLI Installers:** PowerShell and Bash installation and instant rollback scripts (`install.ps1`, `uninstall.ps1`, `install.sh`).
