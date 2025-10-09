import 'package:cryptography/cryptography.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/session/session_state.dart';
import '../../../security/data/services/domain_comparator.dart';
import '../../domain/models/autofill_credential.dart';
import '../../presentation/providers/clipboard_provider.dart';

/// Bridge between Flutter and native autofill service via MethodChannel.
///
/// Handles platform channel calls from native Android AutofillService
/// (and future macOS Credential Provider Extension):
/// - `queryCredentials`: looks up vault items by domain/package hash, decrypts,
///   and returns credential data for the autofill picker.
/// - `onFillComplete`: after a credential is filled, auto-copies the TOTP code
///   (if present) to clipboard with auto-clear.
/// - `getAutofillStatus`: checks if Citadel is the system autofill provider.
///
/// Per D-02: MethodChannel name is `com.citadel/autofill`.
/// Per D-08: uses DomainComparator for phishing detection.
/// Per D-17/D-18/D-19: TOTP auto-copy on fill complete.
class AutofillBridge {
  static const _channel = MethodChannel('com.citadel/autofill');

  final Ref _ref;

  AutofillBridge._(this._ref);

  /// Initialize the autofill bridge and set up method call handler.
  ///
  /// Should be called early in the app lifecycle (e.g., from a provider).
  static AutofillBridge initialize(Ref ref) {
    final bridge = AutofillBridge._(ref);
    _channel.setMethodCallHandler(bridge._handleMethodCall);
    return bridge;
  }

  /// Handle incoming method calls from native autofill service.
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    try {
      switch (call.method) {
        case 'queryCredentials':
          return await _queryCredentials(call.arguments as Map);
        case 'onFillComplete':
          return await _onFillComplete(call.arguments as Map);
        case 'getAutofillStatus':
          return await _getAutofillStatus();
        default:
          return null;
      }
    } catch (e) {
      // Return empty/null on failure -- native side handles gracefully
      return null;
    }
  }

  /// Query credentials matching a domain hash or package hash.
  ///
  /// The native autofill service sends SHA-256 hashes of the requesting
  /// app's domain and/or package name. We look up matching vault items,
  /// decrypt them, and return credential data for the autofill picker.
  ///
  /// Per D-08: checks domain match using DomainComparator for phishing defense.
  Future<List<Map<String, dynamic>>> _queryCredentials(Map args) async {
    final session = _ref.read(sessionProvider);
    if (session is! Unlocked) {
      // Vault is locked -- native side should redirect to auth screen
      return [];
    }

    final domainHash = args['domainHash'] as String?;
    final packageHash = args['packageHash'] as String?;
    final requestingDomain = args['requestingDomain'] as String?;

    final db = _ref.read(appDatabaseProvider);
    final autofillDao = db.autofillIndexDao;

    // Query by domain hash first, fallback to package hash
    List<AutofillIndexData> matches = [];
    if (domainHash != null && domainHash.isNotEmpty) {
      matches = await autofillDao.findByDomainHash(domainHash);
    }
    if (matches.isEmpty && packageHash != null && packageHash.isNotEmpty) {
      matches = await autofillDao.findByPackageHash(packageHash);
    }

    if (matches.isEmpty) return [];

    final vaultKey = SecretKey(session.vaultKey);
    final cryptoEngine = _ref.read(cryptoEngineProvider);
    final totpDao = db.totpDao;
    final credentials = <Map<String, dynamic>>[];

    for (final match in matches) {
      try {
        // Load the vault item by ID
        final allItems = await (db.select(db.vaultItems)
              ..where((t) => t.id.equals(match.vaultItemId)))
            .get();

        if (allItems.isEmpty) continue;
        final item = allItems.first;

        // Decrypt the encrypted blob to get credential fields
        final fields = await cryptoEngine.decryptFields(
          item.encryptedData,
          vaultKey,
        );

        final username = (fields['username'] as String?) ?? '';
        final password = (fields['password'] as String?) ?? '';
        final displayName = (fields['name'] as String?) ?? 'Unknown';
        final savedUrl = fields['url'] as String?;

        // Check for TOTP entries
        final totpEntries = await totpDao.getByVaultItemId(match.vaultItemId);
        final hasTotpEntry = totpEntries.isNotEmpty;

        // Per D-08: phishing detection via domain comparison
        bool phishingWarning = false;
        if (requestingDomain != null && savedUrl != null) {
          phishingWarning = !DomainComparator.domainsMatch(
            savedUrl,
            requestingDomain,
          );
        }

        final credential = AutofillCredential(
          vaultItemId: match.vaultItemId,
          username: username,
          password: password,
          displayName: displayName,
          domain: DomainComparator.extractDomain(savedUrl),
          hasTotpEntry: hasTotpEntry,
          phishingWarning: phishingWarning,
        );

        credentials.add(credential.toMap());
      } catch (_) {
        // Skip items that fail to decrypt (e.g., corrupted data)
        continue;
      }
    }

    return credentials;
  }

  /// Handle fill completion -- auto-copy TOTP code if available.
  ///
  /// Per D-17/D-18/D-19: after a credential is autofilled, look up the
  /// associated TOTP entry, generate the current code, and copy it to
  /// clipboard with auto-clear.
  Future<Map<String, dynamic>?> _onFillComplete(Map args) async {
    final vaultItemId = args['vaultItemId'] as String?;
    if (vaultItemId == null) return null;

    final session = _ref.read(sessionProvider);
    if (session is! Unlocked) return null;

    try {
      final vaultKey = SecretKey(session.vaultKey);
      final totpRepo = _ref.read(totpRepositoryProvider);
      final totpEntries = await totpRepo.getByVaultItemId(vaultItemId, vaultKey);

      if (totpEntries.isEmpty) {
        return {'hasTotpCode': false};
      }

      // Generate current TOTP code from the first entry
      final entry = totpEntries.first;
      final totpService = _ref.read(totpServiceProvider);
      final code = totpService.generateCode(
        base32Secret: entry.secret,
        digits: entry.digits,
        period: entry.period,
        algorithm: entry.algorithm,
      );

      // Copy TOTP code to clipboard with auto-clear
      final clipboardService = _ref.read(clipboardServiceProvider);
      await clipboardService.copyWithAutoClear(code);

      return {
        'hasTotpCode': true,
        'message': 'TOTP code copied to clipboard',
      };
    } catch (_) {
      return {'hasTotpCode': false, 'error': 'Failed to generate TOTP code'};
    }
  }

  /// Check if Citadel is the system autofill provider.
  ///
  /// Per D-21: queries the native side to check AutofillManager status.
  Future<bool> _getAutofillStatus() async {
    try {
      final result = await _channel.invokeMethod<bool>('getAutofillStatus');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Open system autofill settings to let user select Citadel as provider.
  ///
  /// Per D-21: triggers Intent(Settings.ACTION_REQUEST_SET_AUTOFILL_SERVICE).
  static Future<void> openAutofillSettings() async {
    try {
      await _channel.invokeMethod('openAutofillSettings');
    } catch (_) {
      // Ignore errors (e.g., platform not supported)
    }
  }
}
