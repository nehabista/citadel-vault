/// Strength classification for passwords.
enum Strength { weak, moderate, strong }

/// Result of checking a password against character-pool rules.
class PasswordChecks {
  final bool longEnough;
  final bool hasUpper;
  final bool hasLower;
  final bool hasDigit;
  final bool hasSpecial;

  const PasswordChecks({
    required this.longEnough,
    required this.hasUpper,
    required this.hasLower,
    required this.hasDigit,
    required this.hasSpecial,
  });

  int get passedCount =>
      [longEnough, hasUpper, hasLower, hasDigit, hasSpecial]
          .where((b) => b)
          .length;
}
