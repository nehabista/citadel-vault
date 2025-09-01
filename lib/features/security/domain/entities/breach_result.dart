/// Sealed class representing the result of a breach check on a password.
///
/// - [BreachResultNotChecked]: Password has not been checked yet.
/// - [BreachResultClean]: Password was not found in any breach.
/// - [BreachResultBreached]: Password was found in [count] breaches.
sealed class BreachResult {
  const BreachResult();

  const factory BreachResult.notChecked() = BreachResultNotChecked;
  const factory BreachResult.clean() = BreachResultClean;
  const factory BreachResult.breached(int count) = BreachResultBreached;
}

/// Password has not been checked against breach databases.
class BreachResultNotChecked extends BreachResult {
  const BreachResultNotChecked();
}

/// Password was not found in any known breach.
class BreachResultClean extends BreachResult {
  const BreachResultClean();
}

/// Password was found in [count] known breaches.
class BreachResultBreached extends BreachResult {
  final int count;
  const BreachResultBreached(this.count);
}
