#!/bin/bash
#
# Package Chrome Extension for Deployment
#
# This script creates a .crx file from the extension source.
# The .crx file can be hosted on an HTTPS server for MDM deployment.
#
# Usage: ./package-extension.sh [--key path/to/key.pem]
#
# If no key is provided, a new one will be generated.
# IMPORTANT: Keep the .pem key file safe - you need the same key for updates!

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
EXTENSION_DIR="$PROJECT_DIR/extension"
OUTPUT_DIR="$PROJECT_DIR/dist"
KEY_FILE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --key)
            KEY_FILE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Check if Chrome is available for packaging
CHROME_PATH=""
if [[ -d "/Applications/Google Chrome.app" ]]; then
    CHROME_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
elif [[ -d "/Applications/Chromium.app" ]]; then
    CHROME_PATH="/Applications/Chromium.app/Contents/MacOS/Chromium"
fi

echo "=== Riverside Internal Header Extension Packager ==="
echo ""

# Verify extension files exist
if [[ ! -f "$EXTENSION_DIR/manifest.json" ]]; then
    echo "ERROR: manifest.json not found in $EXTENSION_DIR"
    exit 1
fi

if [[ ! -f "$EXTENSION_DIR/icons/icon-48.png" ]] || [[ ! -f "$EXTENSION_DIR/icons/icon-128.png" ]]; then
    echo "WARNING: Icon files missing. Run scripts/generate-icons.sh first."
fi

# Method 1: Use Chrome to package (creates signed .crx)
if [[ -n "$CHROME_PATH" ]] && [[ -x "$CHROME_PATH" ]]; then
    echo "Using Chrome to package extension..."
    
    if [[ -n "$KEY_FILE" ]] && [[ -f "$KEY_FILE" ]]; then
        "$CHROME_PATH" --pack-extension="$EXTENSION_DIR" --pack-extension-key="$KEY_FILE"
    else
        "$CHROME_PATH" --pack-extension="$EXTENSION_DIR"
        echo ""
        echo "IMPORTANT: A new key file was created at $EXTENSION_DIR.pem"
        echo "Keep this file safe - you need it for future updates!"
        KEY_FILE="$EXTENSION_DIR.pem"
    fi
    
    # Move output files to dist directory
    if [[ -f "$EXTENSION_DIR.crx" ]]; then
        mv "$EXTENSION_DIR.crx" "$OUTPUT_DIR/riverside-internal-header.crx"
        echo "Created: $OUTPUT_DIR/riverside-internal-header.crx"
    fi
    
    if [[ -f "$EXTENSION_DIR.pem" ]]; then
        mv "$EXTENSION_DIR.pem" "$OUTPUT_DIR/extension-key.pem"
        echo "Key saved: $OUTPUT_DIR/extension-key.pem"
    fi
else
    # Method 2: Create a ZIP file (for manual loading or Web Store upload)
    echo "Chrome not found. Creating ZIP package instead..."
    echo "(You can load this as an unpacked extension or upload to Chrome Web Store)"
    
    cd "$EXTENSION_DIR"
    zip -r "$OUTPUT_DIR/riverside-internal-header.zip" . -x "*.DS_Store" -x "*.svg"
    echo "Created: $OUTPUT_DIR/riverside-internal-header.zip"
fi

echo ""
echo "=== Packaging Complete ==="
echo ""
echo "Next steps:"
echo "1. Get the extension ID by loading it in Chrome (chrome://extensions, Developer mode)"
echo "2. Update kandji/chrome-policy.mobileconfig with the extension ID"
echo "3. Update kandji/updates.xml with the extension ID and hosting URL"
echo "4. Host the .crx file and updates.xml on an HTTPS server"
echo "5. Deploy the mobileconfig via Kandji"


