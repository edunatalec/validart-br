import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import '../shared/fixtures.dart';

/// Exemplos de `V.string().ddd()` — DDD brasileiro isolado (2 dígitos
/// da lista oficial Anatel, 67 códigos atribuídos).
///
/// Para validar o telefone completo (DDD + número), use `phoneBr()`,
/// que internamente já valida o DDD.
void runDddExamples() {
  section('DDD — capitais');

  print(V.string().ddd().validate('11')); // true (São Paulo)
  print(V.string().ddd().validate('21')); // true (Rio de Janeiro)
  print(V.string().ddd().validate('31')); // true (Belo Horizonte)
  print(V.string().ddd().validate('51')); // true (Porto Alegre)
  print(V.string().ddd().validate('61')); // true (Brasília)
  print(V.string().ddd().validate('85')); // true (Fortaleza)

  section('DDD — códigos não atribuídos');

  print(V.string().ddd().validate('20')); // false
  print(V.string().ddd().validate('23')); // false
  print(V.string().ddd().validate('30')); // false
  print(V.string().ddd().validate('60')); // false
}

void main() => runDddExamples();
