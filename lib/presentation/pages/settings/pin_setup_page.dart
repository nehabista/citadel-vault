// File: lib/presentation/pages/settings/pin_setup_page.dart
// PIN creation flow: enter 6-digit PIN, confirm, save via LocalAuthService.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';

/// Full-screen PIN setup page with two steps: create and confirm.
class PinSetupPage extends ConsumerStatefulWidget {
  /// The user's master password, needed to encrypt/store with the PIN.
  final String masterPassword;

  const PinSetupPage({super.key, required this.masterPassword});

  @override
  ConsumerState<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends ConsumerState<PinSetupPage>
    with SingleTickerProviderStateMixin {
  static const int _pinLength = 6;
  static const Color _primaryColor = Color(0xFF4D4DCD);
  static const Color _errorColor = Color(0xFFE53935);

  final List<int> _enteredPin = [];
  String? _firstPin;
  bool _isConfirmStep = false;
  bool _hasError = false;
  bool _isSaving = false;

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
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onDigitTap(int digit) {
    if (_isSaving || _enteredPin.length >= _pinLength) return;
    HapticFeedback.lightImpact();
    setState(() {
      _hasError = false;
      _enteredPin.add(digit);
    });
    if (_enteredPin.length == _pinLength) {
      _onPinComplete();
    }
  }

  void _onBackspace() {
    if (_isSaving || _enteredPin.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _hasError = false;
      _enteredPin.removeLast();
    });
  }

  Future<void> _onPinComplete() async {
    final pin = _enteredPin.join();
    if (!_isConfirmStep) {
      // Step 1: store first PIN, move to confirm
      setState(() {
        _firstPin = pin;
        _isConfirmStep = true;
        _enteredPin.clear();
      });
    } else {
      // Step 2: verify match
      if (pin == _firstPin) {
        await _savePin(pin);
      } else {
        HapticFeedback.heavyImpact();
        setState(() => _hasError = true);
        _shakeController.forward();
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          setState(() => _enteredPin.clear());
        }
      }
    }
  }

  Future<void> _savePin(String pin) async {
    setState(() => _isSaving = true);
    try {
      final localAuth = ref.read(localAuthServiceProvider);
      await localAuth.enablePinUnlock(pin, widget.masterPassword);
      if (mounted) {
        Navigator.of(context).pop(true); // success
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set up PIN: $e'),
            backgroundColor: _errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text(
          'Set Up PIN',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.04),

            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _primaryColor.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _isConfirmStep ? Icons.check_circle_outline : Icons.pin_outlined,
                size: 40,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              _hasError
                  ? 'PINs don\'t match'
                  : _isConfirmStep
                      ? 'Confirm your PIN'
                      : 'Create a 6-digit PIN',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: _hasError ? _errorColor : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isConfirmStep
                  ? 'Re-enter your PIN to confirm'
                  : 'This PIN will be used for quick unlock',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: Colors.grey.shade500,
              ),
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
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.only(bottom: 80),
                child: CircularProgressIndicator(color: _primaryColor),
              )
            else
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
                        // Empty spacer on left
                        const SizedBox(width: 72, height: 72),
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
                fontSize: 28,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
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
