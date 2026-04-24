import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('PisPattern', () {
    test('name é PIS/PASEP', () {
      expect(const PisPattern().name, 'PIS/PASEP');
    });

    test('aceita PIS válido formatado e sem máscara', () {
      const pattern = PisPattern();
      expect(pattern.matches('120.54789.01-3'), isTrue);
      expect(pattern.matches('12054789013'), isTrue);
      expect(pattern.matches('17033259504'), isTrue);
    });

    test('rejeita PIS com checksum errado / repetido / tamanho errado', () {
      const pattern = PisPattern();
      expect(pattern.matches('12054789010'), isFalse);
      expect(pattern.matches('00000000000'), isFalse);
      expect(pattern.matches('123'), isFalse);
    });

    group('mode: formatted', () {
      test('aceita só PIS formatado', () {
        const pattern = PisPattern(mode: ValidationMode.formatted);
        expect(pattern.matches('120.54789.01-3'), isTrue);
        expect(pattern.matches('12054789013'), isFalse);
      });
    });

    group('mode: unformatted', () {
      test('aceita só PIS sem máscara', () {
        const pattern = PisPattern(mode: ValidationMode.unformatted);
        expect(pattern.matches('12054789013'), isTrue);
        expect(pattern.matches('120.54789.01-3'), isFalse);
      });
    });

    group('integração', () {
      test('V.string().taxId(patterns:) valida', () {
        final schema = V.string().taxId(patterns: [const PisPattern()]);
        expect(schema.validate('12054789013'), isTrue);
      });

      test('error code é tax_id', () {
        final schema = V.string().taxId(patterns: [const PisPattern()]);
        final errors = schema.errors('00000000000');
        expect(errors!.first.code, VStringCode.taxId);
      });

      test('mensagem em pt-BR interpola {name} como "PIS/PASEP"', () {
        V.setLocale(VLocaleBr.ptBr);
        final schema = V.string().pis();
        final errors = schema.errors('00000000000');
        expect(errors!.first.message, 'PIS/PASEP inválido');
      });

      test('atalho V.string().pis()', () {
        expect(V.string().pis().validate('12054789013'), isTrue);
      });
    });
  });
}
