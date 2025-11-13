// File: lib/features/sharing/presentation/pages/emergency_access_page.dart
// Emergency access management page with grantor and grantee sections.
// Per D-22: accessible from Settings page.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/emergency_contact.dart';
import '../providers/emergency_providers.dart';
import '../widgets/emergency_contact_card.dart';
import '../widgets/emergency_request_dialog.dart';

/// Page for managing emergency access contacts.
///
/// Displays two sections:
/// - "Trusted by Me" (grantor): contacts who can request access to your vault
/// - "I'm Trusted By" (grantee): vaults you can request emergency access to
///
/// Accessible from the Settings page per D-22.
class EmergencyAccessPage extends ConsumerWidget {
  const EmergencyAccessPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grantorContacts = ref.watch(grantorContactsProvider);
    final granteeContacts = ref.watch(granteeContactsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Emergency Access',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4D4DCD)),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF4D4DCD),
        onRefresh: () async {
          ref.invalidate(grantorContactsProvider);
          ref.invalidate(granteeContactsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            // Info card
            _buildInfoCard(),

            const SizedBox(height: 16),

            // Grantor section: "Trusted by Me"
            _buildSectionHeader('Trusted by Me'),
            const SizedBox(height: 4),
            _buildSectionSubtitle(
                'Contacts who can request access to your vault'),
            grantorContacts.when(
              data: (contacts) => contacts.isEmpty
                  ? _buildEmptyState(
                      'No emergency contacts added. Add a trusted contact '
                      'who can request access to your vault in case of emergency.',
                      Icons.shield_outlined,
                    )
                  : _buildContactList(contacts, isGrantor: true),
              loading: () => _buildLoading(),
              error: (e, _) => _buildEmptyState(
                'No emergency contacts yet. Add a trusted contact to get started.',
                Icons.shield_outlined,
              ),
            ),

            const SizedBox(height: 24),

            // Grantee section: "I'm Trusted By"
            _buildSectionHeader("I'm Trusted By"),
            const SizedBox(height: 4),
            _buildSectionSubtitle(
                'Vaults you can request emergency access to'),
            granteeContacts.when(
              data: (contacts) => contacts.isEmpty
                  ? _buildEmptyState(
                      'No one has added you as an emergency contact yet.',
                      Icons.people_outline,
                    )
                  : _buildContactList(contacts, isGrantor: false),
              loading: () => _buildLoading(),
              error: (e, _) => _buildEmptyState(
                'No one has added you as an emergency contact yet.',
                Icons.people_outline,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const EmergencyRequestDialog(),
          );
        },
        backgroundColor: const Color(0xFF4D4DCD),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Add Trusted Contact',
          style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4D4DCD).withValues(alpha: 0.08),
            const Color(0xFF4D4DCD).withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF4D4DCD).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4D4DCD).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.emergency,
                color: Color(0xFF4D4DCD), size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Emergency access allows trusted contacts to request read-only '
              'access to your vault. You\'ll be notified in-app and can reject '
              'the request during a configurable waiting period.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                height: 1.5,
                color: Color(0xFF3A3A5C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Color(0xFF4D4DCD),
        ),
      ),
    );
  }

  Widget _buildSectionSubtitle(String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        subtitle,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildContactList(List<EmergencyContact> contacts,
      {required bool isGrantor}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: contacts
            .map((contact) => EmergencyContactCard(
                  contact: contact,
                  isGrantor: isGrantor,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: CircularProgressIndicator(color: Color(0xFF4D4DCD)),
      ),
    );
  }

}
