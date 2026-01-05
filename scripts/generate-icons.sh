#!/bin/bash
# Generate PNG icons from SVG for Chrome extension
# Requires: macOS with sips, or ImageMagick

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ICONS_DIR="$PROJECT_DIR/extension/icons"
SVG_FILE="$ICONS_DIR/icon.svg"

cd "$ICONS_DIR"

# Check if we have the tools we need
if command -v rsvg-convert &> /dev/null; then
    echo "Using rsvg-convert..."
    rsvg-convert -w 48 -h 48 "$SVG_FILE" -o icon-48.png
    rsvg-convert -w 128 -h 128 "$SVG_FILE" -o icon-128.png
elif command -v convert &> /dev/null; then
    echo "Using ImageMagick convert..."
    convert -background none -resize 48x48 "$SVG_FILE" icon-48.png
    convert -background none -resize 128x128 "$SVG_FILE" icon-128.png
elif command -v qlmanage &> /dev/null; then
    echo "Using macOS qlmanage (QuickLook)..."
    # Create a temporary HTML file to render SVG at specific sizes
    # This is a fallback for macOS without other tools
    
    # For 48x48
    qlmanage -t -s 48 -o . "$SVG_FILE" 2>/dev/null
    mv "icon.svg.png" icon-48.png 2>/dev/null || true
    
    # For 128x128  
    qlmanage -t -s 128 -o . "$SVG_FILE" 2>/dev/null
    mv "icon.svg.png" icon-128.png 2>/dev/null || true
else
    echo "No suitable image conversion tool found."
    echo "Please install one of:"
    echo "  - librsvg: brew install librsvg"
    echo "  - ImageMagick: brew install imagemagick"
    echo ""
    echo "Or manually convert $SVG_FILE to:"
    echo "  - icon-48.png (48x48 pixels)"
    echo "  - icon-128.png (128x128 pixels)"
    exit 1
fi

echo "Icons generated successfully:"
ls -la "$ICONS_DIR"/*.png 2>/dev/null || echo "Warning: PNG files may not have been created"


