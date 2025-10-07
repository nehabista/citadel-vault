# CitadelAutofillExtension - Xcode Target Setup

The macOS Credential Provider Extension requires manual Xcode target registration.
Follow these steps to add the extension target to the project.

## Steps

1. **Open the workspace in Xcode:**
   ```
   open macos/Runner.xcworkspace
   ```

2. **Add a new target:**
   - File > New > Target...
   - Select "AutoFill Credential Provider Extension" (under macOS > Application Extension)
   - Click "Next"

3. **Configure the target:**
   - Product Name: `CitadelAutofillExtension`
   - Bundle Identifier: `com.shaivites.citadelvault.autofill-extension`
   - Language: Swift
   - Click "Finish"
   - When prompted to activate the scheme, click "Activate"

4. **Set deployment target:**
   - Select the `CitadelAutofillExtension` target in the project navigator
   - General tab > Minimum Deployments > macOS 12.0

5. **Add capabilities:**
   - Select the `CitadelAutofillExtension` target
   - Signing & Capabilities tab
   - Click "+ Capability" and add **App Groups**
     - Add group: `group.com.shaivites.citadelvault`
   - Click "+ Capability" and add **Keychain Sharing**
     - Add group: `com.shaivites.citadelvault.shared`

6. **Replace auto-generated files:**
   - Delete any Swift files Xcode auto-generated in the extension target
     (e.g., `CredentialProviderViewController.swift`)
   - The correct source files are already in this directory:
     - `CredentialProviderViewController.swift`
     - `CredentialListView.swift`
     - `SharedVaultReader.swift`
   - Add these files to the `CitadelAutofillExtension` target in Xcode
     (select them, open File Inspector, check the extension target under Target Membership)

7. **Verify the extension Info.plist:**
   - Ensure the target uses `CitadelAutofillExtension/Info.plist`
   - The plist should already be configured with the correct NSExtension settings

8. **Verify the entitlements:**
   - Ensure the target uses `CitadelAutofillExtension/CitadelAutofillExtension.entitlements`

9. **Build and verify:**
   - Select the `CitadelAutofillExtension` scheme
   - Build (Cmd+B) to verify no compilation errors
   - The extension should appear in `xcodebuild -list -workspace macos/Runner.xcworkspace`

## Verification

Run this command to confirm the target is registered:
```bash
xcodebuild -list -workspace macos/Runner.xcworkspace 2>/dev/null | grep CitadelAutofillExtension
```

## How It Works

The extension runs as a separate process from the main Flutter app. It:
1. Reads the AES-256-GCM encrypted vault index from the App Group shared container
2. Retrieves the decryption key from the shared Keychain access group
3. Decrypts and displays matching credentials in a SwiftUI list
4. Returns the selected credential to the system for autofill

The main app writes the encrypted index and key via the `com.citadel/vault-index`
MethodChannel (handled in AppDelegate.swift).
