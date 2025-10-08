import AuthenticationServices
import SwiftUI

/// macOS AutoFill Credential Provider Extension view controller.
///
/// Implements ASCredentialProviderViewController to provide system-level
/// autofill for Safari and other macOS apps. Reads encrypted credentials
/// from the App Group shared container via SharedVaultReader.
class CredentialProviderViewController: ASCredentialProviderViewController {
    private let vaultReader = SharedVaultReader()

    /// Called when the system needs a credential list for a service (URL/domain).
    /// Displays a SwiftUI list of matching credentials for user selection.
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        // Extract domain from service identifiers
        let domain = serviceIdentifiers.first?.identifier

        let credentials = vaultReader.readCredentials(forDomain: domain)

        let listView = CredentialListView(
            credentials: credentials,
            onSelect: { [weak self] credential in
                let passwordCredential = ASPasswordCredential(
                    user: credential.username,
                    password: credential.password
                )
                self?.extensionContext.completeRequest(
                    withSelectedCredential: passwordCredential,
                    completionHandler: nil
                )
            },
            onCancel: { [weak self] in
                self?.extensionContext.cancelRequest(
                    withError: NSError(
                        domain: ASExtensionErrorDomain,
                        code: ASExtensionError.userCanceled.rawValue
                    )
                )
            }
        )

        let hostingView = NSHostingController(rootView: listView)
        addChild(hostingView)
        view.addSubview(hostingView.view)
        hostingView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingView.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    /// Quick fill without UI -- try to find credential by record identifier.
    override func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity) {
        let allCredentials = vaultReader.readAllCredentials()
        if let match = allCredentials.first(where: { $0.id == credentialIdentity.recordIdentifier }) {
            let credential = ASPasswordCredential(user: match.username, password: match.password)
            extensionContext.completeRequest(withSelectedCredential: credential, completionHandler: nil)
        } else {
            // Need user interaction to select
            extensionContext.cancelRequest(withError: NSError(
                domain: ASExtensionErrorDomain,
                code: ASExtensionError.userInteractionRequired.rawValue
            ))
        }
    }

    /// User selected from QuickType bar -- find and provide the credential.
    override func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {
        let allCredentials = vaultReader.readAllCredentials()
        if let match = allCredentials.first(where: { $0.id == credentialIdentity.recordIdentifier }) {
            let credential = ASPasswordCredential(user: match.username, password: match.password)
            extensionContext.completeRequest(withSelectedCredential: credential, completionHandler: nil)
        } else {
            // Fall back to showing list
            prepareCredentialList(for: [])
        }
    }
}
