#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "   Antigravity RTL Ultra — 1-Click Installer (Unix)       "
echo "=========================================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE_PATH="${SCRIPT_DIR}/../src/styles/bundle.css"

if [ ! -f "$BUNDLE_PATH" ]; then
    echo "Error: bundle.css not found at $BUNDLE_PATH"
    exit 1
fi

PATCH_CSS=$(cat "$BUNDLE_PATH")
TARGETS=()

# macOS Paths
if [[ "$OSTYPE" == "darwin"* ]]; then
    TARGETS+=(
        "/Applications/Antigravity.app/Contents/Resources/app/out/vs/workbench/workbench.desktop.main.css"
        "/Applications/Cursor.app/Contents/Resources/app/out/vs/workbench/workbench.desktop.main.css"
        "/Applications/Visual Studio Code.app/Contents/Resources/app/out/vs/workbench/workbench.desktop.main.css"
        "$HOME/Applications/Antigravity.app/Contents/Resources/app/out/vs/workbench/workbench.desktop.main.css"
    )
fi

# Linux Paths
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    TARGETS+=(
        "/opt/antigravity/resources/app/out/vs/workbench/workbench.desktop.main.css"
        "/opt/cursor/resources/app/out/vs/workbench/workbench.desktop.main.css"
        "/usr/share/code/resources/app/out/vs/workbench/workbench.desktop.main.css"
    )
fi

for TARGET in "${TARGETS[@]}"; do
    if [ -f "$TARGET" ]; then
        echo "Found target: $TARGET"
        BACKUP="${TARGET}.rtlbak"
        if [ ! -f "$BACKUP" ]; then
            cp "$TARGET" "$BACKUP"
            echo "  [+] Backup created at $BACKUP"
        fi

        # Remove existing patch if present
        sed -i.tmp '/\/\* RTL-PATCH-START \*\//,/\/\* RTL-PATCH-END \*\//d' "$TARGET" 2>/dev/null || true
        rm -f "${TARGET}.tmp"

        # Append new patch
        echo "" >> "$TARGET"
        echo "$PATCH_CSS" >> "$TARGET"
        echo "  [✓] Antigravity RTL Ultra applied successfully!"
    fi
done

echo "=========================================================="
echo " Installation Complete! Please restart Antigravity IDE.   "
echo "=========================================================="
