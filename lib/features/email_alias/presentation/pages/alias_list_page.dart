// File: lib/features/email_alias/presentation/pages/alias_list_page.dart
// Alias list page with tabs for SimpleLogin and DuckDuckGo providers.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ddg_signup_webview.dart';

import '../../../../presentation/widgets/citadel_snackbar.dart';
import '../../data/models/alias_model.dart';
import '../../data/services/duckduckgo_alias_service.dart';
import '../../data/services/simple_login_service.dart';
import '../providers/alias_providers.dart';
import '../widgets/create_alias_sheet.dart';

class AliasListPage extends ConsumerStatefulWidget {
  const AliasListPage({super.key});

  @override
  ConsumerState<AliasListPage> createState() => _AliasListPageState();
}

class _AliasListPageState extends ConsumerState<AliasListPage>
    with SingleTickerProviderStateMixin {
  bool _showSearch = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_showSearch) {
        setState(() {
          _showSearch = false;
          _searchQuery = '';
          _searchController.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Search aliases...',
                  hintStyle: TextStyle(fontFamily: 'Poppins'),
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : const Text(
                'Email Aliases',
                style: TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.w600),
              ),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4D4DCD),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4D4DCD),
          labelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'SimpleLogin'),
            Tab(text: 'DuckDuckGo'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SimpleLoginTab(searchQuery: _searchQuery),
          _DuckDuckGoTab(searchQuery: _searchQuery),
        ],
      ),
      floatingActionButton: ListenableBuilder(
        listenable: _tabController,
        builder: (context, _) {
          // Only show FAB for SimpleLogin tab when API key is configured
          if (_tabController.index == 0) {
            final apiKeyAsync = ref.watch(aliasApiKeyProvider);
            if (apiKeyAsync.value != null) {
              return FloatingActionButton(
                backgroundColor: const Color(0xFF4D4DCD),
                onPressed: () => _showCreateSheet(context),
                child: const Icon(Icons.add, color: Colors.white),
              );
            }
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const CreateAliasSheet(),
    );
  }
}

// ===========================================================================
// SimpleLogin Tab
// ===========================================================================

class _SimpleLoginTab extends ConsumerWidget {
  final String searchQuery;
  const _SimpleLoginTab({required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiKeyAsync = ref.watch(aliasApiKeyProvider);

    return apiKeyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          'Error loading API key: $e',
          style: const TextStyle(fontFamily: 'Poppins', color: Colors.red),
        ),
      ),
      data: (apiKey) {
        if (apiKey == null) return _ApiKeySetupView();
        return _AliasListView(searchQuery: searchQuery);
      },
    );
  }
}

// ===========================================================================
// DuckDuckGo Tab
// ===========================================================================

class _DuckDuckGoTab extends ConsumerWidget {
  final String searchQuery;
  const _DuckDuckGoTab({required this.searchQuery});

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

// ===========================================================================
// SimpleLogin: API Key Setup View (shown when no key is configured)
// ===========================================================================

class _ApiKeySetupView extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ApiKeySetupView> createState() => _ApiKeySetupViewState();
}

class _ApiKeySetupViewState extends ConsumerState<_ApiKeySetupView> {
  final _keyController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.alternate_email,
              size: 64, color: Color(0xFF4D4DCD)),
          const SizedBox(height: 16),
          const Text(
            'Connect SimpleLogin',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your SimpleLogin API key to manage email aliases.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _keyController,
            decoration: InputDecoration(
              labelText: 'API Key',
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
                    const BorderSide(color: Color(0xFF4D4DCD), width: 2),
              ),
              prefixIcon:
                  const Icon(Icons.vpn_key, color: Color(0xFF4D4DCD)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saving
                  ? null
                  : () async {
                      final key = _keyController.text.trim();
                      if (key.isEmpty) return;
                      setState(() => _saving = true);
                      try {
                        await ref.read(aliasActionsProvider).saveApiKey(key);
                        if (context.mounted) {
                          showCitadelSnackBar(context, 'API key saved',
                              type: SnackBarType.success);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          showCitadelSnackBar(context, 'Failed to save: $e',
                              type: SnackBarType.error);
                        }
                      } finally {
                        if (mounted) setState(() => _saving = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4D4DCD),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              launchUrl(Uri.parse('https://simplelogin.io'));
            },
            child: const Text(
              "Don't have an account? Sign up at simplelogin.io",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Color(0xFF4D4DCD),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// SimpleLogin: Alias List View (shown when API key is configured)
// ===========================================================================

class _AliasListView extends ConsumerWidget {
  final String searchQuery;
  const _AliasListView({required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aliasesAsync = ref.watch(aliasListProvider);

    return aliasesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) {
        if (e is InvalidApiKeyException) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  const Text(
                    'Invalid API key. Please check your key in Settings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () async {
                      await ref.read(aliasActionsProvider).removeApiKey();
                    },
                    child: const Text(
                      'Re-enter API Key',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFF4D4DCD),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Center(
          child: Text(
            'Error: $e',
            style:
                const TextStyle(fontFamily: 'Poppins', color: Colors.red),
          ),
        );
      },
      data: (aliases) {
        final filtered = searchQuery.isEmpty
            ? aliases
            : aliases
                .where((a) => a.email
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
                .toList();

        if (filtered.isEmpty) {
          return Center(
            child: Text(
              searchQuery.isEmpty
                  ? 'No aliases yet. Tap + to create one.'
                  : 'No aliases match "$searchQuery".',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey.shade500,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(aliasListProvider),
          child: ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filtered.length,
            itemBuilder: (context, index) =>
                _AliasCard(alias: filtered[index]),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// SimpleLogin: Alias Card
// ---------------------------------------------------------------------------

class _AliasCard extends ConsumerWidget {
  final AliasModel alias;
  const _AliasCard({required this.alias});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Clipboard.setData(ClipboardData(text: alias.email));
          showCitadelSnackBar(context, 'Alias copied');
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alias.email,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _StatusBadge(enabled: alias.enabled),
                        const SizedBox(width: 10),
                        _StatChip(
                            icon: Icons.forward, count: alias.nbForward),
                        const SizedBox(width: 6),
                        _StatChip(icon: Icons.block, count: alias.nbBlock),
                        const SizedBox(width: 6),
                        _StatChip(icon: Icons.reply, count: alias.nbReply),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(alias.createdAt),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) =>
                    _handleMenuAction(context, ref, value),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'toggle',
                    child: Text('Toggle',
                        style: TextStyle(fontFamily: 'Poppins')),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete',
                        style: TextStyle(
                            fontFamily: 'Poppins', color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(
      BuildContext context, WidgetRef ref, String action) async {
    final actions = ref.read(aliasActionsProvider);
    switch (action) {
      case 'toggle':
        try {
          final enabled = await actions.toggle(alias.id);
          if (context.mounted) {
            showCitadelSnackBar(
              context,
              enabled ? 'Alias activated' : 'Alias deactivated',
            );
          }
        } catch (e) {
          if (context.mounted) {
            showCitadelSnackBar(context, 'Toggle failed: $e',
                type: SnackBarType.error);
          }
        }
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Alias',
                style: TextStyle(fontFamily: 'Poppins')),
            content: Text(
              'Permanently delete ${alias.email}? This cannot be undone.',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel',
                    style: TextStyle(fontFamily: 'Poppins')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete',
                    style: TextStyle(
                        fontFamily: 'Poppins', color: Colors.red)),
              ),
            ],
          ),
        );
        if (confirm == true) {
          try {
            await actions.delete(alias.id);
            if (context.mounted) {
              showCitadelSnackBar(context, 'Alias deleted');
            }
          } catch (e) {
            if (context.mounted) {
              showCitadelSnackBar(context, 'Delete failed: $e',
                  type: SnackBarType.error);
            }
          }
        }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// ---------------------------------------------------------------------------
// Small UI components
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  final bool enabled;
  const _StatusBadge({required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: enabled
            ? const Color(0xFF43A047).withValues(alpha: 0.12)
            : const Color(0xFFE53935).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        enabled ? 'Active' : 'Inactive',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color:
              enabled ? const Color(0xFF43A047) : const Color(0xFFE53935),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final int count;
  const _StatChip({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade500),
        const SizedBox(width: 2),
        Text(
          '$count',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
