import 'package:validart/validart.dart';

import '../string_utils.dart';

/// Valida CNHs brasileiras (Carteira Nacional de Habilitação —
/// 11 dígitos).
///
/// Implementa o algoritmo oficial dos dois dígitos verificadores,
/// incluindo a regra de decremento (`dsc = 2`) quando o DV1 ultrapassa 9.
///
/// ```dart
/// V.string().taxId(patterns: [const CnhPattern()]);
/// V.string().cnh(); // atalho
/// ```
class CnhPattern extends TaxIdPattern {
  static final _regex = RegExp(r'^\d{11}$');

  /// Cria um [CnhPattern].
  const CnhPattern();

  @override
  String get name => 'CNH';

  @override
  bool matches(String value) {
    if (!_regex.hasMatch(value)) return false;

    final digits = value.onlyDigits;
    if (digits.isRepeatedCharacters) return false;

    return _checksumIsValid(digits);
  }

  static bool _checksumIsValid(String digits) {
    int sum1 = 0;
    for (int i = 0; i < 9; i++) {
      sum1 += int.parse(digits[i]) * (9 - i);
    }

    int dv1 = sum1 % 11;
    int dsc = 0;
    if (dv1 >= 10) {
      dv1 = 0;
      dsc = 2;
    }

    int sum2 = 0;
    for (int i = 0; i < 9; i++) {
      sum2 += int.parse(digits[i]) * (1 + i);
    }

    final x = sum2 % 11;
    int dv2 = x >= 10 ? 0 : x - dsc;
    if (dv2 < 0) dv2 += 11;

    return digits[9] == dv1.toString() && digits[10] == dv2.toString();
  }
}
