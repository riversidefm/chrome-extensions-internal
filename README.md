# Riverside Internal Header - Chrome Extension

A Chrome extension that adds the `x-riverside-internal: true` HTTP header to all browser requests. Designed for automated enterprise deployment via Kandji MDM on macOS.

## What This Does

This extension automatically injects a custom HTTP header into every HTTP/HTTPS request made by Chrome:

```
x-riverside-internal: true
```

This allows your internal services to identify traffic originating from company-managed Chrome browsers.

## Project Structure

```
chrome-header/
├── extension/                         # Chrome extension source (for local testing)
│   ├── manifest.json
│   ├── rules.json
│   └── icons/
├── kandji/                            # MDM deployment files
│   ├── deploy-extension.sh           # Main deployment script (run as root)
│   ├── uninstall-extension.sh        # Removal script
│   └── chrome-policy.mobileconfig    # Chrome policy profile
├── scripts/                           # Helper scripts
│   ├── generate-icons.sh
│   └── package-extension.sh
└── README.md
```

## Kandji Deployment (Automated, No User Interaction)

This deployment method works for any Mac and any username, with zero user interaction required.

### Step 1: Create Custom Script in Kandji

1. In Kandji, go to **Library** → **Custom Scripts**
2. Click **Add New**
3. Configure:
   - **Name**: `Riverside Chrome Extension - Install`
   - **Execution Frequency**: `Run once per device` (or `Run on every check-in` for enforcement)
   - **Run as**: `root`
4. Paste the contents of `kandji/deploy-extension.sh` into the script editor
5. Save and assign to your Blueprint(s)

### Step 2: Deploy Chrome Policy Profile

1. In Kandji, go to **Library** → **Custom Profiles**
2. Click **Add Custom Profile**
3. Upload `kandji/chrome-policy.mobileconfig`
4. Assign to the same Blueprint(s) as the script

### Step 3: Verify Deployment

After deployment, verify on a test Mac:

```bash
# Check extension files are installed
ls -la "/Library/Application Support/Riverside/ChromeExtension/"

# Check external extension JSON exists
ls -la "/Library/Google/Chrome/External Extensions/"

# Check Chrome policies are applied
defaults read com.google.Chrome
```

In Chrome:
1. Open `chrome://extensions`
2. Verify "Riverside Internal Header" is installed and shows "Installed by enterprise policy"
3. Open `chrome://policy` to verify policies are applied

## How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│                         Kandji MDM                               │
├─────────────────────────────────────────────────────────────────┤
│  1. Custom Script (deploy-extension.sh)                         │
│     └── Copies extension to /Library/Application Support/...   │
│     └── Creates External Extension JSON                         │
│                                                                  │
│  2. Custom Profile (chrome-policy.mobileconfig)                 │
│     └── Force-installs extension via Chrome policy             │
│     └── Prevents user from disabling extension                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Managed Mac                                 │
├─────────────────────────────────────────────────────────────────┤
│  /Library/Application Support/Riverside/ChromeExtension/       │
│     ├── manifest.json                                           │
│     ├── rules.json                                              │
│     ├── updates.xml                                             │
│     └── icons/                                                  │
│                                                                  │
│  /Library/Google/Chrome/External Extensions/                   │
│     └── ogklcjlchkdlpkociihncogjfifbmhgn.json                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Chrome Browser                                │
├─────────────────────────────────────────────────────────────────┤
│  • Extension auto-loads on startup                              │
│  • Shows "Installed by enterprise policy"                       │
│  • User cannot disable or remove                                │
│  • All requests include: x-riverside-internal: true             │
└─────────────────────────────────────────────────────────────────┘
```

## Extension Details

- **Extension ID**: `ogklcjlchkdlpkociihncogjfifbmhgn`
- **Install Location**: `/Library/Application Support/Riverside/ChromeExtension/`
- **Manifest Version**: 3 (latest)
- **API**: `declarativeNetRequest` (secure, performant)

## Uninstalling

### Via Kandji

1. Remove the Custom Script from your Blueprint
2. Remove the Custom Profile from your Blueprint
3. Create a new Custom Script using `kandji/uninstall-extension.sh`
4. Assign to devices that need the extension removed

### Manually on a Mac

```bash
sudo /path/to/kandji/uninstall-extension.sh
```

## Updating the Extension

To deploy an updated version:

1. Update the version number in `kandji/deploy-extension.sh`:
   - Change `"version": "1.0.0"` to the new version
   - Update the `external_version` in the updates.xml section

2. In Kandji, update the Custom Script with the new content
   - Or set the script to "Run on every check-in" to auto-update

3. Chrome will pick up the new version on next restart

## Troubleshooting

### Extension Not Appearing

1. **Check script ran successfully** in Kandji device details
2. **Verify files exist**:
   ```bash
   ls -la "/Library/Application Support/Riverside/ChromeExtension/"
   ls -la "/Library/Google/Chrome/External Extensions/"
   ```
3. **Restart Chrome** completely (Cmd+Q, then reopen)
4. **Check Chrome policies**: Visit `chrome://policy` in Chrome

### Extension Shows But Header Not Added

1. Open DevTools (F12) → Network tab
2. Make any request
3. Click the request → Headers tab
4. Look for `x-riverside-internal: true` in Request Headers
5. If missing, check `chrome://extensions` for errors

### Policy Not Applying

1. **Verify profile is installed**:
   ```bash
   profiles list | grep -i riverside
   ```
2. **Check Chrome reads the policy**:
   ```bash
   defaults read com.google.Chrome ExtensionInstallForcelist
   ```
3. **Force Chrome to reload policies**: Restart Chrome or visit `chrome://policy` and click "Reload policies"

### "Extension may have been corrupted" Error

This can happen if files are partially written. Fix:
```bash
sudo rm -rf "/Library/Application Support/Riverside/ChromeExtension"
sudo rm -f "/Library/Google/Chrome/External Extensions/ogklcjlchkdlpkociihncogjfifbmhgn.json"
# Then re-run the deployment script
```

## Local Testing (Development)

For testing before deployment:

1. Open Chrome → `chrome://extensions`
2. Enable "Developer mode"
3. Click "Load unpacked"
4. Select the `extension/` folder
5. Test on any website using DevTools Network tab

## Security Notes

- Uses `declarativeNetRequest` API (most restricted/secure method)
- Static header value - no dynamic data or user info transmitted
- Force-installed via enterprise policy - users cannot disable
- No access to page content, only HTTP headers
- All files installed in system-wide `/Library/` (not user-writable)

## Files Reference

| File | Purpose |
|------|---------|
| `kandji/deploy-extension.sh` | Main deployment script - copies extension files |
| `kandji/uninstall-extension.sh` | Removes extension from Mac |
| `kandji/chrome-policy.mobileconfig` | Chrome policy for force-install |
| `extension/` | Source files for local development/testing |

## License

Internal use only - Riverside Company
