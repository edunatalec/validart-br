import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import '../shared/fixtures.dart';

/// Exemplos de `V.string().cpf()` — validador de CPF (11 dígitos com
/// dois DVs, rejeita sequências repetidas).
void runCpfExamples() {
  section('CPF — modos de máscara');

  // Default (any) — aceita com ou sem máscara.
  print(V.string().cpf().validate('123.456.789-09')); // true
  print(V.string().cpf().validate('12345678909')); // true
  print(V.string().cpf().validate('111.111.111-11')); // false (repetido)

  // Mode pinning.
  print(
    V.string().cpf(mode: ValidationMode.formatted).validate('12345678909'),
  ); // false
  print(
    V.string().cpf(mode: ValidationMode.unformatted).validate('123.456.789-09'),
  ); // false

  section('CPF — equivalência atalho ↔ pattern');

  // Atalho.
  print(V.string().cpf().validate('123.456.789-09')); // true
  // Forma explícita via pattern do core.
  print(
    V.string().taxId(patterns: [const CpfPattern()]).validate('123.456.789-09'),
  ); // true
}

void main() => runCpfExamples();
