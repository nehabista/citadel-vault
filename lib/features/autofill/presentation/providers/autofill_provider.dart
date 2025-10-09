import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/session_provider.dart';
import '../../../../core/session/session_state.dart';
import '../../data/services/autofill_bridge.dart';
import '../../data/services/vault_index_writer.dart';

/// Provider for the AutofillBridge instance.
///
/// Initializes the MethodChannel handler on creation, enabling native
/// autofill service communication. Should be read early in app lifecycle.
final autofillBridgeProvider = Provider<AutofillBridge>((ref) {
  return AutofillBridge.initialize(ref);
});

/// Whether Citadel is the system autofill provider.
///
/// Per D-21: queries native AutofillManager to check if Citadel is selected
/// as the device's autofill service.
final autofillStatusProvider = FutureProvider<bool>((ref) async {
  // Ensure bridge is initialized
  ref.watch(autofillBridgeProvider);

  try {
    const channel = MethodChannel('com.citadel/autofill');
    final result = await channel.invokeMethod<bool>('getAutofillStatus');
    return result ?? false;
  } catch (_) {
    return false;
  }
});

/// Opens the system autofill settings screen.
///
/// Per D-21: triggers Intent(Settings.ACTION_REQUEST_SET_AUTOFILL_SERVICE)
/// on Android, allowing the user to select Citadel as their autofill provider.
final openAutofillSettingsProvider = Provider<Future<void> Function()>((ref) {
  return AutofillBridge.openAutofillSettings;
});

/// Provider for VaultIndexWriter instance.
final vaultIndexWriterProvider = Provider<VaultIndexWriter>((ref) {
  return VaultIndexWriter(ref);
});

/// Listens to session state changes and manages the encrypted vault index.
///
/// On transition to Unlocked: writes encrypted credential index to macOS
/// App Group container and stores vault key in shared Keychain.
/// On transition to Locked: clears the index and shared key.
///
/// This provider should be watched early in app lifecycle to ensure
/// the index stays in sync with the session state.
final vaultIndexLifecycleProvider = Provider<void>((ref) {
  final session = ref.watch(sessionProvider);
  final writer = ref.read(vaultIndexWriterProvider);

  if (session is Unlocked) {
    // Write encrypted index on unlock
    writer.writeEncryptedIndex();
  } else if (session is Locked) {
    // Clear index on lock
    writer.clearIndex();
  }
});
