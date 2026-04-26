import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import '../shared/fixtures.dart';

/// Exemplos da forma explícita via patterns plugáveis do core. Cada
/// atalho de extension (`.cpf()`, `.cep()`, `.placa()`, `.telefone()`)
/// tem uma forma equivalente que passa o pattern direto pra
/// `V.string().taxId(patterns: [...])` (ou `postalCode`,
/// `licensePlate`, `phone`).
///
/// A forma explícita é o caminho pra compor múltiplos países na
/// mesma validação.
void runPatternsExamples() {
  section('Equivalências atalho ↔ pattern');

  // Sempre equivalentes.
  print(V.string().cpf().validate('123.456.789-09')); // true
  print(
    V.string().taxId(patterns: [const CpfPattern()]).validate('123.456.789-09'),
  ); // true

  print(V.string().cep().validate('01001-000')); // true
  print(
    V.string().postalCode(patterns: [const CepPattern()]).validate('01001-000'),
  ); // true

  print(V.string().placa().validate('ABC-1234')); // true
  print(
    V
        .string()
        .licensePlate(patterns: [const PlacaPattern()])
        .validate('ABC-1234'),
  ); // true

  section('Multi-país — composição BR + outros via patterns: [...]');

  // Aceita CPF brasileiro OU SSN americano.
  final taxIdMulti = V.string().taxId(
    patterns: [const CpfPattern(), const UsSsnPattern()],
  );
  print(taxIdMulti.validate('123.456.789-09')); // true (CPF)
  print(taxIdMulti.validate('123-45-6789')); // true (SSN)
  print(taxIdMulti.validate('xxx')); // false

  // Aceita CEP brasileiro OU ZIP americano.
  final cepOuZip = V.string().postalCode(
    patterns: [const CepPattern(), const UsZipPattern()],
  );
  print(cepOuZip.validate('01001-000')); // true (CEP)
  print(cepOuZip.validate('94103')); // true (ZIP)
}

void main() => runPatternsExamples();
