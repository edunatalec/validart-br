import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import '../shared/fixtures.dart';

/// Exemplos de `V.string().renavam()` — Registro Nacional de
/// Veículos Automotores (11 dígitos com DV mod-11).
void runRenavamExamples() {
  section('Renavam');

  print(V.string().renavam().validate('12345678900')); // true
}

void main() => runRenavamExamples();
