import SwiftUI

/// SwiftUI view for displaying and selecting credentials in the AutoFill extension.
struct CredentialListView: View {
    let credentials: [StoredCredential]
    let onSelect: (StoredCredential) -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Citadel Vault")
                    .font(.headline)
                Spacer()
                Button("Cancel") { onCancel() }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
            }
            .padding()

            Divider()

            if credentials.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No matching credentials")
                        .foregroundColor(.secondary)
                    Text("Unlock Citadel to sync credentials")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(credentials) { credential in
                    Button(action: { onSelect(credential) }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(credential.displayName)
                                .font(.body)
                                .fontWeight(.medium)
                            Text(credential.username)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(minWidth: 300, minHeight: 200)
    }
}
