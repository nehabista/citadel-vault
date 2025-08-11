// File: lib/core/providers/core_providers.dart
// Core infrastructure providers for CryptoEngine, Database, and PocketBase
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../crypto/crypto_engine.dart';

/// Provides a singleton CryptoEngine instance.
final cryptoEngineProvider = Provider<CryptoEngine>((ref) => CryptoEngine());
