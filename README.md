# Antigravity RTL Ultra 🚀

<div align="center">

# محرك توجيه النصوص ثنائي النطاق للذكاء الاصطناعي والمستندات
### Universal Dual-Pane Right-to-Left (RTL) Engine for Antigravity Desktop, Antigravity IDE, Cursor & VS Code

[![GitHub Stars](https://img.shields.io/github/stars/sassil70/antigravity-rtl-ultra?style=for-the-badge&logo=github&color=gold)](https://github.com/sassil70/antigravity-rtl-ultra/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/sassil70/antigravity-rtl-ultra?style=for-the-badge&color=blue)](https://github.com/sassil70/antigravity-rtl-ultra/network/members)
[![Version](https://img.shields.io/badge/Version-2.0.0%20(Latest)-blue.svg?style=for-the-badge)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-brightgreen.svg?style=for-the-badge)]()
[![Supported Environments](https://img.shields.io/badge/Supported-Antigravity%202.x%20Desktop%20%7C%20IDE%20%7C%20Cursor%20%7C%20VS%20Code-purple.svg?style=for-the-badge)]()

<br/>

**[🇸🇦 العربية](#-نظرة-عامة--لماذا-antigravity-rtl-ultra) • [🆕 تحديث v2.0.0](#-تحديث-المعمارية-v200-لدعم-antigravity-212) • [🇬🇧 English](#-overview--why-antigravity-rtl-ultra) • [⚡ التثبيت السريع / Quick Install](#-تثبيت-سريع-بنقرة-واحدة--1-click-quick-install) • [🔄 التراجع والعودة / Safe Rollback](#-التراجع-والاستعادة-الآمنة-100--100-safe-rollback) • [⭐ ادعم المشروع / Support & Stars](#-ادعم-المشروع-وشارك-في-تمكين-المطور-العربي--support-the-community)**

</div>

---

## 🆕 تحديث المعمارية v2.0.0 لدعم Antigravity 2.12+ 

> [!IMPORTANT]
> **تحديث معماري ضخم (سبتمبر 2026):**
> أطلقت شركة Google تحديث Antigravity Desktop 2.12.0، وفيه تم تحويل بنية التطبيق من ملفات VS Code المفتوحة إلى **حزمة Electron ASAR مغلقة ومضغوطة** (`resources\app.asar`).
> 
> تم ترقية **Antigravity RTL Ultra** ليكون **محركاً شاملاً مزدوج الدعم (Universal Dual-Engine)**:
> 1. **المحرك الأول (Electron ASAR Injector):** يقوم بفك حزمة `app.asar` وحقن محرك الـ RTL Ultra ثنائي النطاق مباشرة داخل سكريبت الإقلاع `dist/preload.js` مع إعادة التجميع الذكية، وتطبيقها بنقرة واحدة عبر `apply-desktop.ps1`.
> 2. **المحرك الثاني (Classic CSS Patcher):** يواصل الدعم الكامل لملفات `workbench.desktop.main.css` لمحررات `Antigravity IDE` و `Cursor` و `Windsurf` و `VS Code`.

---

## 🌟 نظرة عامة / لماذا Antigravity RTL Ultra؟

هل عانيت يوماً عند التحدث باللغة العربية مع مساعدك الذكي في بيئة التطوير من انقلاب علامات الترقيم، أو قفز مسارات الملفات مثل `` `config.json` ``، أو تشوه القوائم النقطية، أو بقاء لوحة المستندات والتقارير (**Artifacts Viewer**) مشدودة ومحشورة في أقصى اليسار؟

مشروع **Antigravity RTL Ultra** جاء ليضع حداً نهائياً لهذه المشاكل عبر **محرك توجيه ذكي ثنائي النطاق (Dual-Pane BiDi Engine)**:
1. **لوحة المحادثة مع الذكاء الاصطناعي (AI Chat Pane):** قراءة عربية طبيعية وانسيابية مع ضبط تام للترقيم والقوائم.
2. **لوحة المستندات والتقارير والخطط (Artifacts / Reports Pane):** عرض كامل من اليمين لليسار يشمل العناوين، الجداول، وأشرطة التنبيهات (`[!IMPORTANT]`, `[!NOTE]`).
3. **حجر صحي صارم للأكواد (Code Containment):** بقاء محرر الأكواد Monaco Editor وكتل البرمجة بلغة `LTR` الأصلية دون أدنى تأثير.

---

## 🇬🇧 Overview / Why Antigravity RTL Ultra?

Have you ever struggled with broken Arabic / RTL formatting when collaborating with AI coding agents? Inverted punctuation, jumping inline code snippets, mangled lists, and left-clamped **Artifacts & Reports panels** ruin the developer experience.

**Antigravity RTL Ultra** is the first architecturally robust **Dual-Pane BiDi Engine** supporting both modern **Electron ASAR apps** (Antigravity 2.12+) and **VS Code forks** (Antigravity IDE, Cursor, Windsurf). It delivers seamless right-to-left layout for both chat conversations and markdown reports while strictly preserving code blocks and English text flow.

---

## ⚡ تثبيت سريع بنقرة واحدة / 1-Click Quick Install

### 1️⃣ لتطبيق الترقيع على تطبيق Antigravity Desktop (الإصدار 2.x الجديد):
افتح **PowerShell** ونفّذ سكريبت التفعيل السريع:
```powershell
powershell -ExecutionPolicy Bypass -File ".\cli\apply-desktop.ps1"
```
*(أو عبر الرابط المباشر من GitHub)*:
```powershell
irm https://raw.githubusercontent.com/sassil70/antigravity-rtl-ultra/main/cli/install.ps1 | iex
```

### 2️⃣ لتطبيق الترقيع على Antigravity IDE / Cursor / VS Code (محررات كود CSS):
```powershell
irm https://raw.githubusercontent.com/sassil70/antigravity-rtl-ultra/main/cli/install.ps1 | iex
```

### 🍎 macOS / 🐧 Linux (Terminal)
```bash
curl -fsSL https://raw.githubusercontent.com/sassil70/antigravity-rtl-ultra/main/cli/install.sh | bash
```

---

## 🔄 التراجع والاستعادة الآمنة 100% / 100% Safe Rollback

> 🛡️ **ضمان الأمان الكامل:** يقوم المثبّت تلقائياً بإنشاء نسخة احتياطية خام (`.rtlbak` للملفات و `app.asar.rtlbak` لتطبيق Electron) قبل لمس أي ملف. يمكنك التراجع واستعادة الوضع الأصلي للمصنع في أي لحظة بنقرة واحدة وبأمان تام!

### 🪟 Windows Rollback
```powershell
irm https://raw.githubusercontent.com/sassil70/antigravity-rtl-ultra/main/cli/uninstall.ps1 | iex
```

### 🍎 macOS / 🐧 Linux Rollback
```bash
curl -fsSL https://raw.githubusercontent.com/sassil70/antigravity-rtl-ultra/main/cli/uninstall.sh | bash
```

---

## ✨ أهم المميزات والحلول الهندسية / Key Architectural Features

| الميزة / Feature | الوصف الفني / Technical Detail | الفائدة / Benefit |
| :--- | :--- | :--- |
| ⚡ **دعم Antigravity 2.x ASAR** | حقن كود الـ BiDi في `preload.js` داخل حزم Electron المضغوطة. | التوافق التام مع التحديث الجديد للتطبيق المكتبي. |
| 🔄 **ثنائي النطاق (Dual-Pane)** | يدعم لوحة المحادثة + لوحة الـ Artifacts والتقارير المستقلة. | قراءة المستندات والخطط العربية بنفس جودة واجهة الشات. |
| 🛡️ **عزل حقيقي للأكواد (BiDi Isolation)** | استخدام `unicode-bidi: isolate` الصريح بدلاً من `inline-block`. | منع قفز النقطتين الرأسيتين والأقواس حول أسماء الملفات. |
| 📝 **قوائم نقطية ومرقمة متناسقة** | الاعتماد على الخصائص المنطقية `padding-inline-start`. | الحفاظ على ترقيم المتصفح الأصلي والمحاذاة السليمة. |
| 🚨 **تنبيهات GitHub منسقة** | توجيه أشرطة التنبيه (`[!NOTE]`, `[!TIP]`, `[!IMPORTANT]`). | ظهور خط التنبيه على الحافة اليمنى للنصوص العربية. |
| 🔒 **حجر صحي للأكواد (Monaco Editor)** | تثبيت اتجاه `direction: ltr` الصارم لكافة كتل الأكواد والـ Diff. | عدم تأثر محاذاة وتنسيق لغات البرمجة إطلاقاً. |

---

## ⭐ ادعم المشروع وشارك في تمكين المطور العربي / Support the Community

هذا المشروع مفتوح المصدر ومبني لخدمة مجتمع المطورين العرب والمستخدمين للغات الشرقية. دعمك للمشروع يساهم في إيصاله للجميع ويساعد في تطويره باستمرار:

1. ⭐ **أضف نجمة للمشروع (Give a Star):** اضغط على زر **Star** في أعلى صفحة المستودع لجمع النقاط وزيادة موثوقية وانتشار الأداة.
2. 📢 **شارك الأداة:** شارك رابط المستودع مع زملائك المطورين ومجتمعات التقنية وصناع المحتوى.
3. 💡 **ساهم معنا (Contribute & Fork):** نرحب بجميع المقترحات والمساهمات وفتح الـ Issues أو الـ Pull Requests.

<div align="center">

[![Star on GitHub](https://img.shields.io/badge/⭐%20Star%20on%20GitHub-Click%20Here-gold?style=for-the-badge&logo=github)](https://github.com/sassil70/antigravity-rtl-ultra)

**معاً لجعل بيئات البرمجة والذكاء الاصطناعي تدعم لغتنا العربية بأعلى جودة تليق بنا 🚀**

</div>

---

## 🏗️ سجل التغييرات والمعمارية / Documentation

- للاطلاع على سجل التغييرات التفصيلي للنسخة 2.0.0: [CHANGELOG.md](CHANGELOG.md)
- للاطلاع على التحليل الجنائي الشامل وحالات الاختبار المعيارية: [KNOWLEDGE_BASE.md](KNOWLEDGE_BASE.md)

---

## 📄 الترخيص / License

هذا المشروع منشور تحت ترخيص [MIT License](LICENSE).
