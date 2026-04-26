import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('RenavamPattern', () {
    test('name é Renavam', () {
      expect(const RenavamPattern().name, 'Renavam');
    });

    test('aceita Renavams válidos', () {
      const pattern = RenavamPattern();
      expect(pattern.matches('12345678900'), isTrue);
      expect(pattern.matches('98765432103'), isTrue);
      expect(pattern.matches('11111111124'), isTrue);
    });

    test('rejeita checksum errado / tamanho errado / não numérico', () {
      const pattern = RenavamPattern();
      expect(pattern.matches('12345678901'), isFalse);
      expect(pattern.matches('00000000000'), isFalse);
      expect(pattern.matches('1234567890'), isFalse);
      expect(pattern.matches('1234567890A'), isFalse);
    });

    group('integração', () {
      test('V.string().renavam() valida e retorna code tax_id', () {
        final VString schema = V.string().renavam();
        expect(schema.validate('12345678900'), isTrue);
        final List<VError>? errors = schema.errors('00000000000');
        expect(errors!.first.code, VStringCode.taxId);
      });

      test('mensagem em pt-BR interpola {name} como "Renavam"', () {
        V.setLocale(VLocaleBr.ptBr);
        final VString schema = V.string().renavam();
        final List<VError>? errors = schema.errors('00000000000');
        expect(errors!.first.message, 'Renavam inválido');
      });
    });
  });
}
