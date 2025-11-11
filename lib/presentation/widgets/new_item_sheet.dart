// File: lib/presentation/widgets/new_item_sheet.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/vault/domain/entities/vault_item.dart';
import '../../routing/app_router.dart';

/// Bottom sheet with categorized list of item types for creating new vault items.
class NewItemBottomSheet extends StatelessWidget {
  const NewItemBottomSheet({super.key});

  static const _sections = <({String header, List<({IconData icon, String label, VaultItemType type})> items})>[
    (
      header: 'Logins & Notes',
      items: [
        (icon: Icons.lock_outline, label: 'Password', type: VaultItemType.password),
        (icon: Icons.sticky_note_2_outlined, label: 'Secure Note', type: VaultItemType.secureNote),
        (icon: Icons.contact_page_outlined, label: 'Contact Info', type: VaultItemType.contactInfo),
      ],
    ),
    (
      header: 'Financial',
      items: [
        (icon: Icons.credit_card_outlined, label: 'Payment Card', type: VaultItemType.paymentCard),
        (icon: Icons.account_balance_outlined, label: 'Bank Account', type: VaultItemType.bankAccount),
      ],
    ),
    (
      header: 'Identity Documents',
      items: [
        (icon: Icons.directions_car_outlined, label: 'Drivers License', type: VaultItemType.driversLicense),
        (icon: Icons.public_outlined, label: 'Passport', type: VaultItemType.passport),
        (icon: Icons.badge_outlined, label: 'Social Security Number', type: VaultItemType.socialSecurityNumber),
      ],
    ),
    (
      header: 'Insurance & Memberships',
      items: [
        (icon: Icons.health_and_safety_outlined, label: 'Health Insurance', type: VaultItemType.healthInsurance),
        (icon: Icons.umbrella_outlined, label: 'Insurance Policy', type: VaultItemType.insurancePolicy),
        (icon: Icons.card_membership_outlined, label: 'Membership Card', type: VaultItemType.membershipCard),
        (icon: Icons.wifi_outlined, label: 'WiFi Password', type: VaultItemType.wifiPassword),
      ],
    ),
    (
      header: 'Communication',
      items: [
        (icon: Icons.alternate_email, label: 'Email Account', type: VaultItemType.emailAccount),
        (icon: Icons.chat_outlined, label: 'Instant Messenger', type: VaultItemType.instantMessenger),
      ],
    ),
    (
      header: 'Infrastructure',
      items: [
        (icon: Icons.storage_outlined, label: 'Database', type: VaultItemType.database),
        (icon: Icons.dns_outlined, label: 'Server', type: VaultItemType.server),
        (icon: Icons.vpn_key_outlined, label: 'SSH Key', type: VaultItemType.sshKey),
        (icon: Icons.code_outlined, label: 'Software License', type: VaultItemType.softwareLicense),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Create New Item',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choose the type of item to add to your vault',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).padding.bottom + 24,
              ),
              itemCount: _sections.length,
              itemBuilder: (context, sectionIndex) {
                final section = _sections[sectionIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      child: Text(
                        section.header.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    ...section.items.map((item) => _NewItemListTile(
                          icon: item.icon,
                          label: item.label,
                          onTap: () {
                            Navigator.pop(context);
                            context.push(AppRoutes.vaultItemCreate, extra: item.type);
                          },
                        )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A single item type list tile in the new-item bottom sheet.
class _NewItemListTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NewItemListTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF4D4DCD).withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF4D4DCD)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
