import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import '../shared/fixtures.dart';

/// Exemplos de `V.string().state()` — sigla de UF brasileira (2
/// letras em caixa alta, dentre as 27 unidades federativas).
void runStateExamples() {
  section('UF — siglas válidas');

  print(V.string().state().validate('SP')); // true
  print(V.string().state().validate('RJ')); // true
  print(V.string().state().validate('DF')); // true
  print(V.string().state().validate('TO')); // true

  print(V.string().state().validate('XY')); // false (não existe)
  print(V.string().state().validate('sp')); // false (caixa baixa)

  section('UF — encadeando .toUpperCase()');

  print(V.string().toUpperCase().state().validate('rj')); // true
  print(V.string().toUpperCase().state().validate('Sp')); // true
}

void main() => runStateExamples();
