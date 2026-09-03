# Changelog — Antigravity RTL Ultra

All notable changes to this project are documented in this file.

---

## [2.0.0] — 2026-09-03

### 🚀 Major Architectural Breakthrough: Antigravity Desktop 2.12.0+ Support
In September 2026, Antigravity Desktop released version 2.12.0, completely restructuring the application architecture from an open VS Code workbench layout into a sealed, compiled **Electron ASAR package** (`resources\app.asar`), where UI is served locally via `language_server.exe` (`https://127.0.0.1:<port>`).

This version updates **Antigravity RTL Ultra** into a **Universal Dual-Engine Patcher** supporting both Electron ASAR packages and classic VS Code CSS files.

### ✨ What's New & Actions Taken
- **Electron ASAR Engine (Engine 1):**
  - Automated extraction of `app.asar` via `@electron/asar`.
  - Injects RTL Ultra BiDi engine directly into `dist/preload.js` before page initialization.
  - Monitors dynamic view transitions and injects `<style id="antigravity-rtl-ultra-style">` into the DOM.
  - Repacks `app.asar` with proper `--unpack` boundaries for native dependencies (e.g., `chrome-devtools-mcp`).
- **1-Click Desktop Applier (`cli/apply-desktop.ps1`):**
  - New dedicated script to safely close Antigravity, apply the patched ASAR bundle atomically, and relaunch the application.
  - Safe against file-locking errors on Windows.
- **Process Protection:**
  - Designed with self-termination guardrails so agent sessions running under `language_server.exe` are not accidentally killed mid-flight.
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
