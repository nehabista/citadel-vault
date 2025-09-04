/// Model representing a data breach record from HIBP.
///
/// Ported from Protego project with added toJson() for cache serialization.
class BreachRecord {
  final String name;
  final String title;
  final String domain;
  final DateTime breachDate;
  final DateTime? addedDate;
  final DateTime? modifiedDate;
  final List<String> dataClasses;
  final bool verified;
  final bool isSensitive;
  final int? pwnCount;
  final String? description;
  final String? logoUrl;

  BreachRecord({
    required this.name,
    required this.title,
    required this.domain,
    required this.breachDate,
    required this.dataClasses,
    required this.verified,
    required this.isSensitive,
    this.addedDate,
    this.modifiedDate,
    this.pwnCount,
    this.description,
    this.logoUrl,
  });

  factory BreachRecord.fromJson(Map<String, dynamic> json) {
    DateTime? parseDt(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      return DateTime.tryParse(s);
    }

    return BreachRecord(
      name: (json['Name'] ?? '').toString(),
      title: (json['Title'] ?? '').toString(),
      domain: (json['Domain'] ?? '').toString(),
      breachDate: parseDt(json['BreachDate']) ?? DateTime(1970),
      addedDate: parseDt(json['AddedDate']),
      modifiedDate: parseDt(json['ModifiedDate']),
      dataClasses: (json['DataClasses'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      verified: (json['IsVerified'] as bool?) ?? true,
      isSensitive: (json['IsSensitive'] as bool?) ?? false,
      pwnCount: json['PwnCount'] is int ? json['PwnCount'] as int : null,
      description: (json['Description'] as String?)?.toString(),
      logoUrl: (json['LogoPath'] as String?)?.toString(),
    );
  }

  /// Serialize to JSON map for cache storage.
  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Title': title,
      'Domain': domain,
      'BreachDate': breachDate.toIso8601String(),
      if (addedDate != null) 'AddedDate': addedDate!.toIso8601String(),
      if (modifiedDate != null)
        'ModifiedDate': modifiedDate!.toIso8601String(),
      'DataClasses': dataClasses,
      'IsVerified': verified,
      'IsSensitive': isSensitive,
      if (pwnCount != null) 'PwnCount': pwnCount,
      if (description != null) 'Description': description,
      if (logoUrl != null) 'LogoPath': logoUrl,
    };
  }

  /// Prefer human title when present.
  String get displayTitle => title.isNotEmpty ? title : name;

  /// Plaintext description helper (strips basic HTML).
  String get descriptionPlain {
    final d = description ?? '';
    final noTags = d.replaceAll(RegExp(r'<[^>]*>'), '');
    return noTags
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }
}
