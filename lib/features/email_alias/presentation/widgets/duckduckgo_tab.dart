// File: lib/features/email_alias/presentation/widgets/duckduckgo_tab.dart
// DuckDuckGo tab content: login flow (username + OTP), alias list, generate, logout.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../presentation/widgets/citadel_snackbar.dart';
import '../../data/services/duckduckgo_alias_service.dart';
import '../pages/ddg_signup_webview.dart';
import '../providers/alias_providers.dart';

class DuckDuckGoTab extends ConsumerWidget {
  final String searchQuery;
  const DuckDuckGoTab({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenAsync = ref.watch(ddgTokenProvider);

    return tokenAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          'Error: $e',
          style: const TextStyle(fontFamily: 'Poppins', color: Colors.red),
        ),
      ),
      data: (token) {
        if (token == null) return const _DdgLoginView();
        return _DdgAuthenticatedView(searchQuery: searchQuery);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// DDG Login View (OTP flow)
// ---------------------------------------------------------------------------

class _DdgLoginView extends ConsumerStatefulWidget {
  const _DdgLoginView();

  @override
  ConsumerState<_DdgLoginView> createState() => _DdgLoginViewState();
}

class _DdgLoginViewState extends ConsumerState<_DdgLoginView> {
  final _usernameController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFDE5833).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.email_outlined, size: 36, color: Color(0xFFDE5833)),
          ),
          const SizedBox(height: 16),
          const Text(
            'DuckDuckGo Email Protection',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _otpSent
                ? 'Enter the OTP sent to your email.'
                : 'Generate unlimited private @duck.com aliases.\nSign in with your DuckDuckGo Email account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          if (!_otpSent)
            TextButton.icon(
              onPressed: () async {
                final username = await Navigator.of(context).push<String>(
                  MaterialPageRoute(builder: (_) => const DdgSignupWebview()),
                );
                if (username != null && username.isNotEmpty && mounted) {
                  _usernameController.text = username;
                  showCitadelSnackBar(context, 'Welcome! Sending OTP to $username@duck.com...',
                      type: SnackBarType.success);
                  // Auto-trigger OTP send
                  _handleAction();
                }
              },
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text(
                "Don't have an account? Sign up in-app",
                style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
              ),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFDE5833)),
            ),
          const SizedBox(height: 16),

          // Username field
          TextField(
            controller: _usernameController,
            enabled: !_otpSent,
            decoration: InputDecoration(
              labelText: 'Duck.com Username',
              labelStyle: const TextStyle(fontFamily: 'Poppins'),
              hintText: 'e.g. john (without @duck.com)',
              hintStyle: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE8EDF5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFFDE5833), width: 2),
              ),
              prefixIcon:
                  const Icon(Icons.alternate_email, color: Color(0xFFDE5833)),
            ),
          ),

          if (_otpSent) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'One-Time Passcode',
                labelStyle: const TextStyle(fontFamily: 'Poppins'),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE8EDF5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: Color(0xFFDE5833), width: 2),
                ),
                prefixIcon: const Icon(Icons.lock_outline,
                    color: Color(0xFFDE5833)),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Action button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _loading ? null : _handleAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDE5833),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      _otpSent ? 'Verify OTP' : 'Send OTP',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          if (_otpSent) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loading
                  ? null
                  : () {
                      setState(() {
                        _otpSent = false;
                        _otpController.clear();
                      });
                    },
              child: const Text(
                'Use a different username',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Color(0xFFDE5833),
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              launchUrl(
                  Uri.parse('https://duckduckgo.com/email/'));
            },
            child: const Text(
              "Don't have an account? Sign up at duckduckgo.com/email",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Color(0xFFDE5833),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) return;

    setState(() => _loading = true);

    try {
      if (!_otpSent) {
        // Send OTP
        await ref.read(ddgActionsProvider).requestOtp(username);
        if (mounted) {
          setState(() => _otpSent = true);
          showCitadelSnackBar(context, 'OTP sent to your email',
              type: SnackBarType.success);
        }
      } else {
        // Verify OTP
        final otp = _otpController.text.trim();
        if (otp.isEmpty) {
          setState(() => _loading = false);
          return;
        }
        await ref.read(ddgActionsProvider).verifyOtp(username, otp);
        if (mounted) {
          showCitadelSnackBar(context, 'Authenticated with DuckDuckGo',
              type: SnackBarType.success);
        }
      }
    } on DdgAuthException catch (e) {
      if (mounted) {
        showCitadelSnackBar(context, e.message, type: SnackBarType.error);
      }
    } on DdgApiException catch (e) {
      if (mounted) {
        showCitadelSnackBar(context, e.message, type: SnackBarType.error);
      }
    } catch (e) {
      if (mounted) {
        showCitadelSnackBar(context, 'Error: $e', type: SnackBarType.error);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

// ---------------------------------------------------------------------------
// DDG Authenticated View (generate aliases + list)
// ---------------------------------------------------------------------------

class _DdgAuthenticatedView extends ConsumerStatefulWidget {
  final String searchQuery;
  const _DdgAuthenticatedView({required this.searchQuery});

  @override
  ConsumerState<_DdgAuthenticatedView> createState() =>
      _DdgAuthenticatedViewState();
}

class _DdgAuthenticatedViewState
    extends ConsumerState<_DdgAuthenticatedView> {
  bool _generating = false;

  @override
  Widget build(BuildContext context) {
    final aliases = ref.watch(ddgAliasListProvider);
    final filtered = widget.searchQuery.isEmpty
        ? aliases
        : aliases
            .where((a) =>
                a.toLowerCase().contains(widget.searchQuery.toLowerCase()))
            .toList();

    return Column(
      children: [
        // Generate button + logout row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _generating ? null : _generateAlias,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDE5833),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    icon: _generating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.add, size: 20),
                    label: Text(
                      _generating ? 'Generating...' : 'Generate Alias',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () async {
                  await ref.read(ddgActionsProvider).logout();
                  if (context.mounted) {
                    showCitadelSnackBar(context, 'Logged out from DuckDuckGo');
                  }
                },
                icon: const Icon(Icons.logout, color: Color(0xFFDE5833)),
                tooltip: 'Logout',
              ),
            ],
          ),
        ),

        // Alias list
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    widget.searchQuery.isEmpty
                        ? 'No aliases yet. Generate one above.'
                        : 'No aliases match "${widget.searchQuery}".',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey.shade500,
                    ),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      _DdgAliasCard(alias: filtered[index]),
                ),
        ),
      ],
    );
  }

  Future<void> _generateAlias() async {
    setState(() => _generating = true);
    try {
      final alias = await ref.read(ddgActionsProvider).generateAlias();
      if (mounted) {
        showCitadelSnackBar(context, 'Created $alias',
            type: SnackBarType.success);
      }
    } on DdgAuthException catch (e) {
      if (mounted) {
        showCitadelSnackBar(context, e.message, type: SnackBarType.error);
      }
    } catch (e) {
      if (mounted) {
        showCitadelSnackBar(context, 'Failed: $e', type: SnackBarType.error);
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }
}

// ---------------------------------------------------------------------------
// DDG Alias Card
// ---------------------------------------------------------------------------

class _DdgAliasCard extends StatelessWidget {
  final String alias;
  const _DdgAliasCard({required this.alias});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Clipboard.setData(ClipboardData(text: alias));
          showCitadelSnackBar(context, 'Alias copied');
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFDE5833).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.alternate_email,
                    size: 18, color: Color(0xFFDE5833)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alias,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap to copy',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.copy, size: 18, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
