import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import '../shared/fixtures.dart';

/// Exemplos de `V.string().cnh()` — Carteira Nacional de Habilitação
/// (11 dígitos com DV mod-11 do Detran).
void runCnhExamples() {
  section('CNH');

  print(V.string().cnh().validate('12345678900')); // true
  print(V.string().cnh().validate('00000000000')); // false (repetido)

  // Override do gênero gramatical da mensagem default ("CNH inválido"
  // → "CNH inválida"):
  V.setLocale(VLocaleBr.ptBr);
  final schema = V.string().cnh(message: 'CNH inválida');
  print(schema.errors('00000000000')!.first.message); // 'CNH inválida'
  V.setLocale(const VLocale());
}

void main() => runCnhExamples();
