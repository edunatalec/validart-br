import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('CnpjPattern', () {
    test('name é CNPJ', () {
      expect(const CnpjPattern().name, 'CNPJ');
    });

    group('mode: any (default) — inclui alfanumérico', () {
      test('aceita CNPJ numérico formatado', () {
        const pattern = CnpjPattern();
        expect(pattern.matches('12.345.678/0001-95'), isTrue);
        expect(pattern.matches('11.222.333/0001-81'), isTrue);
        expect(pattern.matches('00.000.000/0001-91'), isTrue);
      });

      test('aceita CNPJ numérico sem máscara', () {
        const pattern = CnpjPattern();
        expect(pattern.matches('12345678000195'), isTrue);
      });

      test('aceita CNPJ alfanumérico (default)', () {
        const pattern = CnpjPattern();
        expect(pattern.matches('12ABC34501DE35'), isTrue);
        expect(pattern.matches('12.ABC.345/01DE-35'), isTrue);
      });

      test('rejeita CNPJ com checksum errado', () {
        const pattern = CnpjPattern();
        expect(pattern.matches('12.345.678/0001-00'), isFalse);
        expect(pattern.matches('12ABC34501DE00'), isFalse);
      });

      test('rejeita todos iguais / tamanho errado / lowercase', () {
        const pattern = CnpjPattern();
        expect(pattern.matches('11.111.111/1111-11'), isFalse);
        expect(pattern.matches('123'), isFalse);
        expect(pattern.matches('12abc34501de35'), isFalse);
      });
    });

    group('mode: formatted / unformatted', () {
      test('formatted exige máscara', () {
        const pattern = CnpjPattern(mode: ValidationMode.formatted);
        expect(pattern.matches('12.345.678/0001-95'), isTrue);
        expect(pattern.matches('12345678000195'), isFalse);
      });

      test('unformatted exige só dígitos', () {
        const pattern = CnpjPattern(mode: ValidationMode.unformatted);
        expect(pattern.matches('12345678000195'), isTrue);
        expect(pattern.matches('12.345.678/0001-95'), isFalse);
      });
    });

    group('alphanumeric: false (formato numérico antigo)', () {
      test('rejeita CNPJ alfanumérico mesmo que válido', () {
        const pattern = CnpjPattern(alphanumeric: false);
        expect(pattern.matches('12ABC34501DE35'), isFalse);
        expect(pattern.matches('12.ABC.345/01DE-35'), isFalse);
      });

      test('continua aceitando CNPJ numérico', () {
        const pattern = CnpjPattern(alphanumeric: false);
        expect(pattern.matches('12345678000195'), isTrue);
      });
    });

    group('integração', () {
      test('V.string().taxId(patterns:) valida', () {
        final VString schema = V.string().taxId(
          patterns: [const CnpjPattern()],
        );
        expect(schema.validate('12ABC34501DE35'), isTrue);
      });

      test('error code é tax_id', () {
        final VString schema = V.string().taxId(
          patterns: [const CnpjPattern()],
        );
        final List<VError>? errors = schema.errors('00.000.000/0000-00');
        expect(errors!.first.code, VStringCode.taxId);
      });

      test('mensagem em pt-BR interpola {name} como "CNPJ"', () {
        V.setLocale(VLocaleBr.ptBr);
        final VString schema = V.string().cnpj();
        final List<VError>? errors = schema.errors('00.000.000/0000-00');
        expect(errors!.first.message, 'CNPJ inválido');
      });

      test('atalho V.string().cnpj() aceita alfanumérico', () {
        expect(V.string().cnpj().validate('12ABC34501DE35'), isTrue);
      });

      test('atalho V.string().cnpj(alphanumeric: false)', () {
        final VString schema = V.string().cnpj(alphanumeric: false);
        expect(schema.validate('12345678000195'), isTrue);
        expect(schema.validate('12ABC34501DE35'), isFalse);
      });

      test('message customizada', () {
        final VString schema = V.string().cnpj(message: 'CNPJ incorreto');
        final List<VError>? errors = schema.errors('00.000.000/0000-00');
        expect(errors!.first.message, 'CNPJ incorreto');
      });
    });
  });
}
