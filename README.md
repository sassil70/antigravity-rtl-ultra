# Antigravity RTL Ultra 🚀

<div align="center">

**Universal Dual-Pane Right-to-Left (RTL) Engine for Antigravity IDE, Cursor & AI-Augmented IDEs**

*محرك توجيه النصوص ثنائي النطاق (محادثة الذكاء الاصطناعي + مستعرض التقارير والمستندات) للغة العربية واللغات المكتوبة من اليمين إلى اليسار*

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-brightgreen.svg)]()
[![IDE](https://img.shields.io/badge/IDE-Antigravity%20%7C%20Cursor%20%7C%20VS%20Code-purple.svg)]()

</div>

---

## 🌟 Overview / نظرة عامة

**Antigravity RTL Ultra** is the first comprehensive, architecturally sound RTL solution built specifically for AI-powered developer environments. Unlike previous superficial patches, it introduces a **Dual-Pane BiDi Engine** that seamlessly handles both **AI Chat Conversations** and **Artifacts / Reports Viewer panels** simultaneously without breaking code blocks, punctuation, or English text.

---

## ✨ Key Features / أهم المميزات

| Feature | Description |
| :--- | :--- |
| 🔄 **Dual-Pane Support** | First solution to support both the **AI Chat Pane** and the **Artifacts / Report Viewer Pane**. |
| 🛡️ **True BiDi Isolation** | Prevents punctuation inversion (`:`, `()`, `{}`) and stops inline code tokens (`` `file.js` ``) from jumping. |
| 📝 **Clean List Formatting** | Preserves native browser counters and bullets with proper logical indentation (`padding-inline-start`). |
| 🚨 **RTL Markdown Alerts** | Re-aligns GitHub-style callouts (`[!NOTE]`, `[!IMPORTANT]`, `[!TIP]`) to the right margin for RTL readers. |
| 🔒 **Code Containment** | Strict LTR quarantine for Monaco Editor, syntax highlighters, and multi-line code snippets. |
| ⚡ **1-Click 100% Safe Install** | Includes automatic backup (`.rtlbak`) and instant 1-click rollback support. |

---

## 🚀 Quick Start / التثبيت السريع

### Windows (PowerShell)
Run PowerShell as Administrator or regular user:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\cli\install.ps1
```

### macOS / Linux (Bash)
```bash
chmod +x ./cli/install.sh
./cli/install.sh
```

---

## 🔄 Rollback / إلغاء التثبيت والاستعادة
If you ever want to revert to original factory styles:
```powershell
.\cli\uninstall.ps1
```

---

## 🏗️ Technical Architecture / المعمارية الفنية

For full technical specifications, layout benchmarks, and comparative analysis with previous projects, please review [KNOWLEDGE_BASE.md](KNOWLEDGE_BASE.md).

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
