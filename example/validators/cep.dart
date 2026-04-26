import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import '../shared/fixtures.dart';

/// Exemplos de `V.string().cep()` — CEP brasileiro (8 dígitos com
/// hífen opcional).
void runCepExamples() {
  section('CEP — modos de máscara');

  print(V.string().cep().validate('01001-000')); // true
  print(V.string().cep().validate('01001000')); // true
  print(V.string().cep().validate('0100100')); // false (7 dígitos)

  print(
    V.string().cep(mode: ValidationMode.formatted).validate('01001000'),
  ); // false
}

void main() => runCepExamples();
