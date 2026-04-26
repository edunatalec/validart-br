import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import '../shared/fixtures.dart';

/// Exemplos de `V.string().placa()` — placa veicular brasileira
/// (formato antigo `AAA-9999` ou Mercosul `AAA9A99`).
void runPlacaExamples() {
  section('Placa — antiga e Mercosul');

  print(V.string().placa().validate('ABC-1234')); // true (antiga)
  print(V.string().placa().validate('ABC1234')); // true (sem hífen)
  print(V.string().placa().validate('ABC1D23')); // true (Mercosul)

  // Letras em caixa baixa: encadeie .toUpperCase().
  print(V.string().toUpperCase().placa().validate('abc-1234')); // true
  print(V.string().toUpperCase().placa().validate('abc1d23')); // true
}

void main() => runPlacaExamples();
