// File: lib/features/email_alias/presentation/pages/ddg_signup_webview.dart
// In-app WebView for DuckDuckGo Email Protection signup.
// Monitors URL changes to detect successful signup and auto-extract the username.

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// WebView page that loads the DuckDuckGo Email Protection signup page.
///
/// When the user completes signup, the page detects the success URL
/// and pops with the duck.com username so the parent can auto-fill
/// the login field and trigger OTP.
class DdgSignupWebview extends StatefulWidget {
  const DdgSignupWebview({super.key});

  @override
  State<DdgSignupWebview> createState() => _DdgSignupWebviewState();
}

class _DdgSignupWebviewState extends State<DdgSignupWebview> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            _checkForSignupCompletion(url);
          },
          onUrlChange: (change) {
            if (change.url != null) {
              _checkForSignupCompletion(change.url!);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://duckduckgo.com/email/'));
  }

  /// Detect when the user has completed signup.
  ///
  /// DuckDuckGo redirects to the dashboard after successful signup.
  /// We try to extract the username from the page via JavaScript.
  Future<void> _checkForSignupCompletion(String url) async {
    // After signup, DDG shows the dashboard or a confirmation page
    if (url.contains('/email/') && !url.contains('/email/start')) {
      // Try to extract the username from the page
      try {
        final result = await _controller.runJavaScriptReturningResult(
          '''
          (function() {
            // Look for the duck address displayed on the page
            var el = document.querySelector('[data-testid="address"]') ||
                     document.querySelector('.address') ||
                     document.querySelector('input[type="email"]');
            if (el) {
              var val = el.textContent || el.value || '';
              return val.replace('@duck.com', '').trim();
            }
            return '';
          })()
          ''',
        );

        final username = result.toString().replaceAll('"', '').trim();
        if (username.isNotEmpty && username.length > 2 && mounted) {
          // Found the username — pop back with it
          Navigator.of(context).pop(username);
        }
      } catch (_) {
        // JS extraction failed — user can still manually go back
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFDE5833),
        foregroundColor: Colors.white,
        title: const Text(
          'DuckDuckGo Email Signup',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Manual "I'm done" button for cases where auto-detection fails
          TextButton(
            onPressed: () => _showUsernameDialog(),
            child: const Text(
              'Done',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const LinearProgressIndicator(
              color: Color(0xFFDE5833),
              backgroundColor: Colors.transparent,
            ),
        ],
      ),
    );
  }

  /// If auto-detection fails, let the user manually enter their duck username.
  Future<void> _showUsernameDialog() async {
    final controller = TextEditingController();

    final username = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Enter your Duck Address',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the username you just created (without @duck.com)',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: const TextStyle(fontFamily: 'Poppins'),
                suffixText: '@duck.com',
                suffixStyle: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
            child: const Text('Save', style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );

    if (username != null && username.isNotEmpty && mounted) {
      Navigator.of(context).pop(username);
    }
  }
}
