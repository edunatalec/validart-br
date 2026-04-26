import 'package:validart/validart.dart';

import '../string_utils.dart';

/// Valida CPFs brasileiros (Cadastro de Pessoas Físicas — 11 dígitos
/// com dois dígitos verificadores).
///
/// Rejeita CPFs com todos os dígitos iguais (`000.000.000-00`, …) e
/// aqueles cujo checksum oficial não confere. [mode] controla a forma
/// aceita: [ValidationMode.any] (padrão) aceita com ou sem máscara,
/// [ValidationMode.formatted] exige máscara e
/// [ValidationMode.unformatted] a rejeita.
///
/// ```dart
/// V.string().taxId(patterns: [const CpfPattern()]);
/// V.string().cpf(); // atalho
///
/// V.string().cpf(mode: ValidationMode.unformatted)
///   .validate('12345678909'); // true
/// ```
class CpfPattern extends TaxIdPattern {
  static final _formattedRegex = RegExp(r'^\d{3}\.\d{3}\.\d{3}-\d{2}$');
  static final _unformattedRegex = RegExp(r'^\d{11}$');

  /// Controla se a máscara (`.` e `-`) é obrigatória, proibida ou
  /// opcional. Padrão: [ValidationMode.any].
  final ValidationMode mode;

  /// Cria um [CpfPattern].
  const CpfPattern({this.mode = ValidationMode.any});

  @override
  String get name => 'CPF';

  @override
  bool matches(String value) {
    if (!_matchesMode(value)) return false;

    final String digits = value.onlyDigits;

    if (digits.length != 11) return false;
    if (digits.isRepeatedCharacters) return false;

    return _checksumIsValid(digits);
  }

  bool _matchesMode(String value) {
    switch (mode) {
      case ValidationMode.formatted:
        return _formattedRegex.hasMatch(value);
      case ValidationMode.unformatted:
        return _unformattedRegex.hasMatch(value);
      case ValidationMode.any:
        return _formattedRegex.hasMatch(value) ||
            _unformattedRegex.hasMatch(value);
    }
  }

  static bool _checksumIsValid(String digits) {
    int sum1 = 0;
    int sum2 = 0;

    for (int i = 0; i < 9; i++) {
      final int d = int.parse(digits[i]);
      sum1 += d * (10 - i);
      sum2 += d * (11 - i);
    }

    final int dv1 = (sum1 * 10) % 11 % 10;
    sum2 += dv1 * 2;
    final int dv2 = (sum2 * 10) % 11 % 10;

    return digits[9] == dv1.toString() && digits[10] == dv2.toString();
  }
}
