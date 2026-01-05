#!/bin/bash
#
# Riverside ModHeader Deployment Script
# Deploys Chrome managed policies to force-install ModHeader and configure it
# with the x-riverside-internal: true header
#
# Run as: root (via Kandji Custom Script)
#

set -e

MANAGED_PREFS_DIR="/Library/Managed Preferences"
CHROME_PLIST="$MANAGED_PREFS_DIR/com.google.Chrome.plist"

echo "Riverside ModHeader Deployment"
echo "=============================="

# Create managed preferences directory if it doesn't exist
mkdir -p "$MANAGED_PREFS_DIR"

# Write Chrome managed policy
cat > "$CHROME_PLIST" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>ExtensionInstallForcelist</key>
    <array>
        <string>idgpnmonknjnojddfkpgkljpfnnfcklj;https://clients2.google.com/service/update2/crx</string>
    </array>
    <key>ExtensionSettings</key>
    <dict>
        <key>idgpnmonknjnojddfkpgkljpfnnfcklj</key>
        <dict>
            <key>installation_mode</key>
            <string>force_installed</string>
            <key>update_url</key>
            <string>https://clients2.google.com/service/update2/crx</string>
            <key>toolbar_pin</key>
            <string>force_pinned</string>
        </dict>
    </dict>
    <key>3rdparty</key>
    <dict>
        <key>extensions</key>
        <dict>
            <key>idgpnmonknjnojddfkpgkljpfnnfcklj</key>
            <dict>
                <key>profiles</key>
                <array>
                    <dict>
                        <key>title</key>
                        <string>Riverside Internal</string>
                        <key>hideComment</key>
                        <true/>
                        <key>headers</key>
                        <array>
                            <dict>
                                <key>enabled</key>
                                <true/>
                                <key>name</key>
                                <string>x-riverside-internal</string>
                                <key>value</key>
                                <string>true</string>
                            </dict>
                        </array>
                        <key>respHeaders</key>
                        <array/>
                        <key>filters</key>
                        <array/>
                        <key>appendMode</key>
                        <false/>
                        <key>sendEmptyHeader</key>
                        <false/>
                    </dict>
                </array>
                <key>lockedProfile</key>
                <true/>
            </dict>
        </dict>
    </dict>
</dict>
</plist>
PLIST

# Set proper ownership and permissions
chown root:wheel "$CHROME_PLIST"
chmod 644 "$CHROME_PLIST"

echo "✓ Chrome managed preferences written to: $CHROME_PLIST"
echo "✓ ModHeader will be force-installed on next Chrome launch"
echo "✓ Header 'x-riverside-internal: true' will be added to all requests"

# Verify the file was written correctly
if /usr/bin/plutil -lint "$CHROME_PLIST" > /dev/null 2>&1; then
    echo "✓ Plist validation passed"
else
    echo "✗ Plist validation failed!"
    exit 1
fi

exit 0


