import 'package:validart/validart.dart';

import '../v_code_br.dart';

/// Valida que a string é um DDD brasileiro válido — 2 dígitos da
/// lista oficial publicada pela Anatel.
///
/// O DDD é apenas a área de discagem (sem o número do assinante).
/// Para validar o telefone completo, use [`V.string().telefone()`].
///
/// A entrada deve conter exatamente 2 dígitos numéricos, sem
/// parênteses, espaços ou outros separadores. Aplique `.preprocess`
/// ou `.replaceAll` antes se o input puder vir mascarado.
///
/// Emite [VStringCodeBr.dddInvalido] em caso de falha.
///
/// Executa na fase de validação.
///
/// ```dart
/// V.string().ddd().validate('11'); // true
/// V.string().ddd().validate('21'); // true
/// V.string().ddd().validate('20'); // false (não atribuído)
/// V.string().ddd().validate('99'); // true
/// ```
class DddValidator extends Validator<String> {
  /// Conjunto dos 67 DDDs brasileiros atualmente em uso.
  ///
  /// Mantido pela Anatel — atualizar conforme novas alocações ou
  /// desativações regionais.
  static const Set<String> ddds = <String>{
    '11', '12', '13', '14', '15', '16', '17', '18', '19', // SP
    '21', '22', '24', // RJ
    '27', '28', // ES
    '31', '32', '33', '34', '35', '37', '38', // MG
    '41', '42', '43', '44', '45', '46', // PR
    '47', '48', '49', // SC
    '51', '53', '54', '55', // RS
    '61', // DF/GO
    '62', '64', // GO
    '63', // TO
    '65', '66', // MT
    '67', // MS
    '68', // AC
    '69', // RO
    '71', '73', '74', '75', '77', // BA
    '79', // SE
    '81', '87', // PE
    '82', // AL
    '83', // PB
    '84', // RN
    '85', '88', // CE
    '86', '89', // PI
    '91', '93', '94', // PA
    '92', '97', // AM
    '95', // RR
    '96', // AP
    '98', '99', // MA
  };

  /// Cria um [DddValidator].
  const DddValidator();

  @override
  String get code => VStringCodeBr.dddInvalido;

  @override
  Map<String, dynamic>? validate(String value) {
    if (ddds.contains(value)) return null;
    return {};
  }
}
