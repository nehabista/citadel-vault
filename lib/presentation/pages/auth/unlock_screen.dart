// P2: Polished onboarding flow with smooth animations
// File: lib/presentation/pages/auth/unlock_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/session/pin_rate_limiter.dart';
import '../../../data/services/auth/local_auth_service.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../routing/app_router.dart';
import '../../widgets/citadel_snackbar.dart';

/// Unlock screen that shows either PIN pad or master password field
/// depending on whether quick unlock (PIN/biometric) is configured.
class UnlockScreen extends ConsumerStatefulWidget {
  const UnlockScreen({super.key});

  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends ConsumerState<UnlockScreen>
    with SingleTickerProviderStateMixin {
  static const int _pinLength = 6;
  static const Color _primaryColor = Color(0xFF4D4DCD);
  static const Color _errorColor = Color(0xFFE53935);

  // State
  final List<int> _enteredPin = [];
  final _masterPwController = TextEditingController();
  bool _isProcessing = false;
  bool _hasError = false;
  bool _biometricsAvailable = false;
  bool _biometricsConfigured = false;
  bool _hasQuickUnlock = false; // true = PIN mode, false = master password mode
  bool _loading = true;
  bool _obscureMasterPw = true;

  // PIN rate limiting
  final PinRateLimiter _rateLimiter = PinRateLimiter();
  Timer? _lockoutCountdownTimer;
  int _lockoutSecondsRemaining = 0;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) _shakeController.reset();
    });

    _detectUnlockMethod();
  }

  Future<void> _detectUnlockMethod() async {
    final localAuth = ref.read(localAuthServiceProvider);
    final hasSetup = await localAuth.hasQuickUnlockSetup();
    final canBio = await localAuth.canUseBiometrics();
    final unlockMethod = await localAuth.getSavedUnlockMethod();
    final bioConfigured = unlockMethod == UnlockMethod.biometrics;

    if (mounted) {
      setState(() {
        _hasQuickUnlock = hasSetup;
        _biometricsAvailable = canBio;
        _biometricsConfigured = bioConfigured;
        _loading = false;
      });

      // Auto-trigger biometric if available and configured
      if (bioConfigured && canBio) {
        _attemptBiometricUnlock();
      }
    }
  }

  // ─── Biometric ───
  Future<void> _attemptBiometricUnlock() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final success =
          await ref.read(authProvider.notifier).unlockWithBiometrics();
      if (success && mounted) context.go(AppRoutes.home);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ─── PIN ───
  void _onDigitTap(int digit) {
    if (_isProcessing || _enteredPin.length >= _pinLength) return;

    // Check if PIN is disabled for session (15+ failures).
    if (_rateLimiter.isPinDisabledForSession) {
      showCitadelSnackBar(
        context,
        'Too many failed attempts. Use your master password to unlock.',
        type: SnackBarType.error,
      );
      return;
    }

    // Check if currently locked out.
    if (_rateLimiter.isLockedOut) {
      final remaining = _rateLimiter.remainingLockout;
      showCitadelSnackBar(
        context,
        'Too many attempts. Try again in ${_formatLockoutTime(remaining.inSeconds)}',
        type: SnackBarType.error,
      );
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _hasError = false;
      _enteredPin.add(digit);
    });
    if (_enteredPin.length == _pinLength) _verifyPin();
  }

  void _onBackspace() {
    if (_isProcessing || _enteredPin.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _hasError = false;
      _enteredPin.removeLast();
    });
  }

  Future<void> _verifyPin() async {
    setState(() => _isProcessing = true);
    final pin = _enteredPin.join();
    final notifier = ref.read(authProvider.notifier);
    notifier.pinController.text = pin;
    final success = await notifier.unlockWithPin();
    if (success && mounted) {
      _rateLimiter.reset();
      context.go(AppRoutes.home);
    } else if (mounted) {
      // Record failure and check for lockout.
      final lockoutDuration = _rateLimiter.recordFailure();

      HapticFeedback.heavyImpact();
      setState(() {
        _hasError = true;
        _isProcessing = false;
      });
      _shakeController.forward();

      if (_rateLimiter.isPinDisabledForSession) {
        // 15+ failures: force master password mode.
        showCitadelSnackBar(
          context,
          'PIN disabled. Use your master password to unlock.',
          type: SnackBarType.error,
        );
        setState(() {
          _hasQuickUnlock = false;
          _enteredPin.clear();
        });
      } else if (lockoutDuration > Duration.zero) {
        // Show lockout countdown.
        _startLockoutCountdown(lockoutDuration);
        showCitadelSnackBar(
          context,
          'Too many attempts. Locked for ${_formatLockoutTime(lockoutDuration.inSeconds)}',
          type: SnackBarType.error,
        );
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) setState(() => _enteredPin.clear());
        });
      } else {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) setState(() => _enteredPin.clear());
        });
      }
    }
  }

  // ─── Master Password ───
  Future<void> _unlockWithMasterPassword() async {
    final masterPw = _masterPwController.text.trim();
    if (masterPw.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _hasError = false;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final user = authService.currentUser;
      if (user == null) {
        // Shouldn't happen — splash loaded the user. Fallback to login.
        if (mounted) context.go(AppRoutes.login);
        return;
      }

      // Derive vault key and unlock session
      final sessionNotifier = ref.read(sessionProvider.notifier);
      await sessionNotifier.unlock(masterPw, user.salt);

      if (mounted) context.go(AppRoutes.home);
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isProcessing = false;
        });
        _shakeController.forward();
      }
    }
  }

  /// Start a visual countdown timer for lockout feedback.
  void _startLockoutCountdown(Duration lockoutDuration) {
    _lockoutCountdownTimer?.cancel();
    _lockoutSecondsRemaining = lockoutDuration.inSeconds;
    _lockoutCountdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _lockoutSecondsRemaining--;
          if (_lockoutSecondsRemaining <= 0) {
            _lockoutSecondsRemaining = 0;
            timer.cancel();
          }
        });
      },
    );
  }

  /// Format seconds into mm:ss display.
  String _formatLockoutTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
    }
    return '${seconds}s';
  }

  @override
  void dispose() {
    _lockoutCountdownTimer?.cancel();
    _shakeController.dispose();
    _masterPwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: _primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _hasQuickUnlock ? _buildPinMode() : _buildMasterPasswordMode(),
      ),
    );
  }

  // ─── Master Password Mode ───
  Widget _buildMasterPasswordMode() {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.12),

          // Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _primaryColor.withAlpha(20),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.shield_rounded,
                size: 44, color: _primaryColor),
          ),
          const SizedBox(height: 24),

          const Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your master password to unlock',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 40),

          // Master password field
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              final offset = _shakeAnimation.value *
                  12 *
                  _shakeDirection(_shakeAnimation.value);
              return Transform.translate(
                  offset: Offset(offset, 0), child: child);
            },
            child: TextField(
              controller: _masterPwController,
              obscureText: _obscureMasterPw,
              enabled: !_isProcessing,
              decoration: InputDecoration(
                labelText: 'Master Password',
                errorText: _hasError ? 'Incorrect master password' : null,
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: _primaryColor, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _errorColor, width: 2),
                ),
                prefixIcon:
                    const Icon(Icons.lock_outline, color: _primaryColor),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureMasterPw
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _obscureMasterPw = !_obscureMasterPw),
                ),
              ),
              onSubmitted: (_) => _unlockWithMasterPassword(),
            ),
          ),
          const SizedBox(height: 24),

          // Unlock button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _unlockWithMasterPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Unlock',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
          ),

          const Spacer(),

          // Logout link
          TextButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              if (mounted) context.go(AppRoutes.login);
            },
            child: Text(
              'Use a different account',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─── PIN Mode ───
  Widget _buildPinMode() {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Column(
      children: [
        SizedBox(height: screenHeight * 0.08),

        // Logo
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: _primaryColor.withAlpha(20),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.shield_rounded,
              size: 40, color: _primaryColor),
        ),
        const SizedBox(height: 24),

        Text(
          _rateLimiter.isPinDisabledForSession
              ? 'PIN Disabled'
              : _hasError
                  ? 'Incorrect PIN'
                  : 'Enter your PIN',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: (_hasError || _rateLimiter.isPinDisabledForSession)
                ? _errorColor
                : const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        if (_lockoutSecondsRemaining > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _errorColor.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _errorColor.withAlpha(50)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, color: _errorColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Try again in ${_formatLockoutTime(_lockoutSecondsRemaining)}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _errorColor,
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            'Unlock your vault',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        const SizedBox(height: 32),

        // PIN dots
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            final offset = _shakeAnimation.value *
                12 *
                _shakeDirection(_shakeAnimation.value);
            return Transform.translate(
                offset: Offset(offset, 0), child: child);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pinLength, (index) {
              final isFilled = index < _enteredPin.length;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  width: isFilled ? 18 : 14,
                  height: isFilled ? 18 : 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _hasError
                        ? _errorColor
                        : isFilled
                            ? _primaryColor
                            : Colors.transparent,
                    border: Border.all(
                      color: _hasError
                          ? _errorColor
                          : _primaryColor.withAlpha(isFilled ? 255 : 80),
                      width: 2,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const Spacer(),

        // Number pad
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              _buildNumberRow([1, 2, 3]),
              const SizedBox(height: 16),
              _buildNumberRow([4, 5, 6]),
              const SizedBox(height: 16),
              _buildNumberRow([7, 8, 9]),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.fingerprint_rounded,
                    visible: _biometricsAvailable && _biometricsConfigured,
                    onTap: _attemptBiometricUnlock,
                  ),
                  _buildDigitButton(0),
                  _buildActionButton(
                    icon: Icons.backspace_outlined,
                    visible: _enteredPin.isNotEmpty,
                    onTap: _onBackspace,
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: screenHeight * 0.02),

        TextButton(
          onPressed: () {
            ref.read(authProvider.notifier).logout();
            if (mounted) context.go(AppRoutes.login);
          },
          child: Text(
            'Use a different account',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ),

        SizedBox(height: bottomPadding + 16),
      ],
    );
  }

  Widget _buildNumberRow(List<int> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildDigitButton(d)).toList(),
    );
  }

  Widget _buildDigitButton(int digit) {
    final isDisabled = _rateLimiter.isLockedOut ||
        _rateLimiter.isPinDisabledForSession;

    return SizedBox(
      width: 72,
      height: 72,
      child: Opacity(
        opacity: isDisabled ? 0.35 : 1.0,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onDigitTap(digit),
            customBorder: const CircleBorder(),
            splashColor: _primaryColor.withAlpha(30),
            highlightColor: _primaryColor.withAlpha(15),
            child: Center(
              child: Text(
                '$digit',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: isDisabled
                      ? Colors.grey.shade400
                      : const Color(0xFF1A1A2E),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required bool visible,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Opacity(
        opacity: visible ? 1.0 : 0.0,
        child: IgnorePointer(
          ignoring: !visible,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              splashColor: _primaryColor.withAlpha(30),
              child: Center(
                child: Icon(icon, size: 28, color: _primaryColor),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _shakeDirection(double t) {
    return (t < 0.25) ? -1 : (t < 0.5) ? 1 : (t < 0.75) ? -1 : 1;
  }
}
