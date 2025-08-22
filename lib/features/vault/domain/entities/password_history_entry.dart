/// Domain entity representing a decrypted password history entry.
///
/// Used by the presentation layer to display previous passwords
/// for a vault item.
class PasswordHistoryEntry {
  final String password;
  final DateTime changedAt;

  const PasswordHistoryEntry({
    required this.password,
    required this.changedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PasswordHistoryEntry &&
          runtimeType == other.runtimeType &&
          password == other.password &&
          changedAt == other.changedAt;

  @override
  int get hashCode => Object.hash(password, changedAt);

  @override
  String toString() =>
      'PasswordHistoryEntry(changedAt: $changedAt)';
}
