import 'package:validart/validart.dart';

import '../string_utils.dart';

/// Valida títulos de eleitor brasileiros (12 dígitos).
///
/// Estrutura: `NNNNNNNN UU DV1 DV2` — 8 dígitos sequenciais, 2 para a
/// UF (`01..28`) e 2 dígitos verificadores. O checksum tem regra
/// especial para SP (UF `01`) e MG (UF `02`), onde um DV calculado
/// como `0` vira `1`.
///
/// ```dart
/// V.string().taxId(patterns: [const TituloEleitorPattern()]);
/// V.string().tituloEleitor(); // atalho
/// ```
class TituloEleitorPattern extends TaxIdPattern {
  static final _regex = RegExp(r'^\d{12}$');

  /// Cria um [TituloEleitorPattern].
  const TituloEleitorPattern();

  @override
  String get name => 'Título de eleitor';

  @override
  bool matches(String value) {
    if (!_regex.hasMatch(value)) return false;

    final String digits = value.onlyDigits;
    final int uf = int.parse(digits.substring(8, 10));

    if (uf < 1 || uf > 28) return false;

    return _checksumIsValid(digits, uf);
  }

  static bool _checksumIsValid(String digits, int uf) {
    int sum1 = 0;
    for (int i = 0; i < 8; i++) {
      sum1 += int.parse(digits[i]) * (i + 2);
    }

    final int dv1 = _reduceDigit(sum1 % 11, uf);

    final int sum2 =
        int.parse(digits[8]) * 7 + int.parse(digits[9]) * 8 + dv1 * 9;
    final int dv2 = _reduceDigit(sum2 % 11, uf);

    return digits[10] == dv1.toString() && digits[11] == dv2.toString();
  }

  /// Reduz o módulo ao dígito final, aplicando a exceção de SP/MG
  /// (UF `01` ou `02`), onde um `0` calculado vira `1`.
  static int _reduceDigit(int mod, int uf) {
    if (mod == 10) return 0;
    if (mod == 0 && (uf == 1 || uf == 2)) return 1;
    return mod;
  }
}
