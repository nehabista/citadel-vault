import 'dart:math';

/// Generate a random hex ID (32 chars) for new vault items.
String generateVaultItemId() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
