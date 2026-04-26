import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import '../shared/fixtures.dart';

/// Exemplos de `V.string().plate()` — placa veicular brasileira
/// (formato antigo `AAA-9999` ou Mercosul `AAA9A99`).
void runPlateExamples() {
  section('Placa — antiga e Mercosul');

  print(V.string().plate().validate('ABC-1234')); // true (antiga)
  print(V.string().plate().validate('ABC1234')); // true (sem hífen)
  print(V.string().plate().validate('ABC1D23')); // true (Mercosul)

  // Letras em caixa baixa: encadeie .toUpperCase().
  print(V.string().toUpperCase().plate().validate('abc-1234')); // true
  print(V.string().toUpperCase().plate().validate('abc1d23')); // true
}

void main() => runPlateExamples();
