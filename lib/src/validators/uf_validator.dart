import 'package:validart/validart.dart';

import '../v_code_br.dart';

/// Valida que a string é uma sigla de unidade federativa brasileira
/// (UF) válida — uma das 27 siglas de 2 letras em caixa alta:
/// `AC, AL, AP, AM, BA, CE, DF, ES, GO, MA, MT, MS, MG, PA, PB, PR,
/// PE, PI, RJ, RN, RS, RO, RR, SC, SP, SE, TO`.
///
/// Letras devem estar em caixa alta — encadeie
/// `V.string().toUpperCase()` quando o input pode vir minúsculo.
///
/// Emite [VStringCodeBr.ufInvalida] em caso de falha.
///
/// Executa na fase de validação.
///
/// ```dart
/// V.string().uf().validate('SP'); // true
/// V.string().uf().validate('XY'); // false
///
/// V.string().toUpperCase().uf().validate('rj'); // true
/// ```
class UfValidator extends Validator<String> {
  /// Conjunto das 27 siglas de UF brasileiras.
  static const Set<String> ufs = <String>{
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO',
  };

  /// Cria um [UfValidator].
  const UfValidator();

  @override
  String get code => VStringCodeBr.ufInvalida;

  @override
  Map<String, dynamic>? validate(String value) {
    if (ufs.contains(value)) return null;
    return {};
  }
}
