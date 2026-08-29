const vscode = require('vscode');
const fs = require('fs');
const path = require('path');
const os = require('os');
const crypto = require('crypto');

const BACKUP_EXT = '.rtlbak';
const CSS_MARKER_START = '/* RTL-PATCH-START */';
const CSS_MARKER_END = '/* RTL-PATCH-END */';

let statusBarItem;

// ── Known IDE names for path resolution ─────────────────────────────
const KNOWN_IDE_NAMES = [
    'Antigravity IDE',
    'Antigravity',
    'Cursor',
    'Windsurf',
    'Code',
    'Code - Insiders',
    'VSCodium',
    'Positron'
];

function getBundleCss() {
    const bundlePath = path.join(__dirname, '..', 'src', 'styles', 'bundle.css');
    if (fs.existsSync(bundlePath)) {
        return fs.readFileSync(bundlePath, 'utf8');
    }
    // Fallback embedded bundle
    return `
/* RTL-PATCH-START */
p,li,h1,h2,h3,h4,h5,h6,td,th{unicode-bidi:plaintext!important;text-align:start!important}
:not(pre)>code{unicode-bidi:isolate!important;direction:ltr!important;display:inline!important}
pre,pre code,pre *,.monaco-editor,.view-lines{direction:ltr!important;unicode-bidi:embed!important;text-align:left!important}
.rendered-markdown,.artifact-content,[class*="artifact"]{unicode-bidi:plaintext!important;text-align:start!important}
.markdown-alert,[class*="alert-"]{border-left:none!important;border-right:none!important;border-inline-start:4px solid currentColor!important;padding-inline-start:1em!important}
/* RTL-PATCH-END */
    `.trim();
}

function getTargetFiles() {
    const targets = [];
    const home = os.homedir();
    const localAppData = process.env.LOCALAPPDATA || path.join(home, 'AppData', 'Local');
    const potentialPaths = [];

    if (vscode.env.appRoot) {
        potentialPaths.push(path.join(vscode.env.appRoot, 'out', 'vs', 'workbench', 'workbench.desktop.main.css'));
    }

    if (process.execPath) {
        const execDir = path.dirname(process.execPath);
        potentialPaths.push(path.join(execDir, 'resources', 'app', 'out', 'vs', 'workbench', 'workbench.desktop.main.css'));
        potentialPaths.push(path.join(execDir, '..', 'Resources', 'app', 'out', 'vs', 'workbench', 'workbench.desktop.main.css'));
    }

    for (const name of KNOWN_IDE_NAMES) {
        potentialPaths.push(path.join(localAppData, 'Programs', name, 'resources', 'app', 'out', 'vs', 'workbench', 'workbench.desktop.main.css'));
        potentialPaths.push(`/Applications/${name}.app/Contents/Resources/app/out/vs/workbench/workbench.desktop.main.css`);
        potentialPaths.push(`/opt/${name.toLowerCase()}/resources/app/out/vs/workbench/workbench.desktop.main.css`);
        potentialPaths.push(`/usr/share/${name.toLowerCase()}/resources/app/out/vs/workbench/workbench.desktop.main.css`);
    }

    const uniquePaths = [...new Set(potentialPaths.map(p => path.normalize(p)))];
    for (const p of uniquePaths) {
        if (fs.existsSync(p)) {
            targets.push(p);
        }
    }
    return targets;
}

function isPatched(filePath) {
    try {
        const content = fs.readFileSync(filePath, 'utf8');
        return content.includes(CSS_MARKER_START);
    } catch {
        return false;
    }
}

function backup(filePath) {
    const backupPath = filePath + BACKUP_EXT;
    if (!fs.existsSync(backupPath)) {
        fs.copyFileSync(filePath, backupPath);
    }
}

function updateChecksum(filePath, content) {
    const appDir = path.dirname(path.dirname(path.dirname(path.dirname(filePath))));
    const productJsonPath = path.join(appDir, 'product.json');
    if (!fs.existsSync(productJsonPath)) return;

    try {
        const productJson = JSON.parse(fs.readFileSync(productJsonPath, 'utf8'));
        if (!productJson.checksums) return;

        const hash = crypto.createHash('sha256').update(content).digest('base64').replace(/=/g, '');
        productJson.checksums['vs/workbench/workbench.desktop.main.css'] = hash;
        fs.writeFileSync(productJsonPath, JSON.stringify(productJson, null, '\t'), 'utf8');
    } catch (e) {
        console.warn('Failed to update product.json checksum:', e);
    }
}

function applyPatch() {
    const targets = getTargetFiles();
    if (targets.length === 0) {
        vscode.window.showErrorMessage('Antigravity RTL Ultra: No target files found.');
        return;
    }

    const patchBlock = getBundleCss();
    let appliedCount = 0;

    for (const target of targets) {
        try {
            backup(target);
            let content = fs.readFileSync(target, 'utf8');

            if (content.includes(CSS_MARKER_START)) {
                const startIdx = content.indexOf(CSS_MARKER_START);
                const endIdx = content.indexOf(CSS_MARKER_END) + CSS_MARKER_END.length;
                content = content.substring(0, startIdx) + content.substring(endIdx);
            }

            const newContent = content.trimEnd() + '\n\n' + patchBlock + '\n';
            fs.writeFileSync(target, newContent, 'utf8');
            updateChecksum(target, newContent);
            appliedCount++;
        } catch (err) {
            vscode.window.showErrorMessage(`Antigravity RTL Ultra failed on ${path.basename(target)}: ${err.message}`);
        }
    }

    if (appliedCount > 0) {
        updateStatusBar(true);
        vscode.window.showInformationMessage(
            `Antigravity RTL Ultra applied successfully (${appliedCount} file(s)). Please reload the window.`,
            'Reload Window'
        ).then(sel => {
            if (sel === 'Reload Window') {
                vscode.commands.executeCommand('workbench.action.reloadWindow');
            }
        });
    }
}

function restoreBackup() {
    const targets = getTargetFiles();
    let restoredCount = 0;

    for (const target of targets) {
        const backupPath = target + BACKUP_EXT;
        if (fs.existsSync(backupPath)) {
            const content = fs.readFileSync(backupPath, 'utf8');
            fs.writeFileSync(target, content, 'utf8');
            updateChecksum(target, content);
            restoredCount++;
        }
    }

    updateStatusBar(false);
    if (restoredCount > 0) {
        vscode.window.showInformationMessage('Antigravity RTL Ultra: Restored original files. Please reload.', 'Reload Window')
            .then(sel => {
                if (sel === 'Reload Window') {
                    vscode.commands.executeCommand('workbench.action.reloadWindow');
                }
            });
    }
}

function updateStatusBar(isActive) {
    if (!statusBarItem) return;
    if (isActive) {
        statusBarItem.text = '$(check) RTL Ultra: Active';
        statusBarItem.tooltip = 'Antigravity RTL Ultra Dual-Pane Engine is active. Click to toggle.';
        statusBarItem.color = '#50fa7b';
    } else {
        statusBarItem.text = '$(x) RTL Ultra: Inactive';
        statusBarItem.tooltip = 'Antigravity RTL Ultra is inactive. Click to toggle.';
        statusBarItem.color = undefined;
    }
    statusBarItem.command = 'antigravityRtlUltra.toggle';
    statusBarItem.show();
}

function activate(context) {
    context.subscriptions.push(
        vscode.commands.registerCommand('antigravityRtlUltra.enable', applyPatch),
        vscode.commands.registerCommand('antigravityRtlUltra.disable', restoreBackup),
        vscode.commands.registerCommand('antigravityRtlUltra.toggle', () => {
            const targets = getTargetFiles();
            const anyPatched = targets.some(t => isPatched(t));
            if (anyPatched) restoreBackup();
            else applyPatch();
        })
    );

    statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 100);
    context.subscriptions.push(statusBarItem);

    const targets = getTargetFiles();
    const anyPatched = targets.some(t => isPatched(t));
    updateStatusBar(anyPatched);

    const autoEnable = vscode.workspace.getConfiguration('antigravityRtlUltra').get('autoEnable', true);
    if (!anyPatched && autoEnable) {
        applyPatch();
    }
}

function deactivate() {
    if (statusBarItem) statusBarItem.dispose();
}

module.exports = { activate, deactivate };
