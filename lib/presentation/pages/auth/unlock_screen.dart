// File: lib/presentation/pages/auth/unlock_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/services/auth/local_auth_service.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../routing/app_router.dart';

/// Beautiful PIN unlock screen with number pad, dot indicators, and biometric support.
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

  final List<int> _enteredPin = [];
  bool _isProcessing = false;
  bool _hasError = false;
  bool _biometricsAvailable = false;

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
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
      }
    });

    _loadUnlockMethod();
  }

  Future<void> _loadUnlockMethod() async {
    final localAuth = ref.read(localAuthServiceProvider);
    final method = await localAuth.getSavedUnlockMethod();
    final canBio = await localAuth.canUseBiometrics();

    if (mounted) {
      setState(() {
        _biometricsAvailable = canBio;
      });

      // Auto-trigger biometric prompt if biometric unlock is configured.
      if (method == UnlockMethod.biometrics && canBio) {
        _attemptBiometricUnlock();
      }
    }
  }

  Future<void> _attemptBiometricUnlock() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final success =
          await ref.read(authProvider.notifier).unlockWithBiometrics();
      if (success && mounted) {
        context.go(AppRoutes.home);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _onDigitTap(int digit) {
    if (_isProcessing || _enteredPin.length >= _pinLength) return;

    HapticFeedback.lightImpact();
    setState(() {
      _hasError = false;
      _enteredPin.add(digit);
    });

    if (_enteredPin.length == _pinLength) {
      _verifyPin();
    }
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
      context.go(AppRoutes.home);
    } else if (mounted) {
      // Show error with shake animation.
      HapticFeedback.heavyImpact();
      setState(() {
        _hasError = true;
        _isProcessing = false;
      });
      _shakeController.forward();

      // Clear after a short delay.
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() => _enteredPin.clear());
        }
      });
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.08),

            // App logo
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _primaryColor.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.shield_rounded,
                size: 40,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              _hasError ? 'Incorrect PIN' : 'Enter your PIN',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _hasError ? _errorColor : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unlock your vault',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 32),

            // PIN dots
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                final offset =
                    _shakeAnimation.value * 12 * _shakeDirection(_shakeAnimation.value);
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: child,
                );
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
                  // Row 1: 1, 2, 3
                  _buildNumberRow([1, 2, 3]),
                  const SizedBox(height: 16),
                  // Row 2: 4, 5, 6
                  _buildNumberRow([4, 5, 6]),
                  const SizedBox(height: 16),
                  // Row 3: 7, 8, 9
                  _buildNumberRow([7, 8, 9]),
                  const SizedBox(height: 16),
                  // Row 4: biometric, 0, backspace
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Biometric button (bottom-left)
                      _buildActionButton(
                        icon: Icons.fingerprint_rounded,
                        visible: _biometricsAvailable,
                        onTap: _attemptBiometricUnlock,
                      ),
                      _buildDigitButton(0),
                      // Backspace button (bottom-right)
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

            // Logout link
            TextButton(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                if (mounted) context.go(AppRoutes.login);
              },
              child: Text(
                'Use a different account',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            SizedBox(height: bottomPadding + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberRow(List<int> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildDigitButton(d)).toList(),
    );
  }

  Widget _buildDigitButton(int digit) {
    return SizedBox(
      width: 72,
      height: 72,
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
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A2E),
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
                child: Icon(
                  icon,
                  size: 28,
                  color: _primaryColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Returns a sin-like direction multiplier for the shake animation.
  double _shakeDirection(double t) {
    // Produces a left-right-left-right pattern.
    return (t < 0.25)
        ? -1
        : (t < 0.5)
            ? 1
            : (t < 0.75)
                ? -1
                : 1;
  }
}
