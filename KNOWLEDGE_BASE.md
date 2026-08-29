# Antigravity RTL Ultra — Comprehensive Knowledge Base & Technical Architecture

## 1. Executive Summary & Problem Statement

Modern AI-augmented IDEs (such as **Google Antigravity IDE**, **Cursor**, **Windsurf**, and **VS Code**) lack native, bi-directional (BiDi) support for Right-to-Left (RTL) scripts, including Arabic, Persian, Hebrew, and Urdu.

When developers interact with AI agents in Arabic or work with mixed Arabic-English reports/artifacts, the interface suffers from severe rendering deformities:
1. **Punctuation Inversion:** Periods, colons, brackets, and arithmetic operators jump to the wrong side of the line.
2. **Inline Code Destruction:** Inline code spans (e.g. `` `mcp_config.json` ``) break the sentence flow and flip surrounding text.
3. **List & Counter Distortion:** Numbered and bulleted lists either align to the wrong margin or have fake pseudo-element bullets that break line indentation.
4. **Artifacts / Reports Left-Clamping:** The Artifacts and Report Viewer panel renders all Arabic text aligned to the far-left edge of the screen, with inverted callout alert bars (`[!IMPORTANT]`, `[!NOTE]`).
5. **Code Block Bleed-through:** Flawed global RTL rules bleed into Monaco Editor and code snippets, corrupting syntax indentation.

**Antigravity RTL Ultra** solves this across the entire IDE through a **Dual-Pane Engine Architecture** that addresses both the **AI Chat Conversation** and the **Artifacts / Reports Viewer** simultaneously with zero side-effects on code blocks and English content.

---

## 2. Forensic Analysis of Previous Failed Approaches

| Previous Solution | Implementation Method | Root Cause of Failure |
| :--- | :--- | :--- |
| **`batalelo.antigravity-rtl-patcher`** | Injected CSS into `workbench.desktop.main.css` | • Used brute-force `* { unicode-bidi: plaintext }` causing layout glitches.<br>• Forced `list-style: none` and replaced native list markers with `::before { content: "• " }` and fake CSS counters, which broke mixed numbered lists.<br>• Forced `display: inline-block` on inline code, causing punctuation swapping around code tokens.<br>• **Completely omitted the Artifacts / Report Viewer panel.** |
| **`NaorHL1/antigravity-rtl-patch`** | UserScript / Client-side JS injection | • Designed only for Antigravity 2.0 Web desktop wrapper.<br>• Focused on Hebrew with an overlay button.<br>• Does not integrate into the native IDE extension pipeline or the Artifacts panel. |
| **`dalirnet.rtl-markdown`** | VS Code Markdown Preview Extension | • Only activates on `.rtl.md` files in standard Markdown preview.<br>• Ineffective inside AI Chat panels, tool outputs, or Antigravity's custom artifact renderers. |

---

## 3. Core Architecture: The Dual-Pane BiDi Engine

```
                                 ┌───────────────────────────────────────────────┐
                                 │          Antigravity RTL Ultra Engine         │
                                 └───────────────────────┬───────────────────────┘
                                                         │
                         ┌───────────────────────────────┴───────────────────────────────┐
                         │                                                               │
                         ▼                                                               ▼
        ┌──────────────────────────────────┐                            ┌──────────────────────────────────┐
        │       Pane 1: AI Chat Engine     │                            │    Pane 2: Artifacts & Reports   │
        │      (Cascade Conversation UI)   │                            │       (Report / Document UI)     │
        └────────────────┬─────────────────┘                            └────────────────┬─────────────────┘
                         │                                                               │
     ┌───────────────────┴───────────────────┐                       ┌───────────────────┴───────────────────┐
     │ • Dynamic Paragraph Direction         │                       │ • Auto Container Direction            │
     │ • Isolated Inline Code (`isolate`)    │                       │ • Logical Borders (`border-inline`)   │
     │ • Native Clean List Alignment         │                       │ • Right-Aligned Markdown Headings     │
     │ • Strict LTR Code Blocks (`pre/code`) │                       │ • RTL Alert Callouts (`[!IMPORTANT]`) │
     └───────────────────────────────────────┘                       └───────────────────────────────────────┘
```

---

## 4. Technical Specifications & CSS Engine Rules

### 4.1. True BiDi Isolation (No Inline-Block Hacks)
- **Inline Code Rule:** Inline code must use `unicode-bidi: isolate !important; direction: ltr !important; display: inline !important;`.
  - *Why?* `display: inline-block` forces the browser to treat code as an atomic rectangular box in line breaking, creating a new inline formatting context that flips preceding/succeeding punctuation. `unicode-bidi: isolate` isolates the directional computation while keeping inline text flow intact.

### 4.2. Clean List Formatting
- Avoid `list-style: none` and fake `::before` pseudo-counters.
- Instead, use CSS logical margin and padding:
  ```css
  padding-inline-start: 1.75em !important;
  margin-inline-start: 0 !important;
  ```
  The browser's layout engine automatically places numbers and bullets on the correct side corresponding to the detected direction.

### 4.3. Artifacts & Markdown Alerts (`[!NOTE]`, `[!IMPORTANT]`, `[!TIP]`, `[!CAUTION]`)
- GitHub-style alert callouts use left borders by default (`border-left: 4px solid ...`).
- In RTL context, this must be switched to logical start borders:
  ```css
  border-left: none !important;
  border-inline-start: 4px solid var(--alert-color) !important;
  padding-inline-start: 1em !important;
  padding-inline-end: 0.5em !important;
  ```

### 4.4. Strict Code Containment
- All editor and code block elements are strictly anchored to LTR:
  ```css
  pre, pre code, .monaco-editor, .monaco-editor *, .view-lines, .code-snippet, .diff-container {
      direction: ltr !important;
      unicode-bidi: embed !important;
      text-align: left !important;
      font-family: var(--vscode-editor-font-family, monospace) !important;
  }
  ```

---

## 5. Directory Structure & Project Layout

```
antigravity-rtl-ultra/
├── KNOWLEDGE_BASE.md           # Comprehensive technical blueprint
├── README.md                   # Public GitHub documentation (Bilingual EN/AR)
├── LICENSE                     # MIT License
├── .gitignore                  # Git ignore rules
│
├── src/                        # Core CSS styles & build pipeline
│   ├── core.css                # Base bi-directional rules & code isolation
│   ├── chat.css                # AI Chat specific layout & list rules
│   ├── artifacts.css           # Artifacts & Markdown report viewer rules
│   └── bundle.css              # Combined, optimized production bundle
│
├── extension/                  # VS Code / Antigravity IDE Extension
│   ├── package.json            # Extension manifest & contributions
│   ├── extension.js            # Patcher lifecycle, auto-watch, checksum recalculator
│   └── icon.png                # High-res extension branding icon
│
└── cli/                        # Standalone 1-Click CLI Installers
    ├── install.ps1             # PowerShell installer for Windows
    ├── uninstall.ps1           # Safe rollback script for Windows
    └── install.sh              # Bash installer for macOS / Linux
```

---

## 6. Verification Test Cases

To guarantee 100% forensic integrity and zero layout regressions, the engine is tested against 5 critical test cases:

1. **Test Case 1 (Pure Arabic Paragraph):**
   * *Input:* نص تجريبي باللغة العربية مع علامات ترقيم: (نقطة، فاصلة، ونقطتان رئيستان).
   * *Expected:* Punctuation at the logical end (left side of the line), text right-aligned.

2. **Test Case 2 (Mixed Arabic + English File Path):**
   * *Input:* تم تعديل الملف `C:\Users\Admin\config.json` بنجاح بنسبة 100%.
   * *Expected:* Path string stays LTR, percentage stays next to 100%, period at the end.

3. **Test Case 3 (Mixed Numbered List):**
   * *Input:* 
     1. خادم `dart-mcp-server`: يعمل بشكل سليم.
     2. خادم `context`: تم تحديث المسار.
   * *Expected:* Numbers `1.` and `2.` on the right margin, colons immediately after the code tags without flipping.

4. **Test Case 4 (Artifact Report Preview):**
   * *Input:* Report with Arabic headers, English subheaders, and `[!IMPORTANT]` alert box.
   * *Expected:* Arabic text aligned right, English headers aligned left, alert indicator bar on the right margin for Arabic text.

5. **Test Case 5 (Monaco Editor & Code Block Immunity):**
   * *Input:* Multi-line Python/Dart code inside chat and artifacts.
   * *Expected:* Indentation, brackets, syntax highlighting remain strictly LTR and left-aligned.
