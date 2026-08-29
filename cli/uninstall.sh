#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "   Antigravity RTL Ultra -- Safe Rollback (Unix)          "
echo "=========================================================="

TARGETS=()

# macOS Paths
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

# Linux Paths
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

FOUND=0

for TARGET in "${TARGETS[@]}"; do
    BACKUP="${TARGET}.rtlbak"
    if [ -f "$BACKUP" ]; then
        FOUND=1
        echo "Restoring from backup: $BACKUP"
        cp "$BACKUP" "$TARGET"
        rm -f "$BACKUP"
        echo "  [OK] Restored original file."
    elif [ -f "$TARGET" ]; then
        FOUND=1
        echo "Surgically stripping RTL patch from: $TARGET"
        sed -i.tmp '/\/\* RTL-PATCH-START \*\//,/\/\* RTL-PATCH-END \*\//d' "$TARGET" 2>/dev/null || true
        rm -f "${TARGET}.tmp"
        echo "  [OK] Stripped patch."
    fi
done

if [ $FOUND -eq 1 ]; then
    echo "=========================================================="
    echo " Rollback Complete! Please restart your IDE.             "
    echo "=========================================================="
else
    echo "No target installations found."
fi