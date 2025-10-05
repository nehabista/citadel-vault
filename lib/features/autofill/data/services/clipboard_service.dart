import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/providers/clipboard_provider.dart';

/// Clipboard service with auto-clear timer and sensitive flag support.
///
/// On Android: uses native MethodChannel for EXTRA_IS_SENSITIVE (API 33+)
/// and native Handler-based timer that works when app is backgrounded.
/// On other platforms: uses Flutter's Clipboard API with Dart Timer.
///
/// Per D-13: clipboard timeout is user-configurable (0, 15, 30, 60, 300 seconds).
/// Per D-14: clipboard is cleared after timeout.
/// Per D-15: sensitive copies are marked with EXTRA_IS_SENSITIVE on Android 13+.
class ClipboardService {
  final Ref _ref;

  /// Native clipboard channel for Android-specific operations.
  static const _clipboardChannel = MethodChannel('com.citadel/clipboard');

  /// Dart-side timer for non-Android platforms.
  Timer? _clearTimer;

  ClipboardService(this._ref);

  /// Whether we're running on Android (not web).
  bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  /// Copy text to clipboard with auto-clear scheduling.
  ///
  /// [sensitive] marks the copy as sensitive on Android 13+ (hides from
  /// clipboard preview and keyboard suggestions). Defaults to true since
  /// this is a password manager.
  ///
  /// After copying, schedules clipboard clear based on user's configured
  /// timeout setting. A timeout of 0 means "never clear".
  Future<void> copyWithAutoClear(String text, {bool sensitive = true}) async {
    // Copy to clipboard
    if (_isAndroid) {
      await _clipboardChannel.invokeMethod('copy', {
        'text': text,
        'isSensitive': sensitive,
      });
    } else {
      await Clipboard.setData(ClipboardData(text: text));
    }

    // Schedule auto-clear based on user preference
    final timeout = await _ref.read(clipboardTimeoutProvider.future);
    if (timeout == Duration.zero) return; // Never clear

    if (_isAndroid) {
      await _clipboardChannel.invokeMethod('scheduleClear', {
        'delayMs': timeout.inMilliseconds,
      });
    } else {
      _clearTimer?.cancel();
      _clearTimer = Timer(timeout, () => clearClipboard());
    }

    // Update timer state for UI display
    _ref.read(clipboardTimerStateProvider.notifier).setClearTime(
        DateTime.now().add(timeout));
  }

  /// Clear clipboard contents immediately.
  Future<void> clearClipboard() async {
    _clearTimer?.cancel();
    _clearTimer = null;

    if (_isAndroid) {
      await _clipboardChannel.invokeMethod('clear');
    } else {
      await Clipboard.setData(const ClipboardData(text: ''));
    }

    // Reset timer state
    _ref.read(clipboardTimerStateProvider.notifier).setClearTime(null);
  }

  /// Cancel any pending auto-clear timer without clearing clipboard.
  void cancelAutoClear() {
    _clearTimer?.cancel();
    _clearTimer = null;
  }
}
