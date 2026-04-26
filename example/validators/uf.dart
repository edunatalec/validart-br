import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import '../shared/fixtures.dart';

/// Exemplos de `V.string().uf()` — sigla de UF brasileira (2
/// letras em caixa alta, dentre as 27 unidades federativas).
void runUfExamples() {
  section('UF — siglas válidas');

  print(V.string().uf().validate('SP')); // true
  print(V.string().uf().validate('RJ')); // true
  print(V.string().uf().validate('DF')); // true
  print(V.string().uf().validate('TO')); // true

  print(V.string().uf().validate('XY')); // false (não existe)
  print(V.string().uf().validate('sp')); // false (caixa baixa)

  section('UF — encadeando .toUpperCase()');

  print(V.string().toUpperCase().uf().validate('rj')); // true
  print(V.string().toUpperCase().uf().validate('Sp')); // true
}

void main() => runUfExamples();
