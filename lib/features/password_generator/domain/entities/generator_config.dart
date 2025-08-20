/// Configuration for the password generator.
class GeneratorConfig {
  final int length;
  final bool upper;
  final bool lower;
  final bool digits;
  final bool symbols;
  final bool pronounceable;

  const GeneratorConfig({
    this.length = 16,
    this.upper = true,
    this.lower = true,
    this.digits = true,
    this.symbols = true,
    this.pronounceable = false,
  });

  GeneratorConfig copyWith({
    int? length,
    bool? upper,
    bool? lower,
    bool? digits,
    bool? symbols,
    bool? pronounceable,
  }) {
    return GeneratorConfig(
      length: length ?? this.length,
      upper: upper ?? this.upper,
      lower: lower ?? this.lower,
      digits: digits ?? this.digits,
      symbols: symbols ?? this.symbols,
      pronounceable: pronounceable ?? this.pronounceable,
    );
  }
}
