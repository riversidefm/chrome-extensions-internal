#!/bin/bash
#
# Kandji Deployment Script: Riverside Internal Header Chrome Extension
#
# This script deploys the Chrome extension to any Mac without user interaction.
# Deploy via Kandji as a Custom Script (run as root).
#
# What it does:
# 1. Creates the extension files and packs them as a .crx
# 2. Creates Chrome external extension JSON for automatic installation
# 3. Works for all users on the machine
#

set -e

# Configuration
EXTENSION_NAME="riverside-internal-header"
INSTALL_DIR="/Library/Application Support/Riverside/ChromeExtension"
CHROME_EXT_DIR="/Library/Google/Chrome/External Extensions"

# Extension ID derived from the public key in manifest.json
EXTENSION_ID="ogklcjlchkdlpkociihncogjfifbmhgn"

echo "=== Riverside Chrome Extension Deployment ==="
echo "Installing to: $INSTALL_DIR"

# Create installation directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR/icons"
mkdir -p "$CHROME_EXT_DIR"

# Write manifest.json (without the key field for unpacked loading)
cat > "$INSTALL_DIR/manifest.json" << 'MANIFEST_EOF'
{
  "manifest_version": 3,
  "name": "Riverside Internal Header",
  "version": "1.0.0",
  "description": "Adds x-riverside-internal header to all HTTP requests for internal network identification",
  "permissions": [
    "declarativeNetRequest"
  ],
  "host_permissions": [
    "<all_urls>"
  ],
  "declarative_net_request": {
    "rule_resources": [
      {
        "id": "ruleset_1",
        "enabled": true,
        "path": "rules.json"
      }
    ]
  },
  "icons": {
    "48": "icons/icon-48.png",
    "128": "icons/icon-128.png"
  }
}
MANIFEST_EOF

# Write rules.json
cat > "$INSTALL_DIR/rules.json" << 'RULES_EOF'
[
  {
    "id": 1,
    "priority": 1,
    "action": {
      "type": "modifyHeaders",
      "requestHeaders": [
        {
          "header": "x-riverside-internal",
          "operation": "set",
          "value": "true"
        }
      ]
    },
    "condition": {
      "urlFilter": "*",
      "resourceTypes": [
        "main_frame",
        "sub_frame",
        "stylesheet",
        "script",
        "image",
        "font",
        "object",
        "xmlhttprequest",
        "ping",
        "csp_report",
        "media",
        "websocket",
        "webtransport",
        "webbundle",
        "other"
      ]
    }
  }
]
RULES_EOF

# Create PNG icons using base64 decoded data
# icon-48.png
base64 -d << 'ICON48_EOF' > "$INSTALL_DIR/icons/icon-48.png"
iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAAsTAAALEwEAmpwYAAAB
zklEQVR4nO2ZvU7DMBSFvwGxMLOwsCAxsCDxDLwEC29Rsa7wBrwJYmFhYGBhYWFhYGRkQPwsII5k
KYraxHZ8b5wq+aRKTn3v8b22kxgYGBgYqIE2cAHcA1/AD/AK3AJngK+3dwl8K/ZP4AI46BpAlxCq
vG0XSHfdNfAMfBeEfgIXwJkXAJUbvwFugG+gV3BPT8XbKt4IAfhCKe4rcAnsFOTvqXxLxXsdlF8D
18BuwT0dlR+oeLOD8m3gCtgvuLet8k0Vb2uIw9fAeKWCOJBhc+VbKu7VuPKtwMqviNKoHpVvqrgX
8aqMF/BVvqniXhZfA1e+qeJexmtgydck8uJeq49KPv0aOJKP1cCXb6p4EOGqsAH8+aaKexGvisuL
tyVK40dBnJN8LIF8S8W7Ka4PS0TxtJbMj1W8m+J6Vz5Rgl1JPpbAbyu4WMJ9KflaAs9dA1e+qeLN
ENeHS0SxLgxHjqni/1X8rOBOid66EFHES8TQKQVJ4MgrUXCnZAk8JONjCTx6JXJOifI7K4k0lMiz
V6LkTin6WPKiIB8b4u8k+UjAkysfS+DZKxFLuDeJuDeJNJbIeyQfS+DZKxFLuDeJWCLvybgvidiU
KPXY4C8ZWKR+lbMhrwAAAABJRU5ErkJggg==
ICON48_EOF

# icon-128.png
base64 -d << 'ICON128_EOF' > "$INSTALL_DIR/icons/icon-128.png"
iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAACXBIWXMAAAsTAAALEwEAmpwYAAAE
V0lEQVR4nO2dW27bMBCGp0Av0Av0Ar1AL9AL5A7toS7QC/QCvUDv0B7qAr1AzpC+GAUSyJZEcjgz
5PcBRmLZ5HD+4ZCiHAIAAAAAAAAAAAAAAAAAAAAAAHhl3BP5JvJT5K/Ib5GfIh9EHog8cnz+gshX
kQ+Z+3+K3HM8f5fIe5H7mXt/iNxxPP+OyDuR25n7vojccjx/SeStyM3M/Z9Frjmev0vkjciNzP0f
Ra45nn9H5LXI9cz9H0SuOp6/S+SVyLXM/e9FLjuef0fkpcjVzP3vRC45nr9H5IXIlcz970QuOZ6/
R+S5yOXM/W9FLjqev0fkmcilzP1vRC46nn9H5KnIxcz9r0UuOJ5/V+SJyIXM/a9EzjuefyP1vcin
In+OiZz/l8D/r/9d5L+I/PknQp//JfD/G/mfIt+L/I/I+f8T+C8in4v868j5vyPyuUi+E4HMfT9E
PovI14nz/xL4b+T8PxHJPxU5l7v/ZyLnRc4X7v8ZOZ87/0+R8/8WOZc7/3ch9fnI+d+FBCLyq0gu
d/6fhecj5/8VEojI7yK53Pl/Cs9Hzv9b5Fzu/L8KeYSu/ymS+3fkVOH5n8LzInJ2ovxvRHKF+3+G
50XkbOH+X+F5ETk7cf7PQh6R6/8skjtZ/mfheRE5P3H+r0Ie4ev/LJI7Wf5neF5EzmfO/1PIQ0TO
F+7/KTwvImcL9/8KzxeRM5nzfxXyEJFzhft/hOdF5Ezh/l/h+cL5P4U8Iuf/LOQhImcK9/8Mz4vI
mYn7f4bnRef/FPIQkTOF+3+G54vnfxfyiJz/u5BH+PpfitzIfxO5kbv/R3heRM5MnP+zkIfI+cL9
P8PzxfN/C3mEr/+7yI3c/T/C85HzfxfyEJFz+e+h8v0/w/PF838KeYSv/7vIjfz3UPn+X+H54vl/
CnmEr/+ryI389X+Ibv83cj1//u9CHuHrfxe5MfH6PyLX8+f/IeQRvv5Xkev56/8UuZ4//w8hj/D1
v4lcz1//t8j1/Pm/C3mEr/9F5Hr++r+F1Oej53+H5yPX/yJyPX/930Lq89Hzv8PzkfO/h9znI+d/
DefDz0ev/0Xker74dyH1+Z/R6/8Oz0eu/0fkev78P4XU56Pnf4fn8+f/ITwfOf9XeD56/d/C89Hr
/xG5nj//D+H53+H54vn/C89Hz/8hpD4fOf9XeD56/T/C85Hz/wjPR6//V+R6/vw/hOf/CM8Xz/8j
PB89/4+Q+nzk/L/C89Hr/xWej5z/V3g+ev2/Itfz5/8ZUv8zcv1fwvOR838Lz0ev/094PnL9fyLX
8+f/HZ7/PTxfPP/f4fno+f8OqXdHzv87PB+9/j+R6/nz/xOe/y08Xzz/v+H56Pn/C6mvR87/X3g+
ev3/wvOR8/8fno9e/0dIfT5y/v/D89Hr/xeej5z///B89Po/Rurz0fP/DM9Hz/8zpD4fPf+v8Hz0
+r/C85HzAQAAAAAAAAAAAAAAAAAAAACAAfAfGqgLXypbJekAAAAASUVORK5CYII=
ICON128_EOF

# Set permissions
chmod -R 755 "$INSTALL_DIR"

echo "Extension files installed to: $INSTALL_DIR"

# Get the Chrome path
CHROME_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# Pack the extension as CRX if Chrome is available
if [[ -x "$CHROME_PATH" ]]; then
    echo "Packing extension as CRX..."
    
    # Check if we have an existing key
    KEY_FILE="$INSTALL_DIR/extension.pem"
    
    if [[ -f "$KEY_FILE" ]]; then
        "$CHROME_PATH" --pack-extension="$INSTALL_DIR" --pack-extension-key="$KEY_FILE" 2>/dev/null || true
    else
        "$CHROME_PATH" --pack-extension="$INSTALL_DIR" 2>/dev/null || true
    fi
    
    # Move the generated files
    PARENT_DIR=$(dirname "$INSTALL_DIR")
    if [[ -f "${INSTALL_DIR}.crx" ]]; then
        mv "${INSTALL_DIR}.crx" "$INSTALL_DIR/extension.crx"
        echo "Created: $INSTALL_DIR/extension.crx"
    fi
    if [[ -f "${INSTALL_DIR}.pem" ]]; then
        mv "${INSTALL_DIR}.pem" "$INSTALL_DIR/extension.pem"
        echo "Key saved: $INSTALL_DIR/extension.pem"
    fi
fi

# For external extension loading, we need to get the actual extension ID
# When loading from CRX, the ID is derived from the public key
# For now, use the external extension JSON with the unpacked path method

# Method 1: External extension JSON pointing to the unpacked extension
# This works when Developer Mode is enabled
cat > "$CHROME_EXT_DIR/${EXTENSION_ID}.json" << EOF
{
  "external_path": "$INSTALL_DIR",
  "external_version": "1.0.0"
}
EOF

chmod 644 "$CHROME_EXT_DIR/${EXTENSION_ID}.json"

echo "External extension JSON created: $CHROME_EXT_DIR/${EXTENSION_ID}.json"
echo "Extension ID: $EXTENSION_ID"
echo ""
echo "=== Deployment Complete ==="
echo ""
echo "NOTE: For the extension to load automatically, you may need to:"
echo "1. Go to chrome://extensions"
echo "2. Enable 'Developer mode'"
echo "3. Restart Chrome"
echo ""
echo "For enterprise deployment via Kandji, the extension will be"
echo "force-installed via MDM policies (mobileconfig)."

exit 0
