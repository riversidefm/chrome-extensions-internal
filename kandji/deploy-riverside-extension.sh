#!/bin/bash
#
# Riverside Chrome Extension - Enterprise Deployment
# Adds x-riverside-internal: true header to all requests
#
# Run as: root (via Kandji)
#

set -e

INSTALL_DIR="/Library/Application Support/Riverside/ChromeExtension"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/../extension"

echo "=== Riverside Chrome Extension Deployment ==="

# 1. Create installation directory
mkdir -p "$INSTALL_DIR/icons"

# 2. Copy extension files
cp -f "$SOURCE_DIR/manifest.json" "$INSTALL_DIR/"
cp -f "$SOURCE_DIR/rules.json" "$INSTALL_DIR/"
[ -d "$SOURCE_DIR/icons" ] && cp -f "$SOURCE_DIR/icons/"* "$INSTALL_DIR/icons/" 2>/dev/null || true

chmod -R 755 "$INSTALL_DIR"
chown -R root:wheel "$INSTALL_DIR"

echo "✓ Extension installed to $INSTALL_DIR"

# 3. Create Chrome policy to enable Developer Mode extensions enterprise-wide
# and set up the extension path
mkdir -p "/Library/Managed Preferences"
cat > "/Library/Managed Preferences/com.google.Chrome.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>DeveloperToolsAvailability</key>
    <integer>1</integer>
    <key>ExtensionAllowedTypes</key>
    <array>
        <string>extension</string>
    </array>
</dict>
</plist>
PLIST

chmod 644 "/Library/Managed Preferences/com.google.Chrome.plist"
chown root:wheel "/Library/Managed Preferences/com.google.Chrome.plist"

echo "✓ Chrome policy configured"

# 4. For each user with Chrome, set up auto-load via Preferences
for USERHOME in /Users/*; do
    [ ! -d "$USERHOME" ] && continue
    USERNAME=$(basename "$USERHOME")
    [[ "$USERNAME" == "Shared" || "$USERNAME" == "Guest" || "$USERNAME" == ".localized" ]] && continue
    
    CHROME_SUPPORT="$USERHOME/Library/Application Support/Google/Chrome"
    [ ! -d "$CHROME_SUPPORT" ] && continue
    
    # Find all Chrome profiles
    for PROFILE_DIR in "$CHROME_SUPPORT"/Default "$CHROME_SUPPORT"/Profile*; do
        [ ! -d "$PROFILE_DIR" ] && continue
        
        PREFS_FILE="$PROFILE_DIR/Preferences"
        [ ! -f "$PREFS_FILE" ] && continue
        
        # Check if extension is already in preferences
        if ! grep -q "lbbmjopnbmddljnhnffllbibbajlombd" "$PREFS_FILE" 2>/dev/null; then
            echo "  → User $USERNAME needs to load extension manually once"
        fi
    done
done

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Extension location: $INSTALL_DIR"
echo ""
echo "IMPORTANT: Users must load the extension ONCE manually:"
echo "  1. Open Chrome → chrome://extensions"
echo "  2. Enable 'Developer mode' (top right)"
echo "  3. Click 'Load unpacked'"
echo "  4. Select: $INSTALL_DIR"
echo ""
echo "After first load, the extension persists across Chrome restarts."

exit 0
