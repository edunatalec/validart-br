import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import '../shared/fixtures.dart';

/// Exemplos de `V.string().pixKey()` — chave PIX (DICT) e/ou BR Code
/// (payload EMVCo do QR Code).
void runPixKeyExamples() {
  section('PIX — defaults aceitam as 5 chaves do DICT');

  print(V.string().pixKey().validate('12345678909')); // true (CPF)
  print(V.string().pixKey().validate('12345678000195')); // true (CNPJ)
  print(V.string().pixKey().validate('user@example.com')); // true (e-mail)
  print(V.string().pixKey().validate('+5511987654321')); // true (telefone)
  print(
    V.string().pixKey().validate('123e4567-e89b-12d3-a456-426614174000'),
  ); // true (UUID)

  // CPF formatado é rejeitado — PIX exige formato estrito.
  print(V.string().pixKey().validate('123.456.789-09')); // false

  section('PIX — restringindo tipos com [allow]');

  final emailOuTelefone = V.string().pixKey(
    allow: const [PixKeyType.email, PixKeyType.phone],
  );
  print(emailOuTelefone.validate('user@example.com')); // true
  print(emailOuTelefone.validate('+5511987654321')); // true
  print(emailOuTelefone.validate('12345678909')); // false (CPF rejeitado)

  section('PIX — incluindo BR Code');

  // Adicione PixKeyType.brCode em allow para aceitar o payload do
  // QR Code ("copia e cola"), validado com CRC16 e campos do Bacen.
  final completo = V.string().pixKey(allow: PixKeyType.values);
  print(completo.validate(kPixBrCodeUuid)); // true
  print(completo.validate(kPixBrCodeEmail)); // true

  // Só BR Code:
  final soBrCode = V.string().pixKey(allow: const [PixKeyType.brCode]);
  print(soBrCode.validate(kPixBrCodeUuid)); // true
  print(soBrCode.validate('12345678909')); // false (CPF não está em allow)
}

void main() => runPixKeyExamples();
