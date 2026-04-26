import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import '../shared/fixtures.dart';

/// Exemplos de `V.string().cnpj()` — CNPJ numérico ou alfanumérico
/// (formato novo da Receita, default desde julho/2026).
void runCnpjExamples() {
  section('CNPJ — alfanumérico (default)');

  print(V.string().cnpj().validate('12.345.678/0001-95')); // true (numérico)
  print(
    V.string().cnpj().validate('12.ABC.345/01DE-35'),
  ); // true (alfanumérico)

  section('CNPJ — restrito a numérico');

  print(
    V.string().cnpj(alfanumerico: false).validate('12345678000195'),
  ); // true
  print(
    V.string().cnpj(alfanumerico: false).validate('12.ABC.345/01DE-35'),
  ); // false

  section('CNPJ — caixa alta obrigatória, encadeie .toUpperCase()');

  print(V.string().toUpperCase().cnpj().validate('12.abc.345/01de-35')); // true
}

void main() => runCnpjExamples();
