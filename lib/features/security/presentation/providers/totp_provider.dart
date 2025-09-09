import 'dart:async';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/session/session_state.dart';
import '../../data/models/totp_entry_entity.dart';

// ---------------------------------------------------------------------------
// TOTP entries for a vault item
// ---------------------------------------------------------------------------

/// Fetches all TOTP entries for a given vault item ID.
///
/// Requires an unlocked session to decrypt the TOTP secrets.
final totpEntriesProvider =
    FutureProvider.family<List<TotpEntryEntity>, String>(
        (ref, vaultItemId) async {
  final session = ref.watch(sessionProvider);
  if (session is! Unlocked) return [];

  final vaultKey = SecretKey(session.vaultKey);
  final repo = ref.read(totpRepositoryProvider);
  return repo.getByVaultItemId(vaultItemId, vaultKey);
});

// ---------------------------------------------------------------------------
// TOTP countdown display state
// ---------------------------------------------------------------------------

/// Immutable state for a single TOTP countdown display.
class TotpDisplayState {
  final String code;
  final int remainingSeconds;
  final int totalPeriod;

  const TotpDisplayState({
    this.code = '',
    this.remainingSeconds = 0,
    this.totalPeriod = 30,
  });
}

/// Parameters to identify a specific TOTP countdown.
class TotpDisplayParams {
  final String entryId;
  final String base32Secret;
  final int digits;
  final int period;
  final String algorithm;

  const TotpDisplayParams({
    required this.entryId,
    required this.base32Secret,
    this.digits = 6,
    this.period = 30,
    this.algorithm = 'SHA1',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TotpDisplayParams &&
          runtimeType == other.runtimeType &&
          entryId == other.entryId;

  @override
  int get hashCode => entryId.hashCode;
}

/// Manages a TOTP countdown as a stream, emitting new state every second.
///
/// Generates a new code when the period boundary is crossed and
/// counts down remaining seconds. Auto-disposes when no longer watched.
final totpDisplayProvider = StreamProvider.autoDispose
    .family<TotpDisplayState, TotpDisplayParams>((ref, params) {
  final service = ref.read(totpServiceProvider);

  TotpDisplayState tick() {
    final code = service.generateCode(
      base32Secret: params.base32Secret,
      digits: params.digits,
      period: params.period,
      algorithm: params.algorithm,
    );
    final remaining = service.remainingSeconds(period: params.period);
    return TotpDisplayState(
      code: code,
      remainingSeconds: remaining,
      totalPeriod: params.period,
    );
  }

  // Emit initial state immediately, then every second.
  return Stream.periodic(const Duration(seconds: 1), (_) => tick())
      .transform(StreamTransformer.fromBind((stream) async* {
    yield tick(); // Emit immediately
    yield* stream;
  }));
});
