import 'package:validart/validart.dart';

import '../string_utils.dart';

/// Valida CEPs brasileiros (Código de Endereçamento Postal — 8 dígitos).
///
/// Aceita 8 dígitos com ou sem a máscara `XXXXX-XXX`. Rejeita CEPs com
/// todos os dígitos iguais. [mode] controla a forma aceita:
/// [ValidationMode.any] (padrão) aceita os dois jeitos,
/// [ValidationMode.formatted] exige o hífen e
/// [ValidationMode.unformatted] o rejeita.
///
/// ```dart
/// V.string().postalCode(patterns: [const CepPattern()]);
/// V.string().cep(); // atalho
///
/// V.string().cep(mode: ValidationMode.formatted)
///   .validate('01001-000'); // true
/// ```
class CepPattern extends PostalCodePattern {
  static final _formattedRegex = RegExp(r'^\d{5}-\d{3}$');
  static final _unformattedRegex = RegExp(r'^\d{8}$');

  /// Controla se o hífen é obrigatório, proibido ou opcional.
  /// Padrão: [ValidationMode.any].
  final ValidationMode mode;

  /// Cria um [CepPattern].
  const CepPattern({this.mode = ValidationMode.any});

  @override
  String get name => 'CEP';

  @override
  bool matches(String value) {
    if (!_matchesMode(value)) return false;

    final digits = value.onlyDigits;
    if (digits.length != 8) return false;
    if (digits.isRepeatedCharacters) return false;

    return true;
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
}
