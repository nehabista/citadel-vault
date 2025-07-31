import 'package:get/get.dart';
import '../data/services/api/pocketbase_service.dart';
import '../data/services/auth/auth_service.dart';
import '../data/services/auth/local_auth_service.dart';
import '../data/services/auth/session_service.dart';
import '../data/services/crypto/encryption_service.dart';
import '../data/services/vault/vault_service.dart';

/// Initializes all the core services of the application using GetX
/// for dependency injection. This setup ensures that services are available
/// throughout the app where needed.
class DependencyInjection {
  static Future<void> init() async {
    // Core Services (Lowest Level)
    // Get.put(PocketBaseService(), permanent: true);
    Get.put(EncryptionService(), permanent: true);
    Get.put(SessionService(), permanent: true);

    // Dependent Services
    Get.put(LocalAuthService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(VaultService(), permanent: true);
  }
}
