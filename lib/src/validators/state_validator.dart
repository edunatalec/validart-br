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
/// Emite [VStringCodeBr.invalidState] em caso de falha.
///
/// Executa na fase de validação.
///
/// ```dart
/// V.string().state().validate('SP'); // true
/// V.string().state().validate('XY'); // false
///
/// V.string().toUpperCase().state().validate('rj'); // true
/// ```
class StateValidator extends Validator<String> {
  /// Conjunto das 27 siglas de UF brasileiras.
  static const Set<String> states = <String>{
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

  /// Cria um [StateValidator].
  const StateValidator();

  @override
  String get code => VStringCodeBr.invalidState;

  @override
  Map<String, dynamic>? validate(String value) {
    if (states.contains(value)) return null;
    return {};
  }
}
