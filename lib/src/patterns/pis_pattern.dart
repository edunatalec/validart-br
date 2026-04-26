import 'package:validart/validart.dart';

import '../string_utils.dart';

/// Valida PIS/PASEP/NIS/NIT (11 dígitos com um dígito verificador).
///
/// Máscara canônica: `XXX.XXXXX.XX-X` (3/5/2/1). [mode] controla se a
/// máscara é obrigatória, proibida ou opcional.
///
/// ```dart
/// V.string().taxId(patterns: [const PisPattern()]);
/// V.string().pis(); // atalho
///
/// V.string().pis(modo: ModoValidacao.semMascara)
///   .validate('12054789013'); // true
/// ```
class PisPattern extends TaxIdPattern {
  static final _formattedRegex = RegExp(r'^\d{3}\.\d{5}\.\d{2}-\d$');
  static final _unformattedRegex = RegExp(r'^\d{11}$');

  static const _weights = <int>[3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

  /// Controla se a máscara (`.` e `-`) é obrigatória, proibida ou
  /// opcional. Padrão: [ValidationMode.any].
  final ValidationMode mode;

  /// Cria um [PisPattern].
  const PisPattern({this.mode = ValidationMode.any});

  @override
  String get name => 'PIS/PASEP';

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
    int sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(digits[i]) * _weights[i];
    }

    final int mod = sum % 11;
    final int dv = mod < 2 ? 0 : 11 - mod;

    return digits[10] == dv.toString();
  }
}
