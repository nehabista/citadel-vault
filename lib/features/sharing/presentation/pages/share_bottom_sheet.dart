// File: lib/features/sharing/presentation/pages/share_bottom_sheet.dart
// Bottom sheet for sharing vault items via user-to-user or link-based sharing.
// Per D-05, D-06, D-20.

import 'package:flutter/material.dart';
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

  bool _isSharing = false;

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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4D4DCD).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF4D4DCD).withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4D4DCD).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.link_off,
                    color: Color(0xFF4D4DCD),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Link Sharing Coming in v2',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Shareable links for non-Citadel users require a web '
                  'frontend to decrypt shared data. This feature is planned '
                  'for a future release.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    height: 1.5,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(
                      'Use "Citadel User" tab to share securely now',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
