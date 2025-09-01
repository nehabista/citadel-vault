/// Types of custom fields that can be attached to vault items.
enum CustomFieldType { text, hidden, boolean }

/// A typed custom field attached to a vault item.
///
/// Custom fields allow users to store arbitrary key-value pairs
/// (e.g., API keys, security questions) with type information
/// controlling how the UI renders and protects the value.
class CustomField {
  final String name;
  final String value;
  final CustomFieldType type;

  const CustomField({
    required this.name,
    required this.value,
    required this.type,
  });

  /// Serialize to JSON map for storage in the encrypted blob.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'type': type.name,
    };
  }

  /// Deserialize from JSON map. Unknown types default to [CustomFieldType.text].
  factory CustomField.fromJson(Map<String, dynamic> json) {
    return CustomField(
      name: json['name'] as String? ?? '',
      value: json['value'] as String? ?? '',
      type: CustomFieldType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CustomFieldType.text,
      ),
    );
  }

  CustomField copyWith({
    String? name,
    String? value,
    CustomFieldType? type,
  }) {
    return CustomField(
      name: name ?? this.name,
      value: value ?? this.value,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomField &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          value == other.value &&
          type == other.type;

  @override
  int get hashCode => Object.hash(name, value, type);

  @override
  String toString() => 'CustomField(name: $name, type: $type)';
}
