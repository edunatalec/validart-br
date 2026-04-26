import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import '../shared/fixtures.dart';

/// Exemplos de `V.string().tituloEleitor()` — 12 dígitos com UF nas
/// posições 9-10 (`01..28`).
void runTituloEleitorExamples() {
  section('Título de eleitor');

  print(V.string().tituloEleitor().validate('876543210329')); // true
  print(V.string().tituloEleitor().validate('123456780099')); // false (UF 00)
}

void main() => runTituloEleitorExamples();
