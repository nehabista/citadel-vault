import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../providers/clipboard_provider.dart';

/// Settings tile with a dropdown for clipboard auto-clear timeout.
///
/// Per D-13: user-configurable timeout with options:
///   0 -> Never, 15 -> 15 seconds, 30 -> 30 seconds (default),
///   60 -> 1 minute, 300 -> 5 minutes.
/// Per D-20: persists to SettingsDao via `clipboard_timeout` key.
class ClipboardSettingsTile extends ConsumerWidget {
  const ClipboardSettingsTile({super.key});

  /// Timeout options: seconds -> display label.
  static const Map<int, String> timeoutOptions = {
    0: 'Never',
    15: '15 seconds',
    30: '30 seconds',
    60: '1 minute',
    300: '5 minutes',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeoutAsync = ref.watch(clipboardTimeoutProvider);

    return ListTile(
      leading: const Icon(
        Icons.content_paste_off,
        color: Color(0xFF4D4DCD),
      ),
      title: const Text(
        'Clipboard Auto-Clear',
        style: TextStyle(fontFamily: 'Poppins'),
      ),
      trailing: timeoutAsync.when(
        data: (duration) {
          final currentSeconds = duration.inSeconds;
          // Ensure current value is one of the valid options
          final selectedValue = timeoutOptions.containsKey(currentSeconds)
              ? currentSeconds
              : 30;

          return DropdownButton<int>(
            value: selectedValue,
            underline: const SizedBox(),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.black87,
            ),
            items: timeoutOptions.entries.map((entry) {
              return DropdownMenuItem<int>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (newValue) async {
              if (newValue == null) return;

              // Persist to settings database
              final db = ref.read(appDatabaseProvider);
              await db.settingsDao.setSetting(
                'clipboard_timeout',
                newValue.toString(),
              );

              // Invalidate the provider to reload the new value
              ref.invalidate(clipboardTimeoutProvider);
            },
          );
        },
        loading: () => const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (_, __) => const Text(
          '30 seconds',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
