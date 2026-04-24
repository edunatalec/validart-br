import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('CepPattern', () {
    test('name é CEP', () {
      expect(const CepPattern().name, 'CEP');
    });

    test('aceita CEP formatado e sem máscara', () {
      const pattern = CepPattern();
      expect(pattern.matches('01001-000'), isTrue);
      expect(pattern.matches('01001000'), isTrue);
      expect(pattern.matches('22021-001'), isTrue);
    });

    test('rejeita CEP com todos dígitos iguais', () {
      const pattern = CepPattern();
      expect(pattern.matches('00000-000'), isFalse);
      expect(pattern.matches('11111111'), isFalse);
    });

    test('rejeita formato inválido / tamanho errado', () {
      const pattern = CepPattern();
      expect(pattern.matches('0100100'), isFalse);
      expect(pattern.matches('01001_000'), isFalse);
    });

    test('mode: formatted exige máscara', () {
      const pattern = CepPattern(mode: ValidationMode.formatted);
      expect(pattern.matches('01001-000'), isTrue);
      expect(pattern.matches('01001000'), isFalse);
    });

    test('mode: unformatted rejeita máscara', () {
      const pattern = CepPattern(mode: ValidationMode.unformatted);
      expect(pattern.matches('01001000'), isTrue);
      expect(pattern.matches('01001-000'), isFalse);
    });

    group('integração', () {
      test('V.string().postalCode(patterns:) valida', () {
        final schema = V.string().postalCode(patterns: [const CepPattern()]);
        expect(schema.validate('01001-000'), isTrue);
      });

      test('error code é postal_code', () {
        final schema = V.string().postalCode(patterns: [const CepPattern()]);
        final errors = schema.errors('00000-000');
        expect(errors!.first.code, VStringCode.postalCode);
      });

      test('mensagem em pt-BR interpola {name} como "CEP"', () {
        V.setLocale(VLocaleBr.ptBr);
        final schema = V.string().cep();
        final errors = schema.errors('00000-000');
        expect(errors!.first.message, 'CEP inválido');
      });

      test('atalho V.string().cep()', () {
        expect(V.string().cep().validate('01001-000'), isTrue);
        expect(V.string().cep().validate('00000-000'), isFalse);
      });
    });
  });
}
