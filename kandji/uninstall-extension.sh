#!/bin/bash
#
# Kandji Uninstall Script: Riverside Internal Header Chrome Extension
#
# This script removes the Chrome extension from the Mac.
# Deploy via Kandji as a Custom Script (run as root) when you need to remove the extension.
#

set -e

# Configuration - must match deploy script
INSTALL_DIR="/Library/Application Support/Riverside/ChromeExtension"
CHROME_EXT_DIR="/Library/Google/Chrome/External Extensions"
MANAGED_PREFS_DIR="/Library/Managed Preferences"
EXTENSION_ID="ogklcjlchkdlpkociihncogjfifbmhgn"
CHROME_PLIST="$MANAGED_PREFS_DIR/com.google.Chrome.plist"

echo "=== Riverside Chrome Extension Uninstall ==="

# Remove extension files
if [[ -d "$INSTALL_DIR" ]]; then
    rm -rf "$INSTALL_DIR"
    echo "Removed: $INSTALL_DIR"
fi

# Remove parent directory if empty
PARENT_DIR="/Library/Application Support/Riverside"
if [[ -d "$PARENT_DIR" ]] && [[ -z "$(ls -A "$PARENT_DIR")" ]]; then
    rmdir "$PARENT_DIR"
    echo "Removed empty directory: $PARENT_DIR"
fi

# Remove external extension JSON
if [[ -f "$CHROME_EXT_DIR/${EXTENSION_ID}.json" ]]; then
    rm -f "$CHROME_EXT_DIR/${EXTENSION_ID}.json"
    echo "Removed: $CHROME_EXT_DIR/${EXTENSION_ID}.json"
fi

# Remove Chrome managed preferences (only if we created it)
# Be careful not to remove other Chrome policies
if [[ -f "$CHROME_PLIST" ]]; then
    # Check if this plist only contains our extension policies
    # If it has other keys, just remove our specific entries
    PLIST_KEYS=$(defaults read "$CHROME_PLIST" 2>/dev/null | grep -c "=" || echo "0")
    
    if [[ "$PLIST_KEYS" -le 3 ]]; then
        # Only our 3 keys, safe to remove the whole file
        rm -f "$CHROME_PLIST"
        echo "Removed: $CHROME_PLIST"
    else
        # Other policies exist, just remove our entries
        defaults delete "$CHROME_PLIST" ExtensionInstallAllowlist 2>/dev/null || true
        defaults delete "$CHROME_PLIST" ExtensionInstallForcelist 2>/dev/null || true
        defaults delete "$CHROME_PLIST" ExtensionInstallSources 2>/dev/null || true
        echo "Removed extension entries from: $CHROME_PLIST"
    fi
fi

echo ""
echo "=== Uninstall Complete ==="
echo "Note: Users need to restart Chrome for the extension to be removed."

exit 0
