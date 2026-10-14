# Antigravity RTL Ultra 🚀 (v2.1)

<div align="center">

# المحرك الذكي الشامل لدعم اللغة العربية ومنع انقلاب الجمل في Antigravity 2.23+
### Universal Zero-Downtime Right-to-Left (RTL) & UAX #9 BiDi Isolation Engine for Antigravity Desktop 2.x, Antigravity IDE, Cursor, Windsurf & VS Code

[![GitHub Stars](https://img.shields.io/github/stars/sassil70/antigravity-rtl-ultra?style=for-the-badge&logo=github&color=gold)](https://github.com/sassil70/antigravity-rtl-ultra/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/sassil70/antigravity-rtl-ultra?style=for-the-badge&color=blue)](https://github.com/sassil70/antigravity-rtl-ultra/network/members)
[![Version](https://img.shields.io/badge/Version-2.1.0%20(Jetbox%20Ready)-blue.svg?style=for-the-badge)](CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-brightgreen.svg?style=for-the-badge)]()
[![Zero Downtime](https://img.shields.io/badge/Live%20Patch-Zero%20Restart%20Needed-orange.svg?style=for-the-badge)]()

<br/>

**[⚡ تثبيت بأمر واحد / 1-Command Install](#-تثبيت-فوري-بأمر-واحد-بدون-إغلاق-البرنامج--1-command-live-install) • [🔄 التراجع الآمن / 1-Click Rollback](#-التراجع-والاستعادة-الآمنة-100--100-safe-rollback) • [🆕 ما الجديد في v2.1؟](#-تحديث-v210-الحل-الجذري-لانقلاب-الكلمات-الإنجليزية-في-antigravity-223) • [🇬🇧 English](#-english-overview--architecture) • [⭐ ادعم المشروع بنجمة / Give a Star](#-ادعم-المشروع-بإضافة-نجمة-star--support-the-community)**

</div>

---

## ⚡ تثبيت فوري بأمر واحد (بدون إغلاق البرنامج!) / 1-Command Live Install

> [!TIP]
> **تفعيل لحظي مباشر (Live Hot-Injection) بدون أي تخريب أو إغلاق للبرنامج:**
> يعمل هذا الأمر الواحد مباشرةً حتى أثناء فتح برنامج **Antigravity**؛ حيث يأخذ نسخة احتياطية خام (`app.asar.rtlbak`)، ويحقن المحرك الذكي بأمان تام بدون الحاجة لـ `npx` أو أي مكتبات خارجية، **ويُفعّل إصلاح اللغة العربية فوراً أمام عينيك على النافذة المفتوحة في أجزاء من الثانية دون الحاجة لإعادة تشغيل البرنامج!**

### 🪟 Windows (PowerShell — أمر واحد فقط / Single Command)
انسخ هذا الأمر والصقه في **PowerShell** ثم اضغط `Enter`:
```powershell
irm https://raw.githubusercontent.com/sassil70/antigravity-rtl-ultra/main/cli/install.ps1 | iex
```

### 🍎 macOS / 🐧 Linux (Terminal — أمر واحد فقط / Single Command)
```bash
curl -fsSL https://raw.githubusercontent.com/sassil70/antigravity-rtl-ultra/main/cli/install.sh | bash
```

---

## 🔄 التراجع والاستعادة الآمنة 100% / 100% Safe Rollback

> [!IMPORTANT]
> **أمان مطلق 100% (Zero-Risk Guarantee):**
> قبل تعديل أي بايت واحد، ينشئ السكريبت تلقائياً نسخة احتياطية مطابقة للأصل (`app.asar.rtlbak` و `.rtlbak`). يمكنك في أي لحظة إلغاء التعديل واستعادة ملفات المصنع الأصلية 100% فوراً وبأمر واحد فقط (حتى بدون إغلاق البرنامج!):

### 🪟 Windows Rollback (أمر التراجع الفوري)
```powershell
irm https://raw.githubusercontent.com/sassil70/antigravity-rtl-ultra/main/cli/uninstall.ps1 | iex
```

### 🍎 macOS / 🐧 Linux Rollback
```bash
curl -fsSL https://raw.githubusercontent.com/sassil70/antigravity-rtl-ultra/main/cli/uninstall.sh | bash
```

---

## 🆕 تحديث v2.1.0: الحل الجذري لانقلاب الكلمات الإنجليزية في Antigravity 2.23+

### 🔍 لماذا كانت الجملة العربية تنقلب عند ورود كلمة إنجليزية مثل `github` أو `Bug`؟
في التحديثات الأخيرة لبرنامج **Antigravity 2.x (معمارية Jetbox)**، يقوم مكون عرض ردود الذكاء الاصطناعي (`CustomMarkdown`) بتوليد الفقرات `<p>` والقوائم `<li>` والعناوين `<h1>-<h6>` باتجاه أساسي من اليسار لليمين (`LTR - Level 0`) مع تقطيع كل كلمة داخل `<span>` مستقل.
بموجب **خوارزمية اليونيكود ثنائية الاتجاه (UAX #9)**:
- ما دامت الجملة عربية خالصة، تتماسك في جزيرة واحدة (`Level 1`).
- **بمجرد دخول كلمة إنجليزية واحدة** (مثل `github`، `Bug`، `README.md`، `Eng. Saleem Asseel`)، تهبط الكلمة الإنجليزية إلى المستوى الأساسي للفقرة (`Level 0 - LTR`) وتقسم الجملة العربية إلى شطرين، فيقوم المتصفح بترتيب الشطرين **من اليسار إلى اليمين** (فتنقلب بداية الجملة إلى آخرها، وتنعكس الأقواس `(في مسار الويندوز (Bug` وتقفز النقطتان `:` إلى الطرف المعاكس!).

### 🛡️ كيف يعالج Antigravity RTL Ultra v2.1 هذه المشكلة جذرياً؟
1. **الرصد الذكي للنصوص العربية (Smart DOM BiDi Observer):**
   مراقب `MutationObserver` فائق الخفة يفحص الفقرات وعناصر القوائم والعناوين لحظياً أثناء تدفق رد الذكاء الاصطناعي (Streaming)؛ فإذا اكتشف حروفاً عربية، يضبط هوية العنصر الأساسية على `dir="rtl"` مع `unicode-bidi: normal !important` (مما يمنع حتى فواصل الأسطر `<br>` من قلب السطر التالي إذا بدأ بكلمة إنجليزية!).
2. **عزل الجزر الإنجليزية والأكواد المضمنة (Strict UAX #9 Isolation):**
   تطبيق `unicode-bidi: isolate !important; direction: ltr !important;` على كافة الأكواد المضمنة `<code>`، وأزرار الإشارة للملفات `.context-scope-mention` و `.inline-pill`، والروابط الإنجليزية `a.text-link`، بحيث تستقر الكلمة الإنجليزية في موضعها الطبيعي داخل الجملة العربية دون أن تؤثر على الأقواس `()` أو النقطتين `:` المجاورة لها.
3. **حجر صحي صارم لكتل الأكواد (Jetbox & Monaco Code Quarantine):**
   عزل تام لكلاسات الكود في النسخة الجديدة (`.code-block`, `.code-line`, `.line-content`, `pre`, `.monaco-editor`, `.terminal`) لتبقى دائماً من اليسار لليمين (`LTR`) بنسبة 100%.
4. **حقن ثنائي بدون توقف (In-Place Native .NET ASAR Patcher + CDP Hot-Inject):**
   لا يحتاج إلى `npx` أو `node` أو فك ضغط آلاف الملفات، ولا يغلق جلسات عملك المفتوحة!

---

## 🇬🇧 English Overview & Architecture

### Why do English words (`github`, `Bug`, `README.md`) scramble Arabic sentences in Antigravity 2.x?
In **Antigravity 2.x (Jetbox architecture)**, while the user input box uses Meta's **Lexical** editor (which automatically sets `dir="rtl"`), the AI response renderer (`CustomMarkdown`) renders `<p>`, `<li>`, and `<h1>–<h6>` elements without a `dir` attribute—inheriting `<html lang="en">` (`direction: ltr`, Embedding Level 0)—and splits words into animated `<span>` elements.
Under the **Unicode Bidirectional Algorithm (UAX #9)**:
- Any English word (`L`) inside an `LTR` paragraph drops to **Level 0**, splitting the Arabic sentence (`Level 1`) into separate islands that get ordered **left-to-right** (Rule L2), while paired brackets `(Bug ...)` and trailing colons `:` resolve to `LTR` (Rules N0b, N1, N2) and flip across the line.
- Furthermore, pure `unicode-bidi: plaintext` resets directionality after forced line breaks (`<br>`), breaking lines that start with inline code or English names.

### How Antigravity RTL Ultra v2.1 Solves It
- **Hybrid CSS + Smart DOM BiDi Observer:** Detects Arabic Unicode ranges (`U+0600..U+06FF`, etc.) on block elements and sets `dir="rtl"` with `unicode-bidi: normal !important`, keeping pure English paragraphs and UI headers (`h2.select-none`) 100% `LTR`.
- **Inline Token Isolation:** Wraps `:not(pre) > code`, `.context-scope-mention`, `.inline-pill`, and URLs in `unicode-bidi: isolate !important; direction: ltr !important;`.
- **Zero-Downtime Binary ASAR Patcher & Live CDP Injection:** Appends the patched `dist/preload.js` to `resources/app.asar` in-place (<50ms, preserving all existing byte offsets and updating the SHA-256 integrity hash) and hot-injects the engine into running windows via `DevToolsActivePort`.

---

## ✨ مقارنة المميزات الهندسية / Architectural Comparison

| الميزة / Feature | بدون الأداة / Default Antigravity 2.x | مع Antigravity RTL Ultra v2.1 |
| :--- | :--- | :--- |
| **كلمات إنجليزية وسط العربي (`github`, `Bug`)** | ❌ تشطر الجملة العربية وتعكس ترتيب شطريها | ✅ تستقر في مكانها الطبيعي من اليمين لليسار |
| **الأقواس وعلامات الترقيم `(Bug ...):`** | ❌ تنقلب الأقواس وتقفز النقطتان `:` لأقصى اليمين | ✅ أقواس ونقطتان متماسكة 100% في موضعها |
| **أزرار الملفات المضمنة (`.context-scope-mention`)** | ❌ تبعثر الكلمات العربية المجاورة لها | ✅ معزولة بـ `unicode-bidi: isolate` بتناسق تام |
| **الأسطر بعد `<br>` التي تبدأ بكود إنجليزي** | ❌ تنقلب إلى `LTR` حتى مع `plaintext` | ✅ تبقى `RTL` بفضل الهوية الصريحة `dir="rtl"` |
| **كتل الأكواد والمحرر (`.code-block`, `pre`)** | ✅ `LTR` | ✅ محمية بحجر صحي صارم `LTR` 100% |
| **طريقة التثبيت والتراجع** | — | ⚡ أمر واحد فوري بدون إغلاق البرنامج + تراجع آمن 100% |

---

## ⭐ ادعم المشروع بإضافة نجمة (Star) / Support the Community

تم تطوير هذا المشروع بهندسة دقيقة لخدمة مجتمع المطورين العرب ومستخدمي اللغات الشرقية حول العالم.
**إذا أفادتك هذه الأداة وأراحتك من تشوه النصوص العربية في Antigravity و VS Code و Cursor:**

1. ⭐ **اضغط على زر النجمة (Star) في أعلى مستودع GitHub الآن!** كل نجمة ترفع تصنيف المشروع وتساعد آلاف المطورين العرب في الوصول إليه.
2. 📢 **شارك الأمر الواحد مع زملائك:** انسخ أمر التثبيت وشاركه في مجموعات البرمجة ومجتمعات الذكاء الاصطناعي.
3. 🍴 **ساهم معنا (Fork & PR):** نرحب بتجربتك وملاحظاتك ومشاركتك في تطوير الأداة.

<div align="center">

### 👇 اضغط هنا لمنح المشروع نجمة ⭐ على GitHub 👇
[![Star on GitHub](https://img.shields.io/badge/⭐%20Give%20a%20Star%20on%20GitHub-Click%20Here!-gold?style=for-the-badge&logo=github)](https://github.com/sassil70/antigravity-rtl-ultra)

**معاً لبيئة برمجة وذكاء اصطناعي تدعم لغتنا العربية بأعلى معايير الدقة العالمية 🚀**

</div>

---

## 🏗️ الوثائق وسجل التغييرات / Documentation

- سجل الإصدارات والتحديثات المعمارية: [CHANGELOG.md](CHANGELOG.md)
- القاعدة المعرفية والتحليل الجنائي للـ BiDi: [KNOWLEDGE_BASE.md](KNOWLEDGE_BASE.md)
- الرخصة القانونية: [MIT License](LICENSE) — **Eng. Saleem Asseel**
