import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/autofill_bridge.dart';

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
