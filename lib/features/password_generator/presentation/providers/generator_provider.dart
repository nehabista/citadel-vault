import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/password_generator_service.dart';
import '../../domain/entities/generator_config.dart';

/// State for the password generator.
class PasswordGeneratorState {
  final String generatedPassword;
  final GeneratorConfig config;

  const PasswordGeneratorState({
    this.generatedPassword = '',
    this.config = const GeneratorConfig(),
  });

  PasswordGeneratorState copyWith({
    String? generatedPassword,
    GeneratorConfig? config,
  }) {
    return PasswordGeneratorState(
      generatedPassword: generatedPassword ?? this.generatedPassword,
      config: config ?? this.config,
    );
  }
}

/// Notifier managing password generator state and actions.
class PasswordGeneratorNotifier extends Notifier<PasswordGeneratorState> {
  @override
  PasswordGeneratorState build() => const PasswordGeneratorState();

  void setLength(int length) {
    state = state.copyWith(config: state.config.copyWith(length: length));
    generate();
  }

  void toggleUpper() {
    state = state.copyWith(
      config: state.config.copyWith(upper: !state.config.upper),
    );
    generate();
  }

  void toggleLower() {
    state = state.copyWith(
      config: state.config.copyWith(lower: !state.config.lower),
    );
    generate();
  }

  void toggleDigits() {
    state = state.copyWith(
      config: state.config.copyWith(digits: !state.config.digits),
    );
    generate();
  }

  void toggleSymbols() {
    state = state.copyWith(
      config: state.config.copyWith(symbols: !state.config.symbols),
    );
    generate();
  }

  void togglePronounceable() {
    state = state.copyWith(
      config: state.config.copyWith(pronounceable: !state.config.pronounceable),
    );
    generate();
  }

  void generate() {
    final c = state.config;
    final pwd = generatePassword(
      length: c.length,
      upper: c.upper,
      lower: c.lower,
      digits: c.digits,
      symbols: c.symbols,
      pronounceable: c.pronounceable,
    );
    state = state.copyWith(generatedPassword: pwd);
  }
}

/// Provider for the password generator.
final passwordGeneratorProvider =
    NotifierProvider<PasswordGeneratorNotifier, PasswordGeneratorState>(
  PasswordGeneratorNotifier.new,
);
