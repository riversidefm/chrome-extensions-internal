# Chrome Web Store Submission Texts

Copy and paste these into the Chrome Web Store Developer Console.

---

## Store Listing Tab

### Extension Name
```
Riverside Internal Header
```

### Summary (132 chars max)
```
Adds x-riverside-internal: true header to all HTTP requests for internal network identification.
```

### Description
```
This extension automatically adds the HTTP header "x-riverside-internal: true" to all outgoing browser requests.

Purpose:
- Identifies traffic from company-managed Chrome browsers
- Enables internal services to recognize corporate network requests
- Zero configuration required - works automatically once installed

Technical Details:
- Uses Chrome's declarativeNetRequest API for optimal performance
- No data is collected, stored, or transmitted
- Header is added to all request types (pages, scripts, images, API calls, etc.)

This extension is designed for enterprise deployment via MDM (Mobile Device Management) solutions like Kandji, Jamf, or Intune.

For IT Administrators:
Deploy using Chrome's ExtensionInstallForcelist policy to automatically install on all managed devices.
```

### Category
```
Productivity
```

---

## Privacy Practices Tab

### Single Purpose Description
```
Adds the HTTP header "x-riverside-internal: true" to all browser requests for internal network identification.
```

### Permission Justification: declarativeNetRequest
```
This extension uses declarativeNetRequest to add a static HTTP header (x-riverside-internal: true) to all outgoing requests. This identifies traffic from company-managed browsers to internal services. No request data is read, logged, or transmitted - only a static header is appended.
```

### Permission Justification: Host Permissions (all_urls)
```
The extension requires access to all URLs because the x-riverside-internal header must be added to every HTTP request, regardless of destination. This enables our internal services to identify traffic from managed corporate browsers. The extension only adds a header and does not read, modify, or store any page content or user data.
```

### Remote Code Justification
```
This extension does not use any remote code. All functionality is contained within the extension package using Chrome's declarativeNetRequest API with static rules defined in rules.json. No external scripts, code, or resources are loaded at runtime.
```

### Data Usage Certification
- [x] I certify that this extension does not collect or transmit user data

---

## Required Assets Checklist

- [ ] **Icon 128x128**: Use `extension/icons/icon-128.png` (already created)
- [ ] **Screenshot 1280x800 or 640x400**: Use `store-assets/screenshot-1280x800.png` (just created)
- [ ] **Contact Email**: Add in Account tab
- [ ] **Verify Email**: Complete verification in Account tab

---

## After Publishing

Once approved, you'll get an Extension ID like: `abcdefghijklmnopqrstuvwxyz123456`

Update Kandji mobileconfig:
```bash
# Replace EXTENSION_ID_HERE with your actual ID
sed -i '' 's/EXTENSION_ID_HERE/your-actual-extension-id/g' kandji/chrome-policy.mobileconfig
```

Then upload `chrome-policy.mobileconfig` to Kandji as a Custom Profile.


