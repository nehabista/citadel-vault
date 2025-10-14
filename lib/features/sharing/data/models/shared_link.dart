import 'package:pocketbase/pocketbase.dart';

/// Model representing a link-based shared item.
///
/// Maps to the `shared_links` PocketBase collection (per D-04, D-06).
/// The decryption key is NOT stored server-side -- it lives only in
/// the URL fragment, so the server never has access to plaintext.
class SharedLink {
  /// Unique identifier (PocketBase record ID).
  final String id;

  /// Base64-encoded encrypted item data (AES-256-GCM blob).
  final String encryptedData;

  /// ID of the user who created the link.
  final String creatorId;

  /// When the link expires and becomes inaccessible.
  final DateTime expiresAt;

  /// If true, the link is destroyed after a single view.
  final bool oneTimeView;

  /// Whether the link has been viewed (only relevant if [oneTimeView] is true).
  final bool viewed;

  /// When the link was created.
  final DateTime createdAt;

  const SharedLink({
    required this.id,
    required this.encryptedData,
    required this.creatorId,
    required this.expiresAt,
    this.oneTimeView = false,
    this.viewed = false,
    required this.createdAt,
  });

  /// Deserialize from a PocketBase RecordModel.
  factory SharedLink.fromRecord(RecordModel record) {
    return SharedLink(
      id: record.id,
      encryptedData: record.getStringValue('encryptedData'),
      creatorId: record.getStringValue('creatorId'),
      expiresAt: DateTime.parse(record.getStringValue('expiresAt')),
      oneTimeView: record.getBoolValue('oneTimeView'),
      viewed: record.getBoolValue('viewed'),
      createdAt: DateTime.parse(record.getStringValue('created')),
    );
  }

  /// Serialize to a PocketBase request body.
  Map<String, dynamic> toBody() {
    return {
      'encryptedData': encryptedData,
      'creatorId': creatorId,
      'expiresAt': expiresAt.toUtc().toIso8601String(),
      'oneTimeView': oneTimeView,
      'viewed': viewed,
    };
  }

  SharedLink copyWith({
    String? id,
    String? encryptedData,
    String? creatorId,
    DateTime? expiresAt,
    bool? oneTimeView,
    bool? viewed,
    DateTime? createdAt,
  }) {
    return SharedLink(
      id: id ?? this.id,
      encryptedData: encryptedData ?? this.encryptedData,
      creatorId: creatorId ?? this.creatorId,
      expiresAt: expiresAt ?? this.expiresAt,
      oneTimeView: oneTimeView ?? this.oneTimeView,
      viewed: viewed ?? this.viewed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
