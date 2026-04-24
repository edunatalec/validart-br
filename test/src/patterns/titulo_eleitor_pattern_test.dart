import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('TituloEleitorPattern', () {
    test('name é Título de eleitor', () {
      expect(const TituloEleitorPattern().name, 'Título de eleitor');
    });

    test('aceita títulos válidos (UF 03, 04, 01, 28, SP exceção)', () {
      const pattern = TituloEleitorPattern();
      expect(pattern.matches('876543210329'), isTrue);
      expect(pattern.matches('112233440493'), isTrue);
      expect(pattern.matches('000000010191'), isTrue);
      expect(pattern.matches('111111112801'), isTrue);
      expect(pattern.matches('999999990116'), isTrue);
    });

    test('rejeita checksum errado / UF inválida / tamanho errado', () {
      const pattern = TituloEleitorPattern();
      expect(pattern.matches('876543210320'), isFalse);
      expect(pattern.matches('123456780099'), isFalse); // UF 00
      expect(pattern.matches('123456782999'), isFalse); // UF 29
      expect(pattern.matches('87654321032'), isFalse);
    });

    group('integração', () {
      test('V.string().taxId(patterns:) valida', () {
        final schema = V.string().taxId(
          patterns: [const TituloEleitorPattern()],
        );
        expect(schema.validate('876543210329'), isTrue);
      });

      test('atalho V.string().tituloEleitor()', () {
        expect(V.string().tituloEleitor().validate('876543210329'), isTrue);
      });

      test('error code é tax_id', () {
        final schema = V.string().tituloEleitor();
        final errors = schema.errors('000000000000');
        expect(errors!.first.code, VStringCode.taxId);
      });

      test('mensagem em pt-BR interpola {name} como "Título de eleitor"', () {
        V.setLocale(VLocaleBr.ptBr);
        final schema = V.string().tituloEleitor();
        final errors = schema.errors('000000000000');
        expect(errors!.first.message, 'Título de eleitor inválido');
      });
    });
  });
}
