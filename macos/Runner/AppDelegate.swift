import Cocoa
import FlutterMacOS
import Security

@main
class AppDelegate: FlutterAppDelegate {

  private let appGroupId = "group.com.shaivites.citadelvault"
  private let keychainService = "com.shaivites.citadelvault.autofill-key"
  private let keychainAccount = "vault-index-key"
  private let keychainAccessGroup = "com.shaivites.citadelvault.shared"

  override func applicationDidFinishLaunching(_ notification: Notification) {
    guard let controller = mainFlutterWindow?.contentViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: "com.citadel/vault-index",
      binaryMessenger: controller.engine.binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else {
        result(FlutterError(code: "UNAVAILABLE", message: "AppDelegate deallocated", details: nil))
        return
      }

      switch call.method {
      case "writeIndex":
        self.handleWriteIndex(call: call, result: result)
      case "storeSharedKey":
        self.handleStoreSharedKey(call: call, result: result)
      case "clearIndex":
        self.handleClearIndex(result: result)
      case "clearSharedKey":
        self.handleClearSharedKey(result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  // MARK: - Vault Index Write/Clear

  /// Write base64-encoded encrypted vault index to App Group container.
  private func handleWriteIndex(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let base64Data = args["data"] as? String,
          let data = Data(base64Encoded: base64Data)
    else {
      result(FlutterError(code: "INVALID_ARGS", message: "Missing or invalid 'data' parameter", details: nil))
      return
    }

    guard let containerURL = FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: appGroupId
    ) else {
      result(FlutterError(code: "APP_GROUP_ERROR", message: "Cannot access App Group container", details: nil))
      return
    }

    let fileURL = containerURL.appendingPathComponent("autofill_vault.enc")
    do {
      try data.write(to: fileURL, options: .atomic)
      result(true)
    } catch {
      result(FlutterError(code: "WRITE_ERROR", message: "Failed to write vault index: \(error.localizedDescription)", details: nil))
    }
  }

  /// Delete encrypted vault index from App Group container.
  private func handleClearIndex(result: @escaping FlutterResult) {
    guard let containerURL = FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: appGroupId
    ) else {
      result(FlutterError(code: "APP_GROUP_ERROR", message: "Cannot access App Group container", details: nil))
      return
    }

    let fileURL = containerURL.appendingPathComponent("autofill_vault.enc")
    do {
      if FileManager.default.fileExists(atPath: fileURL.path) {
        try FileManager.default.removeItem(at: fileURL)
      }
      result(true)
    } catch {
      result(FlutterError(code: "DELETE_ERROR", message: "Failed to delete vault index: \(error.localizedDescription)", details: nil))
    }
  }

  // MARK: - Shared Keychain Key Storage

  /// Store the vault index decryption key in the shared Keychain access group.
  private func handleStoreSharedKey(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let base64Key = args["key"] as? String,
          let keyData = Data(base64Encoded: base64Key),
          keyData.count == 32
    else {
      result(FlutterError(code: "INVALID_ARGS", message: "Missing or invalid 'key' parameter (must be 32 bytes base64)", details: nil))
      return
    }

    // Try to update existing item first
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: keychainService,
      kSecAttrAccount as String: keychainAccount,
      kSecAttrAccessGroup as String: keychainAccessGroup,
    ]

    let updateAttributes: [String: Any] = [
      kSecValueData as String: keyData,
    ]

    var status = SecItemUpdate(query as CFDictionary, updateAttributes as CFDictionary)

    if status == errSecItemNotFound {
      // Item doesn't exist yet, add it
      var addQuery = query
      addQuery[kSecValueData as String] = keyData
      status = SecItemAdd(addQuery as CFDictionary, nil)
    }

    if status == errSecSuccess {
      result(true)
    } else {
      result(FlutterError(code: "KEYCHAIN_ERROR", message: "Failed to store key in Keychain (status: \(status))", details: nil))
    }
  }

  /// Delete the vault index decryption key from the shared Keychain.
  private func handleClearSharedKey(result: @escaping FlutterResult) {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: keychainService,
      kSecAttrAccount as String: keychainAccount,
      kSecAttrAccessGroup as String: keychainAccessGroup,
    ]

    let status = SecItemDelete(query as CFDictionary)

    if status == errSecSuccess || status == errSecItemNotFound {
      result(true)
    } else {
      result(FlutterError(code: "KEYCHAIN_ERROR", message: "Failed to delete key from Keychain (status: \(status))", details: nil))
    }
  }
}
