import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/autofill_provider.dart';

/// Settings tile showing the current autofill service status.
///
/// Displays whether Citadel is enabled as the system autofill provider
/// and opens system autofill settings on tap.
///
/// Per D-21: queries native AutofillManager status and triggers
/// ACTION_REQUEST_SET_AUTOFILL_SERVICE on tap.
class AutofillSettingsTile extends ConsumerWidget {
  const AutofillSettingsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(autofillStatusProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(
            Icons.password,
            color: Color(0xFF4D4DCD),
          ),
          title: const Text(
            'Autofill Service',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          subtitle: statusAsync.when(
            data: (enabled) => Text(
              enabled ? 'Enabled' : 'Not enabled',
              style: TextStyle(
                color: enabled ? Colors.green : Colors.grey,
                fontFamily: 'Poppins',
              ),
            ),
            loading: () => const Text(
              'Checking...',
              style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'),
            ),
            error: (_, __) => const Text(
              'Not available',
              style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'),
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            final openSettings = ref.read(openAutofillSettingsProvider);
            openSettings();
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 72, right: 16, bottom: 8),
          child: Text(
            'Set Citadel as your autofill provider in system settings',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                ),
          ),
        ),
      ],
    );
  }
}
