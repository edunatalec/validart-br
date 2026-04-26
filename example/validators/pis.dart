import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import '../shared/fixtures.dart';

/// Exemplos de `V.string().pis()` — PIS / PASEP / NIS (11 dígitos com
/// DV mod-11).
void runPisExamples() {
  section('PIS — formatos aceitos');

  print(V.string().pis().validate('120.54789.01-3')); // true
  print(V.string().pis().validate('12054789013')); // true
  print(V.string().pis().validate('11111111111')); // false (repetido)
}

void main() => runPisExamples();
