// Custom exception for handling biometric lockouts.
class BiometricLockoutException implements Exception {
  final String message = "Biometric authentication is temporarily locked.";
}
