#!/bin/bash
#
# Riverside ModHeader Uninstall Script
# Removes Chrome managed policies for ModHeader
#
# Run as: root (via Kandji Custom Script)
#

set -e

CHROME_PLIST="/Library/Managed Preferences/com.google.Chrome.plist"

echo "Riverside ModHeader Uninstall"
echo "============================="

if [ -f "$CHROME_PLIST" ]; then
    rm -f "$CHROME_PLIST"
    echo "✓ Removed Chrome managed preferences"
else
    echo "✓ Chrome managed preferences file not found (already removed)"
fi

echo "✓ ModHeader will be uninstalled on next Chrome restart"
echo "  (Users may need to manually remove if they want it gone immediately)"

exit 0


