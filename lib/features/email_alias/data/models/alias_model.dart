/// SimpleLogin alias model per D-11.
///
/// Maps to the SimpleLogin API response for alias objects.
/// See: https://github.com/nicepkg/simplelogin-api-doc
class AliasModel {
  final int id;
  final String email;
  final String? name;
  final bool enabled;
  final int creationTimestamp;
  final int nbForward;
  final int nbBlock;
  final int nbReply;
  final String? note;

  const AliasModel({
    required this.id,
    required this.email,
    this.name,
    required this.enabled,
    required this.creationTimestamp,
    this.nbForward = 0,
    this.nbBlock = 0,
    this.nbReply = 0,
    this.note,
  });

  factory AliasModel.fromJson(Map<String, dynamic> json) => AliasModel(
        id: json['id'] as int,
        email: json['email'] as String,
        name: json['name'] as String?,
        enabled: json['enabled'] as bool? ?? true,
        creationTimestamp: json['creation_timestamp'] as int? ?? 0,
        nbForward: json['nb_forward'] as int? ?? 0,
        nbBlock: json['nb_block'] as int? ?? 0,
        nbReply: json['nb_reply'] as int? ?? 0,
        note: json['note'] as String?,
      );

  /// Creation date derived from the Unix timestamp.
  DateTime get createdAt =>
      DateTime.fromMillisecondsSinceEpoch(creationTimestamp * 1000);
}
