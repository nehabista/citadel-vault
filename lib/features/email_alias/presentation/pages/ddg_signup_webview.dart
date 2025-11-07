// File: lib/features/email_alias/presentation/pages/ddg_signup_webview.dart
// DuckDuckGo Email Protection signup helper.
// Opens system browser for signup, then prompts for username on return.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helper page that guides the user through DDG Email signup.
///
/// DDG blocks in-app WebViews from accessing Email Protection —
/// requires the DuckDuckGo browser or extension. So we open the
/// system browser for signup and ask the user to enter their
/// username when they return.
class DdgSignupWebview extends StatelessWidget {
  const DdgSignupWebview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFDE5833),
        foregroundColor: Colors.white,
        title: const Text(
          'DuckDuckGo Email',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Duck icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFDE5833).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.email_outlined, size: 40, color: Color(0xFFDE5833)),
              ),
              const SizedBox(height: 24),

              const Text(
                'Create a Duck Address',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'DuckDuckGo Email Protection requires signup through their browser or website. '
                "We'll open it in Safari — create your free @duck.com address, then come back.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Step indicators
              _StepRow(number: '1', text: "Tap 'Open DuckDuckGo' below"),
              const SizedBox(height: 12),
              _StepRow(number: '2', text: 'Create your free @duck.com address'),
              const SizedBox(height: 12),
              _StepRow(number: '3', text: "Come back and tap 'I have my address'"),

              const Spacer(),

              // Open DDG button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () => launchUrl(
                    Uri.parse('https://duckduckgo.com/email/'),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text(
                    'Open DuckDuckGo',
                    style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFDE5833),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // I have my address button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => _showUsernameDialog(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDE5833),
                    side: const BorderSide(color: Color(0xFFDE5833)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'I have my Duck Address',
                    style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showUsernameDialog(BuildContext context) async {
    final controller = TextEditingController();

    final username = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Enter your Duck Address',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the username you created (without @duck.com)',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: const TextStyle(fontFamily: 'Poppins'),
                suffixText: '@duck.com',
                suffixStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey.shade500, fontSize: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFDE5833), width: 2),
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) Navigator.pop(ctx, value.trim());
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins')),
          ),
          FilledButton(
            onPressed: () {
              final val = controller.text.trim();
              if (val.isNotEmpty) Navigator.pop(ctx, val);
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDE5833)),
            child: const Text('Continue', style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );

    if (username != null && username.isNotEmpty && context.mounted) {
      Navigator.of(context).pop(username);
    }
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.text});
  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFDE5833).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                color: Color(0xFFDE5833),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
      ],
    );
  }
}
