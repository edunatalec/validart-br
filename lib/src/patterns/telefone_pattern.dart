import 'package:validart/validart.dart';

import '../enums.dart';

/// [PhonePattern] para números de telefone brasileiros.
///
/// Aceita celular (9 dígitos iniciando com `9`) e fixo (8 dígitos).
/// O DDI (`+55`), o DDD e a presença de separadores (parênteses,
/// traços, espaços) são controlados por [countryCode], [areaCode] e
/// [mode]. Quando [mobileOnly] é `true`, só celular é aceito.
///
/// Os nomes dos campos seguem a convenção do core (em inglês). A
/// API pública pt-BR é exposta via `V.string().telefone(...)`, que
/// usa nomes pt-BR (`ddd`, `pais`, `apenasCelular`, `modo`) e faz
/// o depara pra cá internamente.
///
/// ```dart
/// V.string().phone(patterns: [const TelefonePattern()]);
/// V.string().telefone(); // atalho pt-BR
///
/// V.string().phone(patterns: [
///   const TelefonePattern(
///     countryCode: CountryCodeFormat.required,
///     areaCode: FormatoDdd.obrigatorio,
///     mobileOnly: true,
///   ),
/// ]);
/// ```
class TelefonePattern extends PhonePattern {
  static final _regex = RegExp(
    r'^'
    r'(\+55\s?)?'
    r'(\(\d{2}\)\s?|\d{2}\s?)?'
    r'(\d{4,5})'
    r'[\s-]?'
    r'(\d{4})'
    r'$',
  );

  static const _validAreaCodes = <int>{
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    21,
    22,
    24,
    27,
    28,
    31,
    32,
    33,
    34,
    35,
    37,
    38,
    41,
    42,
    43,
    44,
    45,
    46,
    47,
    48,
    49,
    51,
    53,
    54,
    55,
    61,
    62,
    63,
    64,
    65,
    66,
    67,
    68,
    69,
    71,
    73,
    74,
    75,
    77,
    79,
    81,
    82,
    83,
    84,
    85,
    86,
    87,
    88,
    89,
    91,
    92,
    93,
    94,
    95,
    96,
    97,
    98,
    99,
  };

  /// Controla se o DDD é obrigatório, proibido ou opcional.
  /// Padrão: [FormatoDdd.opcional].
  final FormatoDdd areaCode;

  /// Controla se o DDI (`+55`) é obrigatório, proibido ou opcional.
  /// Padrão: [CountryCodeFormat.optional].
  final CountryCodeFormat countryCode;

  /// Quando `true`, só aceita celular (9 dígitos iniciando com `9`).
  /// Padrão: `false`.
  final bool mobileOnly;

  /// Controla se separadores (espaços, traços, parênteses) são
  /// obrigatórios, proibidos ou opcionais.
  /// Padrão: [ValidationMode.any].
  final ValidationMode mode;

  /// Cria um [TelefonePattern].
  const TelefonePattern({
    this.areaCode = FormatoDdd.opcional,
    this.countryCode = CountryCodeFormat.optional,
    this.mobileOnly = false,
    this.mode = ValidationMode.any,
  });

  @override
  String get code => VStringCode.phone;

  @override
  Map<String, dynamic>? validate(String value) {
    final RegExpMatch? match = _regex.firstMatch(value);
    if (match == null) return {};

    final bool hasCountryCode = match.group(1) != null;
    final String? areaCodeRaw = match.group(2);
    final String first = match.group(3)!;
    final bool hasAreaCode = areaCodeRaw != null;

    if (hasCountryCode && countryCode == CountryCodeFormat.none) return {};
    if (!hasCountryCode && countryCode == CountryCodeFormat.required) {
      return {};
    }

    if (hasAreaCode && areaCode == FormatoDdd.nenhum) return {};
    if (!hasAreaCode && areaCode == FormatoDdd.obrigatorio) return {};

    if (hasCountryCode && !hasAreaCode) return {};

    if (hasAreaCode) {
      final String areaCodeDigits = areaCodeRaw.replaceAll(
        RegExp(r'[^\d]'),
        '',
      );
      final int areaCodeInt = int.parse(areaCodeDigits);

      if (!_validAreaCodes.contains(areaCodeInt)) return {};
    }

    final bool isMobile = first.length == 5 && first.startsWith('9');
    final bool isLandline = first.length == 4;

    if (!isMobile && !isLandline) return {};
    if (mobileOnly && !isMobile) return {};

    final bool hasSeparators = _containsSeparator(value);

    if (mode == ValidationMode.unformatted && hasSeparators) return {};
    if (mode == ValidationMode.formatted && !hasSeparators) return {};

    return null;
  }

  static bool _containsSeparator(String value) =>
      value.contains(' ') || value.contains('-') || value.contains('(');
}
