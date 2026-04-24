import 'package:test/test.dart';
import 'package:validart_br/src/string_utils.dart';

void main() {
  group('StringUtils.onlyDigits', () {
    test('extrai dígitos de string com máscara', () {
      expect('123.456.789-09'.onlyDigits, '12345678909');
      expect('+55 (11) 98765-4321'.onlyDigits, '5511987654321');
    });

    test('mantém string só de dígitos', () {
      expect('12345678909'.onlyDigits, '12345678909');
    });

    test('retorna vazio quando não há dígitos', () {
      expect('abc-def'.onlyDigits, '');
      expect(''.onlyDigits, '');
    });
  });

  group('StringUtils.isRepeatedCharacters', () {
    test('retorna false para string vazia', () {
      expect(''.isRepeatedCharacters, isFalse);
    });

    test('retorna true para um único caractere', () {
      expect('7'.isRepeatedCharacters, isTrue);
      expect('A'.isRepeatedCharacters, isTrue);
    });

    test('retorna true quando todos os caracteres são iguais', () {
      expect('00000000000'.isRepeatedCharacters, isTrue);
      expect('11111111111'.isRepeatedCharacters, isTrue);
      expect('AAAA'.isRepeatedCharacters, isTrue);
    });

    test('retorna false quando há pelo menos um caractere diferente', () {
      expect('11111111112'.isRepeatedCharacters, isFalse);
      expect('21111111111'.isRepeatedCharacters, isFalse);
      expect('12054789013'.isRepeatedCharacters, isFalse);
    });
  });
}
