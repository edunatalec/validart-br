import 'dart:math';

/// Seed usada por todo teste de fuzz. Fixa de propósito para falhas
/// serem reproduzíveis. Override em runtime com `FUZZ_SEED=<int>`.
const int kFuzzSeed = 42;

/// Iterações por propriedade. Equilibra cobertura e tempo de suite
/// (~1s por arquivo com este valor).
const int kFuzzIterations = 500;

/// Resolve o seed a partir da env var `FUZZ_SEED`, caindo em
/// [kFuzzSeed] quando ausente ou mal-formada.
int envSeed() {
  const fromEnv = String.fromEnvironment('FUZZ_SEED');

  return int.tryParse(fromEnv) ?? kFuzzSeed;
}

/// ASCII imprimível para strings "quase válidas".
const String kAsciiPrintable =
    ' !"#\$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~';

/// Scalars Unicode adversariais para estressar validadores: control
/// chars, zero-width, bidi overrides, combining marks, surrogates,
/// code points altos. Em escape para o fonte ficar ASCII-safe.
const List<String> kAdversarialChars = [
  '\u{0000}', // NUL
  '\u{0007}', // BEL
  '\u{001B}', // ESC
  '\u{007F}', // DEL
  '\u{200B}', // zero-width space
  '\u{200E}', // left-to-right mark
  '\u{200F}', // right-to-left mark
  '\u{202E}', // right-to-left override
  '\u{00A0}', // non-breaking space
  '\u{0301}', // combining acute accent
  '\u{FFFD}', // replacement char
  '\u{FFFF}', // non-character
  '\u{1F600}', // emoji (surrogate pair)
  '\u{10FFFF}', // max Unicode code point
];

/// String ASCII-imprimível aleatória com [len] caracteres.
String randomAscii(Random rng, int len) {
  final StringBuffer buf = StringBuffer();

  for (int i = 0; i < len; i++) {
    buf.write(kAsciiPrintable[rng.nextInt(kAsciiPrintable.length)]);
  }

  return buf.toString();
}

/// String aleatória que mistura ASCII imprimível e caracteres Unicode
/// adversariais. Bom para testar que validadores nem crasham nem
/// aceitam lixo.
String randomAdversarial(Random rng, int len) {
  final StringBuffer buf = StringBuffer();

  for (int i = 0; i < len; i++) {
    if (rng.nextInt(10) < 3) {
      buf.write(kAdversarialChars[rng.nextInt(kAdversarialChars.length)]);
    } else {
      buf.write(kAsciiPrintable[rng.nextInt(kAsciiPrintable.length)]);
    }
  }

  return buf.toString();
}

/// String só de dígitos com tamanho [len].
String randomDigits(Random rng, int len) {
  final StringBuffer buf = StringBuffer();

  for (int i = 0; i < len; i++) {
    buf.write(rng.nextInt(10));
  }

  return buf.toString();
}

/// Itera [kFuzzIterations] vezes, passando um [Random] seedado e o
/// índice da iteração para [body]. Falhas imprimem o seed para
/// reproduzir com `FUZZ_SEED=<n>`.
void fuzz(
  String description,
  void Function(Random rng, int iteration) body, {
  int? iterations,
  int? seed,
}) {
  final int actualSeed = seed ?? envSeed();
  final Random rng = Random(actualSeed);
  final int count = iterations ?? kFuzzIterations;

  for (int i = 0; i < count; i++) {
    try {
      body(rng, i);
    } catch (e, s) {
      throw StateError(
        'fuzz property "$description" failed at iteration $i '
        '(seed=$actualSeed): $e\n$s',
      );
    }
  }
}
