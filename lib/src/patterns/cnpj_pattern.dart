import 'package:validart/validart.dart';

import '../string_utils.dart';

/// Valida CNPJs brasileiros (Cadastro Nacional da Pessoa Jurídica —
/// 14 caracteres com dois dígitos verificadores).
///
/// Desde a resolução da Receita Federal que introduz o CNPJ
/// alfanumérico (produção a partir de julho/2026), os 12 primeiros
/// caracteres podem ser `[0-9A-Z]` e os 2 últimos (DVs) continuam
/// numéricos. Letras devem estar em caixa alta — encadeie
/// `V.string().toUpperCase()` para aceitar lowercase.
///
/// Passe `alphanumeric: false` para travar no formato antigo (só
/// dígitos). CNPJs numéricos continuam validando dos dois jeitos
/// (dígitos são subconjunto do alfanumérico).
///
/// ```dart
/// V.string().taxId(patterns: [const CnpjPattern()]);
/// V.string().cnpj();                        // atalho
/// V.string().cnpj(alfanumerico: false);     // só dígitos
///
/// V.string().toUpperCase().cnpj()
///   .validate('12.abc.345/01de-35');        // true
/// ```
class CnpjPattern extends TaxIdPattern {
  static final _formattedAlphaRegex = RegExp(
    r'^[0-9A-Z]{2}\.[0-9A-Z]{3}\.[0-9A-Z]{3}/[0-9A-Z]{4}-\d{2}$',
  );
  static final _unformattedAlphaRegex = RegExp(r'^[0-9A-Z]{12}\d{2}$');

  static final _formattedNumericRegex = RegExp(
    r'^\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}$',
  );
  static final _unformattedNumericRegex = RegExp(r'^\d{14}$');

  static const _weights1 = <int>[5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
  static const _weights2 = <int>[6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

  /// Controla se a máscara (`.`, `/`, `-`) é obrigatória, proibida ou
  /// opcional. Padrão: [ValidationMode.any].
  final ValidationMode mode;

  /// Quando `true` (padrão) aceita o novo formato alfanumérico da
  /// Receita Federal. Quando `false`, exige apenas dígitos.
  final bool alphanumeric;

  /// Cria um [CnpjPattern].
  const CnpjPattern({this.mode = ValidationMode.any, this.alphanumeric = true});

  @override
  String get name => 'CNPJ';

  @override
  bool matches(String value) {
    if (!_matchesMode(value)) return false;

    final String chars = value.replaceAll(RegExp(r'[^0-9A-Z]'), '');

    if (chars.length != 14) return false;
    if (chars.isRepeatedCharacters) return false;

    return _checksumIsValid(chars);
  }

  bool _matchesMode(String value) {
    final RegExp formattedRegex = alphanumeric
        ? _formattedAlphaRegex
        : _formattedNumericRegex;
    final RegExp unformattedRegex = alphanumeric
        ? _unformattedAlphaRegex
        : _unformattedNumericRegex;

    switch (mode) {
      case ValidationMode.formatted:
        return formattedRegex.hasMatch(value);
      case ValidationMode.unformatted:
        return unformattedRegex.hasMatch(value);
      case ValidationMode.any:
        return formattedRegex.hasMatch(value) ||
            unformattedRegex.hasMatch(value);
    }
  }

  static bool _checksumIsValid(String chars) {
    final int dv1 = _checkDigit(chars, 12, _weights1);
    if (chars[12] != dv1.toString()) return false;

    final int dv2 = _checkDigit(chars, 13, _weights2);

    return chars[13] == dv2.toString();
  }

  /// Cada caractere vale `codeUnit - 48` — dígitos `'0'..'9'` mapeiam
  /// para `0..9` e letras `'A'..'Z'` para `17..42` (algoritmo oficial
  /// da Receita).
  static int _checkDigit(String chars, int length, List<int> weights) {
    int sum = 0;

    for (int i = 0; i < length; i++) {
      sum += (chars.codeUnitAt(i) - 48) * weights[i];
    }

    final int mod = sum % 11;

    return mod < 2 ? 0 : 11 - mod;
  }
}
