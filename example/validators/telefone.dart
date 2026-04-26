import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import '../shared/fixtures.dart';

/// Exemplos de `V.string().telefone()` — telefone brasileiro com
/// flags de DDD, DDI, modo móvel e máscara.
void runTelefoneExamples() {
  section('Telefone BR — defaults flexíveis');

  // Aceita celular e fixo, com ou sem DDD/DDI.
  print(V.string().telefone().validate('(11) 98765-4321')); // true
  print(V.string().telefone().validate('11987654321')); // true
  print(V.string().telefone().validate('+55 11 98765-4321')); // true
  print(V.string().telefone().validate('1133334444')); // true (fixo)

  section('Telefone BR — restrito');

  final schema = V.string().telefone(
    pais: CountryCodeFormat.required,
    ddd: FormatoDdd.required,
    apenasCelular: true,
    mode: ValidationMode.formatted,
  );
  print(schema.validate('+55 (11) 98765-4321')); // true
  print(schema.validate('+5511987654321')); // false (sem máscara)
  print(schema.validate('11987654321')); // false (sem DDI)
  print(schema.validate('+55 (11) 3333-4444')); // false (fixo)
}

void main() => runTelefoneExamples();
