// File: lib/features/sharing/presentation/widgets/emergency_contact_card.dart
// Card widget displaying an emergency contact with status-specific actions.
// Shows countdown timer, reject/revoke/request buttons based on role and status.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../presentation/widgets/citadel_snackbar.dart';
import '../../data/models/emergency_contact.dart';
import '../providers/emergency_providers.dart';

/// Displays an emergency contact with status badge and context-specific actions.
///
/// [isGrantor] determines whether the card shows grantor actions (reject, revoke)
/// or grantee actions (request access, view vault).
class EmergencyContactCard extends ConsumerWidget {
  final EmergencyContact contact;
  final bool isGrantor;

  const EmergencyContactCard({
    super.key,
    required this.contact,
    required this.isGrantor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(emergencyRepositoryProvider);
    final remaining = repo.remainingWaitTime(contact);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: contact info + status badge
            Row(
              children: [
                const Icon(Icons.person_outline,
                    color: Color(0xFF4D4DCD), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGrantor
                            ? 'Grantee: ${contact.granteeId}'
                            : 'Grantor: ${contact.grantorId}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        '${contact.waitingPeriodDays} day waiting period',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),

            const SizedBox(height: 12),

            // Countdown display for waiting status
            if (contact.status == 'waiting' && remaining != null)
              _buildCountdown(remaining),

            // Action buttons based on role and status
            _buildActions(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final (Color color, String label) = switch (contact.status) {
      'pending' => (Colors.grey, 'Pending'),
      'waiting' => (Colors.amber.shade700, 'Waiting'),
      'active' => (const Color(0xFF43A047), 'Active'),
      'rejected' => (const Color(0xFFE53935), 'Rejected'),
      'revoked' => (Colors.grey.shade600, 'Revoked'),
      _ => (Colors.grey, contact.status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCountdown(Duration remaining) {
    final isExpired = remaining.isNegative;
    final days = remaining.inDays.abs();
    final hours = (remaining.inHours % 24).abs();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isExpired ? Icons.check_circle : Icons.timer_outlined,
            size: 16,
            color: isExpired ? const Color(0xFF43A047) : Colors.amber.shade700,
          ),
          const SizedBox(width: 6),
          Text(
            isExpired
                ? 'Waiting period elapsed'
                : 'Access in $days days $hours hours',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color:
                  isExpired ? const Color(0xFF43A047) : Colors.amber.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    final repo = ref.read(emergencyRepositoryProvider);

    if (isGrantor) {
      return _buildGrantorActions(context, repo);
    } else {
      return _buildGranteeActions(context, ref, repo);
    }
  }

  Widget _buildGrantorActions(
      BuildContext context, EmergencyRepository repo) {
    return switch (contact.status) {
      'pending' => Row(
          children: [
            const Spacer(),
            TextButton.icon(
              onPressed: () async {
                // TODO: call service.deleteContact when wired
                showCitadelSnackBar(context, 'Contact removed');
              },
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Remove',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
            ),
          ],
        ),
      'waiting' => Row(
          children: [
            const Spacer(),
            FilledButton.icon(
              onPressed: () async {
                await repo.rejectRequest(contact.id);
                if (context.mounted) {
                  showCitadelSnackBar(context, 'Emergency access rejected');
                }
              },
              icon: const Icon(Icons.block, size: 16),
              label: const Text('Reject',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
              ),
            ),
          ],
        ),
      'active' => Row(
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: Color(0xFF43A047)),
                const SizedBox(width: 4),
                const Text('Access granted',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Color(0xFF43A047))),
              ],
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () async {
                await repo.revokeContact(contact.id);
                if (context.mounted) {
                  showCitadelSnackBar(context, 'Emergency access revoked');
                }
              },
              icon: const Icon(Icons.remove_circle_outline, size: 16),
              label: const Text('Revoke',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
              style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFE53935)),
            ),
          ],
        ),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildGranteeActions(
      BuildContext context, WidgetRef ref, EmergencyRepository repo) {
    return switch (contact.status) {
      'pending' => Row(
          children: [
            const Spacer(),
            FilledButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Request Emergency Access?',
                        style: TextStyle(fontFamily: 'Poppins')),
                    content: Text(
                      'This will start a ${contact.waitingPeriodDays}-day waiting period. '
                      'The vault owner will be notified and can reject your request.',
                      style: const TextStyle(fontFamily: 'Poppins'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel',
                            style: TextStyle(fontFamily: 'Poppins')),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                        ),
                        child: const Text('Request Access',
                            style: TextStyle(fontFamily: 'Poppins')),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await repo.requestAccess(contact.id);
                  if (context.mounted) {
                    showCitadelSnackBar(
                        context, 'Emergency access requested');
                  }
                }
              },
              icon: const Icon(Icons.emergency, size: 16),
              label: const Text('Request Access',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
              ),
            ),
          ],
        ),
      'waiting' => const SizedBox.shrink(), // Countdown shown above
      'active' => Row(
          children: [
            const Spacer(),
            FilledButton.icon(
              onPressed: () {
                // TODO: Navigate to vault view for emergency access
              },
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('View Vault',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF43A047),
              ),
            ),
          ],
        ),
      _ => const SizedBox.shrink(),
    };
  }
}
