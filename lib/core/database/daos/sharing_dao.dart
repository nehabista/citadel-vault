import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/shared_items_table.dart';
import '../tables/vault_members_table.dart';
import '../tables/emergency_contacts_table.dart';

part 'sharing_dao.g.dart';

/// Data access object for sharing-related tables:
/// SharedItems, VaultMembers, and EmergencyContacts.
@DriftAccessor(tables: [SharedItems, VaultMembers, EmergencyContacts])
class SharingDao extends DatabaseAccessor<AppDatabase>
    with _$SharingDaoMixin {
  SharingDao(super.db);

  // ---------------------------------------------------------------------------
  // SharedItems
  // ---------------------------------------------------------------------------

  /// Get all shared items received by a user.
  Future<List<SharedItem>> getReceivedItems(String userId) {
    return (select(sharedItems)
          ..where((t) => t.recipientId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Get all shared items sent by a user.
  Future<List<SharedItem>> getSentItems(String userId) {
    return (select(sharedItems)
          ..where((t) => t.senderId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Insert or update a shared item.
  Future<void> upsertSharedItem(SharedItemsCompanion item) {
    return into(sharedItems).insertOnConflictUpdate(item);
  }

  /// Delete a shared item by ID.
  Future<void> deleteSharedItem(String id) {
    return (delete(sharedItems)..where((t) => t.id.equals(id))).go();
  }

  // ---------------------------------------------------------------------------
  // VaultMembers
  // ---------------------------------------------------------------------------

  /// Get all members of a vault.
  Future<List<VaultMember>> getVaultMembers(String vaultId) {
    return (select(vaultMembers)
          ..where((t) => t.vaultId.equals(vaultId)))
        .get();
  }

  /// Insert or update a vault member.
  Future<void> upsertVaultMember(VaultMembersCompanion member) {
    return into(vaultMembers).insertOnConflictUpdate(member);
  }

  /// Delete a vault member by ID.
  Future<void> deleteVaultMember(String id) {
    return (delete(vaultMembers)..where((t) => t.id.equals(id))).go();
  }

  // ---------------------------------------------------------------------------
  // EmergencyContacts
  // ---------------------------------------------------------------------------

  /// Get all emergency contacts for a user (as grantor or grantee).
  Future<List<EmergencyContact>> getEmergencyContacts(String userId) {
    return (select(emergencyContacts)
          ..where(
            (t) =>
                t.grantorId.equals(userId) | t.granteeId.equals(userId),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Insert or update an emergency contact.
  Future<void> upsertEmergencyContact(EmergencyContactsCompanion contact) {
    return into(emergencyContacts).insertOnConflictUpdate(contact);
  }
}
