// File: lib/features/sharing/presentation/pages/share_bottom_sheet.dart
// Bottom sheet for sharing vault items via user-to-user or link-based sharing.
// Per D-05, D-06, D-20.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../presentation/widgets/citadel_snackbar.dart';
import '../providers/sharing_providers.dart';
import '../widgets/share_user_picker.dart';

/// Bottom sheet that offers two sharing modes:
/// 1. Share with a Citadel user (X25519 encrypted transfer)
/// 2. Create a shareable link (time-limited, optional one-time view)
///
/// Opened from the vault item detail page's share button.
class ShareBottomSheet extends ConsumerStatefulWidget {
  /// The decrypted vault item data to be shared.
  final Map<String, dynamic> itemData;

  const ShareBottomSheet({
    super.key,
    required this.itemData,
  });

  /// Show as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> itemData,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareBottomSheet(itemData: itemData),
    );
  }

  @override
  ConsumerState<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends ConsumerState<ShareBottomSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Link sharing state.
  Duration _selectedTtl = const Duration(hours: 24);
  bool _oneTimeView = false;
  bool _isCreatingLink = false;
  String? _generatedLink;
  bool _isSharing = false;

  static const _ttlOptions = [
    (label: '1 hour', duration: Duration(hours: 1)),
    (label: '24 hours', duration: Duration(hours: 24)),
    (label: '7 days', duration: Duration(days: 7)),
    (label: '30 days', duration: Duration(days: 30)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _shareWithUser(String userId, String email) async {
    setState(() => _isSharing = true);
    try {
      final repo = ref.read(sharingRepositoryProvider);
      await repo.shareItemWithUser(
        recipientEmail: email,
        itemData: widget.itemData,
      );
      if (mounted) {
        showCitadelSnackBar(
          context,
          'Item shared successfully',
          type: SnackBarType.success,
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showCitadelSnackBar(
          context,
          'Failed to share: ${e.toString().replaceAll('SharingRepositoryException: ', '')}',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _createShareLink() async {
    setState(() {
      _isCreatingLink = true;
      _generatedLink = null;
    });

    try {
      final repo = ref.read(sharingRepositoryProvider);
      final link = await repo.createShareLink(
        itemData: widget.itemData,
        ttl: _selectedTtl,
        oneTimeView: _oneTimeView,
      );
      setState(() {
        _generatedLink = link;
        _isCreatingLink = false;
      });
    } catch (e) {
      if (mounted) {
        showCitadelSnackBar(
          context,
          'Failed to create link',
          type: SnackBarType.error,
        );
      }
      setState(() => _isCreatingLink = false);
    }
  }

  void _copyLink() {
    if (_generatedLink == null) return;
    Clipboard.setData(ClipboardData(text: _generatedLink!));
    showCitadelSnackBar(
      context,
      'Link copied to clipboard',
      type: SnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle.
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title.
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              'Share Item',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),

          // Tab bar.
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF4D4DCD),
            unselectedLabelColor: Colors.grey.shade500,
            indicatorColor: const Color(0xFF4D4DCD),
            labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Citadel User'),
              Tab(text: 'Shareable Link'),
            ],
          ),

          // Tab content.
          SizedBox(
            height: 320,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUserShareTab(),
                _buildLinkShareTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserShareTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Share with Citadel User',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'End-to-end encrypted using X25519 key exchange',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          ShareUserPicker(
            onUserSelected: _isSharing ? (_, __) {} : _shareWithUser,
          ),
          if (_isSharing) ...[
            const SizedBox(height: 16),
            const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation(Color(0xFF4D4DCD)),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Encrypting and sharing...',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Color(0xFF4D4DCD),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLinkShareTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create Shareable Link',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Decryption key stays in the URL fragment (never sent to server)',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),

          // TTL dropdown.
          const Text(
            'Link expires after',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Duration>(
                value: _selectedTtl,
                isExpanded: true,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                items: _ttlOptions
                    .map(
                      (opt) => DropdownMenuItem(
                        value: opt.duration,
                        child: Text(opt.label),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedTtl = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // One-time view checkbox.
          CheckboxListTile(
            value: _oneTimeView,
            onChanged: (val) =>
                setState(() => _oneTimeView = val ?? false),
            title: const Text(
              'One-time view',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
              ),
            ),
            subtitle: Text(
              'Link expires after first access',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: const Color(0xFF4D4DCD),
            dense: true,
          ),
          const SizedBox(height: 12),

          // Create link button or generated link display.
          if (_generatedLink == null)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isCreatingLink ? null : _createShareLink,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4D4DCD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: _isCreatingLink
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.link, size: 18),
                label: Text(
                  _isCreatingLink ? 'Creating...' : 'Create Link',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4D4DCD).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF4D4DCD).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _generatedLink!,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Color(0xFF4D4DCD),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.copy,
                      color: Color(0xFF4D4DCD),
                      size: 20,
                    ),
                    onPressed: _copyLink,
                    tooltip: 'Copy link',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
