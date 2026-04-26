import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('CpfPattern', () {
    test('name é CPF', () {
      expect(const CpfPattern().name, 'CPF');
    });

    group('mode: any (default)', () {
      test('aceita CPF formatado válido', () {
        const pattern = CpfPattern();
        expect(pattern.matches('123.456.789-09'), isTrue);
        expect(pattern.matches('111.444.777-35'), isTrue);
        expect(pattern.matches('529.982.247-25'), isTrue);
      });

      test('aceita CPF só dígitos válido', () {
        const pattern = CpfPattern();
        expect(pattern.matches('12345678909'), isTrue);
        expect(pattern.matches('11144477735'), isTrue);
      });

      test('rejeita CPF com checksum errado', () {
        const pattern = CpfPattern();
        expect(pattern.matches('123.456.789-00'), isFalse);
        expect(pattern.matches('11144477736'), isFalse);
      });

      test('rejeita CPF com todos os dígitos iguais', () {
        const pattern = CpfPattern();
        expect(pattern.matches('111.111.111-11'), isFalse);
        expect(pattern.matches('00000000000'), isFalse);
      });

      test('rejeita tamanho errado e formato inválido', () {
        const pattern = CpfPattern();
        expect(pattern.matches('123'), isFalse);
        expect(pattern.matches('123456789012'), isFalse);
        expect(pattern.matches('123-456-789.09'), isFalse);
      });
    });

    group('mode: formatted', () {
      test('aceita só CPF formatado', () {
        const pattern = CpfPattern(mode: ValidationMode.formatted);
        expect(pattern.matches('123.456.789-09'), isTrue);
        expect(pattern.matches('12345678909'), isFalse);
      });
    });

    group('mode: unformatted', () {
      test('aceita só CPF sem máscara', () {
        const pattern = CpfPattern(mode: ValidationMode.unformatted);
        expect(pattern.matches('12345678909'), isTrue);
        expect(pattern.matches('123.456.789-09'), isFalse);
      });
    });

    group('integração — V.string().taxId(patterns: …)', () {
      test('valida via método genérico do core', () {
        final VString schema = V.string().taxId(patterns: [const CpfPattern()]);
        expect(schema.validate('123.456.789-09'), isTrue);
        expect(schema.validate('111.111.111-11'), isFalse);
      });

      test('error code é tax_id (genérico do core)', () {
        final VString schema = V.string().taxId(patterns: [const CpfPattern()]);
        final List<VError>? errors = schema.errors('000.000.000-00');
        expect(errors!.first.code, VStringCode.taxId);
      });

      test('mensagem com VLocaleBr.ptBr interpola {name}', () {
        V.setLocale(VLocaleBr.ptBr);
        final VString schema = V.string().taxId(patterns: [const CpfPattern()]);
        final List<VError>? errors = schema.errors('000.000.000-00');
        expect(errors!.first.message, 'CPF inválido');
      });
    });

    group('integração — atalho V.string().cpf()', () {
      test('comporta como taxId(patterns: [const CpfPattern()])', () {
        expect(V.string().cpf().validate('123.456.789-09'), isTrue);
        expect(V.string().cpf().validate('111.111.111-11'), isFalse);
      });

      test('respeita mode', () {
        final VString schema = V.string().cpf(modo: ModoValidacao.semMascara);
        expect(schema.validate('12345678909'), isTrue);
        expect(schema.validate('123.456.789-09'), isFalse);
      });

      test('respeita message customizada', () {
        final VString schema = V.string().cpf(
          mensagem: 'CPF inválido, meu caro',
        );
        final List<VError>? errors = schema.errors('000.000.000-00');
        expect(errors!.first.message, 'CPF inválido, meu caro');
      });
    });
  });
}
