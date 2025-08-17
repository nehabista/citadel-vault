import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/crypto/crypto_migration.dart';
import '../../../../core/providers/migration_provider.dart';

/// Migration progress page shown during v1-to-v2 crypto upgrade.
///
/// Displays progress bar, item count, and current item name.
/// Back navigation is disabled during migration to prevent user confusion
/// (migration is safe to interrupt per D-13, but the UI flow is clearer
/// without allowing back).
class MigrationPage extends ConsumerStatefulWidget {
  /// Master password passed from unlock screen for key derivation.
  final String masterPassword;

  /// Salt for key derivation (base64-encoded).
  final String salt;

  const MigrationPage({
    super.key,
    required this.masterPassword,
    required this.salt,
  });

  @override
  ConsumerState<MigrationPage> createState() => _MigrationPageState();
}

class _MigrationPageState extends ConsumerState<MigrationPage> {
  bool _migrationStarted = false;

  @override
  void initState() {
    super.initState();
    // Start migration after the first frame to avoid build-phase side effects
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_migrationStarted) {
        _migrationStarted = true;
        ref.read(migrationProvider.notifier).startMigration(
              widget.masterPassword,
              widget.salt,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final migrationState = ref.watch(migrationProvider);

    // Navigate to home when migration completes
    ref.listen<MigrationState>(migrationProvider, (previous, next) {
      if (next is MigrationComplete && next.errors == 0) {
        context.go('/home');
      }
    });

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xff1A1A2E),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Shield icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xff4D4DCD).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.security_update_good_rounded,
                    size: 40,
                    color: Color(0xff4D4DCD),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'Upgrading your vault security...',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'Your passwords are being upgraded to stronger encryption. '
                  'This is a one-time process.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Progress section
                _buildProgressSection(migrationState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(MigrationState migrationState) {
    return switch (migrationState) {
      MigrationIdle() => _buildProgressIndicator(
          progress: 0.0,
          statusText: 'Preparing migration...',
        ),
      MigrationInProgress(:final progress) => _buildProgressIndicator(
          progress: progress.percent,
          statusText: _progressText(progress),
          itemName: progress.currentItemName,
        ),
      MigrationComplete(:final totalMigrated, :final errors) =>
        _buildCompleteSection(totalMigrated, errors),
      MigrationFailed(:final error) => _buildErrorSection(error),
    };
  }

  Widget _buildProgressIndicator({
    required double progress,
    required String statusText,
    String? itemName,
  }) {
    return Column(
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.white12,
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xff4D4DCD)),
          ),
        ),
        const SizedBox(height: 16),

        // Percentage
        Text(
          '${(progress * 100).toInt()}%',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: const Color(0xff4D4DCD),
          ),
        ),
        const SizedBox(height: 8),

        // Status text
        Text(
          statusText,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),

        // Current item name
        if (itemName != null && itemName.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            itemName,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white38,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildCompleteSection(int totalMigrated, int errors) {
    if (errors > 0) {
      return Column(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 48,
            color: Colors.orangeAccent,
          ),
          const SizedBox(height: 16),
          Text(
            'Migration completed with $errors error(s)',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.orangeAccent,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '$totalMigrated items upgraded successfully.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Retry button
              OutlinedButton(
                onPressed: () {
                  ref.read(migrationProvider.notifier).startMigration(
                        widget.masterPassword,
                        widget.salt,
                      );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xff4D4DCD),
                  side: const BorderSide(color: Color(0xff4D4DCD)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Retry',
                  style: GoogleFonts.poppins(),
                ),
              ),
              const SizedBox(width: 16),
              // Continue button
              ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff4D4DCD),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Success: auto-navigated by ref.listen above
    return Column(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          size: 48,
          color: Colors.greenAccent,
        ),
        const SizedBox(height: 16),
        Text(
          'Upgrade complete!',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.greenAccent,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$totalMigrated items upgraded to stronger encryption.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorSection(String error) {
    return Column(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 48,
          color: Colors.redAccent,
        ),
        const SizedBox(height: 16),
        Text(
          'Migration failed',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.redAccent,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          error,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.white54,
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            ref.read(migrationProvider.notifier).startMigration(
                  widget.masterPassword,
                  widget.salt,
                );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff4D4DCD),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Retry Migration',
            style: GoogleFonts.poppins(),
          ),
        ),
      ],
    );
  }

  String _progressText(MigrationProgress progress) {
    if (progress.total == 0) return 'Scanning vault...';
    return 'Upgrading item ${progress.current} of ${progress.total}...';
  }
}
