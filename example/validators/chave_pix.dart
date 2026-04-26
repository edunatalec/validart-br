import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import '../shared/fixtures.dart';

/// Exemplos de `V.string().chavePix()` — chave PIX (DICT) e/ou BR Code
/// (payload EMVCo do QR Code).
void runChavePixExamples() {
  section('PIX — defaults aceitam as 5 chaves do DICT');

  print(V.string().chavePix().validate('12345678909')); // true (CPF)
  print(V.string().chavePix().validate('12345678000195')); // true (CNPJ)
  print(V.string().chavePix().validate('user@example.com')); // true (e-mail)
  print(V.string().chavePix().validate('+5511987654321')); // true (telefone)
  print(
    V.string().chavePix().validate('123e4567-e89b-12d3-a456-426614174000'),
  ); // true (UUID)

  // CPF formatado é rejeitado — PIX exige formato estrito.
  print(V.string().chavePix().validate('123.456.789-09')); // false

  section('PIX — restringindo tipos com [allow]');

  final emailOuTelefone = V.string().chavePix(
    allow: const [TipoChavePix.email, TipoChavePix.telefone],
  );
  print(emailOuTelefone.validate('user@example.com')); // true
  print(emailOuTelefone.validate('+5511987654321')); // true
  print(emailOuTelefone.validate('12345678909')); // false (CPF rejeitado)

  section('PIX — incluindo BR Code');

  // Adicione TipoChavePix.brCode em allow para aceitar o payload do
  // QR Code ("copia e cola"), validado com CRC16 e campos do Bacen.
  final completo = V.string().chavePix(allow: TipoChavePix.values);
  print(completo.validate(kPixBrCodeUuid)); // true
  print(completo.validate(kPixBrCodeEmail)); // true

  // Só BR Code:
  final soBrCode = V.string().chavePix(allow: const [TipoChavePix.brCode]);
  print(soBrCode.validate(kPixBrCodeUuid)); // true
  print(soBrCode.validate('12345678909')); // false (CPF não está em allow)
}

void main() => runChavePixExamples();
