import Foundation
import Security
import CryptoKit

/// A credential stored in the encrypted vault index.
struct StoredCredential: Identifiable {
    let id: String
    let username: String
    let password: String
    let displayName: String
    let domain: String?
}

/// Reads and decrypts the AES-256-GCM encrypted credential index from the
/// App Group shared container using a key stored in the shared Keychain.
///
/// Flow (per D-10):
/// 1. Read encrypted blob from App Group container (autofill_vault.enc)
/// 2. Read 32-byte decryption key from shared Keychain access group
/// 3. Parse v2 blob: [0x02][12-byte nonce][ciphertext][16-byte GCM tag]
/// 4. Decrypt using AES-GCM (CryptoKit)
/// 5. Parse JSON into [StoredCredential]
class SharedVaultReader {
    private let appGroupId = "group.com.shaivites.citadelvault"
    private let keychainService = "com.shaivites.citadelvault.autofill-key"
    private let keychainAccount = "vault-index-key"
    // NOTE: At build time, $(AppIdentifierPrefix) resolves to your team ID + "."
    // e.g., "ABCDEF1234.com.shaivites.citadelvault.shared"
    // You may need to hardcode your team ID prefix here or read it from the bundle.
    private let keychainAccessGroup = "com.shaivites.citadelvault.shared"

    /// Read and decrypt all credentials from the encrypted vault index.
    func readAllCredentials() -> [StoredCredential] {
        // Step 1: Read encrypted file from App Group container
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupId
        ) else { return [] }

        let encryptedFile = containerURL.appendingPathComponent("autofill_vault.enc")
        guard let encryptedData = try? Data(contentsOf: encryptedFile),
              encryptedData.count > 29 // minimum: 1 (version) + 12 (nonce) + 16 (tag)
        else { return [] }

        // Step 2: Read decryption key from shared Keychain
        guard let keyData = readKeyFromKeychain(),
              keyData.count == 32
        else { return [] }

        // Step 3: Parse v2 encrypted blob format
        // [0x02 version][12-byte nonce][ciphertext][16-byte GCM tag]
        let version = encryptedData[0]
        guard version == 0x02 else { return [] } // Only support v2 format

        let nonceData = encryptedData[1..<13]
        let tagStart = encryptedData.count - 16
        let ciphertextData = encryptedData[13..<tagStart]
        let tagData = encryptedData[tagStart...]

        // Step 4: Decrypt using AES-256-GCM (CryptoKit)
        do {
            let symmetricKey = SymmetricKey(data: keyData)
            let nonce = try AES.GCM.Nonce(data: nonceData)
            let sealedBox = try AES.GCM.SealedBox(
                nonce: nonce,
                ciphertext: ciphertextData,
                tag: tagData
            )
            let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)

            // Step 5: Parse decrypted JSON
            guard let json = try? JSONSerialization.jsonObject(with: decryptedData) as? [[String: Any]]
            else { return [] }

            return json.compactMap { item in
                guard let id = item["vaultItemId"] as? String,
                      let username = item["username"] as? String,
                      let password = item["password"] as? String,
                      let displayName = item["displayName"] as? String
                else { return nil }
                return StoredCredential(
                    id: id, username: username, password: password,
                    displayName: displayName, domain: item["domain"] as? String
                )
            }
        } catch {
            // Decryption failed -- key mismatch, tampered data, or vault is locked
            return []
        }
    }

    /// Filter credentials by domain match.
    func readCredentials(forDomain domain: String?) -> [StoredCredential] {
        let all = readAllCredentials()
        guard let domain = domain?.lowercased() else { return all }
        return all.filter { credential in
            guard let credDomain = credential.domain?.lowercased() else { return false }
            return credDomain.contains(domain) || domain.contains(credDomain)
        }
    }

    // MARK: - Private Keychain Access

    /// Read the vault index decryption key from the shared Keychain access group.
    private func readKeyFromKeychain() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecAttrAccessGroup as String: keychainAccessGroup,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }
        return data
    }
}
