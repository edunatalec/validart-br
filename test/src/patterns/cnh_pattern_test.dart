import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('CnhPattern', () {
    test('name é CNH', () {
      expect(const CnhPattern().name, 'CNH');
    });

    test('aceita CNHs válidas', () {
      const pattern = CnhPattern();
      expect(pattern.matches('12345678900'), isTrue);
      expect(pattern.matches('98765432109'), isTrue);
      expect(pattern.matches('11122233369'), isTrue);
    });

    test('rejeita checksum errado / repetido / tamanho', () {
      const pattern = CnhPattern();
      expect(pattern.matches('12345678901'), isFalse);
      expect(pattern.matches('00000000000'), isFalse);
      expect(pattern.matches('1234567890'), isFalse);
    });

    group('integração', () {
      test('V.string().cnh() valida e retorna code tax_id', () {
        final VString schema = V.string().cnh();
        expect(schema.validate('12345678900'), isTrue);
        final List<VError>? errors = schema.errors('00000000000');
        expect(errors!.first.code, VStringCode.taxId);
      });

      test('mensagem em pt-BR interpola {name} como "CNH"', () {
        V.setLocale(VLocaleBr.ptBr);
        final VString schema = V.string().cnh();
        final List<VError>? errors = schema.errors('00000000000');
        expect(errors!.first.message, 'CNH inválido');
      });
    });
  });
}
