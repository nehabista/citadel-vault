import 'dart:math';

import 'package:random_x/random_x.dart';

/// Generate a random password with configurable character pools.
///
/// When [pronounceable] is true, generates a passphrase instead.
String generatePassword({
  required int length,
  required bool upper,
  required bool lower,
  required bool digits,
  required bool symbols,
  required bool pronounceable,
}) {
  if (pronounceable) {
    // Words ~ length/4 but at least 4
    final words = max(4, (length / 4).round());
    return generatePassphrase(
      wordCount: words,
      separator: '-',
      addDigit: digits,
      addSymbol: symbols,
      randomCapitalization: upper || lower,
    );
  }

  final rng = Random.secure();
  final pools = <String>[];
  if (lower) pools.add('abcdefghijklmnopqrstuvwxyz');
  if (upper) pools.add('ABCDEFGHIJKLMNOPQRSTUVWXYZ');
  if (digits) pools.add('0123456789');
  if (symbols) pools.add(r'!@#$%^&*()-_=+[]{};:,<.>/?~');

  if (pools.isEmpty) {
    pools.addAll(['abcdefghijklmnopqrstuvwxyz', '0123456789']);
  }

  // Ensure at least one char from each chosen pool.
  final buffer = StringBuffer();
  for (var i = 0; i < pools.length && i < length; i++) {
    final p = pools[i];
    buffer.write(p[rng.nextInt(p.length)]);
  }
  while (buffer.length < length) {
    final p = pools[rng.nextInt(pools.length)];
    buffer.write(p[rng.nextInt(p.length)]);
  }

  final list = buffer.toString().split('')..shuffle(rng);
  return list.join();
}

/// Generate a passphrase of [wordCount] random words joined by [separator].
String generatePassphrase({
  int wordCount = 4,
  String separator = '-',
  bool randomCapitalization = true,
  bool addDigit = true,
  bool addSymbol = true,
}) {
  final rng = Random.secure();
  final words = <String>[];

  for (int i = 0; i < wordCount; i++) {
    words.add(_randomWord(rng));
  }

  if (randomCapitalization) {
    for (var i = 0; i < words.length; i++) {
      if (rng.nextBool() && words[i].isNotEmpty) {
        words[i] = '${words[i][0].toUpperCase()}${words[i].substring(1)}';
      }
    }
  }

  var passphrase = words.join(separator);
  if (addDigit) passphrase += '$separator${rng.nextInt(90) + 10}';
  if (addSymbol) {
    const syms = r'!@#$%&*?';
    passphrase += '$separator${syms[rng.nextInt(syms.length)]}';
  }
  return passphrase;
}

String _randomWord(Random rng) {
  try {
    final pick =
        rng.nextBool() ? RndX.generateName() : RndX.randomAddress().city;
    final cleaned = pick.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (cleaned.isNotEmpty) return cleaned;
  } catch (_) {
    // random_x not available or threw; fall back
  }

  const fallback = [
    'glowering',
    'armour',
    'permanently',
    'jacket',
    'forest',
    'river',
    'planet',
    'violet',
    'ember',
    'cinder',
    'mystic',
    'pepper',
    'quantum',
    'velvet',
    'cipher',
    'thunder',
    'aurora',
    'nebula',
    'cosmic',
    'saffron',
    'onyx',
    'azure',
    'embered',
    'pioneer',
    'galaxy',
    'sundial',
    'harbor',
    'orchid',
    'cascade',
    'blizzard',
    'lantern',
    'marble',
    'tundra',
    'willow',
    'zephyr',
    'talon',
    'emberleaf',
  ];
  return fallback[rng.nextInt(fallback.length)];
}
