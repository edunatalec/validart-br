import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import '../shared/fixtures.dart';

/// Exemplos de `V.string().bankCode()` — código COMPE de instituição
/// financeira brasileira (3 dígitos, lista oficial do Banco Central).
void runBankCodeExamples() {
  section('Código de banco — principais instituições');

  print(V.string().bankCode().validate('001')); // true (Banco do Brasil)
  print(V.string().bankCode().validate('033')); // true (Santander)
  print(V.string().bankCode().validate('104')); // true (Caixa)
  print(V.string().bankCode().validate('237')); // true (Bradesco)
  print(V.string().bankCode().validate('341')); // true (Itaú)
  print(V.string().bankCode().validate('260')); // true (Nubank)
  print(V.string().bankCode().validate('077')); // true (Inter)

  section('Código de banco — formatos rejeitados');

  print(V.string().bankCode().validate('999')); // false (não atribuído)
  print(V.string().bankCode().validate('1')); // false (sem zero à esquerda)
  print(V.string().bankCode().validate('001-9')); // false (com DV)
}

void main() => runBankCodeExamples();
