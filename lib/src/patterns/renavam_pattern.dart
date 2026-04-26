import 'package:validart/validart.dart';

import '../string_utils.dart';

/// Valida Renavams brasileiros (Registro Nacional de Veículos
/// Automotores — 11 dígitos com um dígito verificador).
///
/// ```dart
/// V.string().taxId(patterns: [const RenavamPattern()]);
/// V.string().renavam(); // atalho
/// ```
class RenavamPattern extends TaxIdPattern {
  static final _regex = RegExp(r'^\d{11}$');
  static const _weights = <int>[3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

  /// Cria um [RenavamPattern].
  const RenavamPattern();

  @override
  String get name => 'Renavam';

  @override
  bool matches(String value) {
    if (!_regex.hasMatch(value)) return false;

    final String digits = value.onlyDigits;

    if (digits.isRepeatedCharacters) return false;

    return _checksumIsValid(digits);
  }

  static bool _checksumIsValid(String digits) {
    int sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(digits[i]) * _weights[i];
    }

    final int mod = sum % 11;
    final int dv = mod < 2 ? 0 : 11 - mod;

    return digits[10] == dv.toString();
  }
}
