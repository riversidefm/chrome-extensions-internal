#!/bin/bash
#
# Pack the Riverside extension as a .crx file
# This creates a signed .crx that can be force-installed via policy
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
EXTENSION_DIR="$PROJECT_DIR/extension"
DIST_DIR="$PROJECT_DIR/dist"
KEY_FILE="$PROJECT_DIR/extension.pem"

echo "Packing Riverside Chrome Extension"
echo "==================================="

# Create dist directory
mkdir -p "$DIST_DIR"

# Check if Chrome is available
CHROME_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
if [ ! -x "$CHROME_PATH" ]; then
    echo "ERROR: Google Chrome not found at $CHROME_PATH"
    exit 1
fi

# Pack the extension
# If a key exists, use it for consistent extension ID
# Otherwise Chrome will generate a new key
if [ -f "$KEY_FILE" ]; then
    echo "Using existing key: $KEY_FILE"
    "$CHROME_PATH" --pack-extension="$EXTENSION_DIR" --pack-extension-key="$KEY_FILE" --no-message-box 2>/dev/null || true
else
    echo "Generating new key..."
    "$CHROME_PATH" --pack-extension="$EXTENSION_DIR" --no-message-box 2>/dev/null || true
fi

# Chrome creates the .crx next to the extension directory
CRX_FILE="$PROJECT_DIR/extension.crx"
NEW_KEY_FILE="$PROJECT_DIR/extension.pem"

if [ -f "$CRX_FILE" ]; then
    mv "$CRX_FILE" "$DIST_DIR/riverside-internal-header.crx"
    echo "✓ Created: $DIST_DIR/riverside-internal-header.crx"
else
    echo "ERROR: Failed to create .crx file"
    echo "You may need to pack manually:"
    echo "1. Open Chrome"
    echo "2. Go to chrome://extensions"
    echo "3. Enable Developer mode"
    echo "4. Click 'Pack extension'"
    echo "5. Select: $EXTENSION_DIR"
    exit 1
fi

if [ -f "$NEW_KEY_FILE" ] && [ ! -f "$KEY_FILE" ]; then
    echo "✓ Key saved: $NEW_KEY_FILE"
    echo "  Keep this key safe - it's needed for updates!"
fi

# Get the extension ID from the .crx
# The extension ID is derived from the public key
echo ""
echo "Extension packed successfully!"
echo "Next steps:"
echo "1. Run the deployment script to install locally"
echo "2. Or upload the .crx and updates.xml to a web server"

exit 0

