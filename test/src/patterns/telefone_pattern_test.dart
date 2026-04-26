import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('TelefonePattern', () {
    group('defaults (DDI opcional, DDD opcional, any mode)', () {
      test('aceita celular com DDD', () {
        final VString schema = V.string().phone(
          patterns: [const TelefonePattern()],
        );
        expect(schema.validate('(11) 98765-4321'), isTrue);
        expect(schema.validate('11987654321'), isTrue);
        expect(schema.validate('11 98765 4321'), isTrue);
      });

      test('aceita fixo com DDD', () {
        final VString schema = V.string().phone(
          patterns: [const TelefonePattern()],
        );
        expect(schema.validate('(11) 3333-4444'), isTrue);
        expect(schema.validate('1133334444'), isTrue);
      });

      test('aceita celular sem DDD', () {
        final VString schema = V.string().phone(
          patterns: [const TelefonePattern()],
        );
        expect(schema.validate('98765-4321'), isTrue);
        expect(schema.validate('987654321'), isTrue);
      });

      test('aceita fixo sem DDD', () {
        final VString schema = V.string().phone(
          patterns: [const TelefonePattern()],
        );
        expect(schema.validate('3333-4444'), isTrue);
        expect(schema.validate('33334444'), isTrue);
      });

      test('aceita com DDI +55 e DDD', () {
        final VString schema = V.string().phone(
          patterns: [const TelefonePattern()],
        );
        expect(schema.validate('+55 11 98765-4321'), isTrue);
        expect(schema.validate('+5511987654321'), isTrue);
        expect(schema.validate('+55 (11) 98765-4321'), isTrue);
      });

      test('rejeita DDD inexistente', () {
        final VString schema = V.string().phone(
          patterns: [const TelefonePattern()],
        );
        expect(schema.validate('(20) 98765-4321'), isFalse);
        expect(schema.validate('(10) 98765-4321'), isFalse);
        expect(schema.validate('(00) 98765-4321'), isFalse);
      });

      test('rejeita celular que não começa com 9', () {
        final VString schema = V.string().phone(
          patterns: [const TelefonePattern()],
        );
        expect(schema.validate('11 88765-4321'), isFalse);
      });

      test('rejeita +55 sem DDD (combinação inválida)', () {
        final VString schema = V.string().phone(
          patterns: [const TelefonePattern()],
        );
        expect(schema.validate('+55 98765-4321'), isFalse);
        expect(schema.validate('+5598765-4321'), isFalse);
        expect(schema.validate('+55987654321'), isFalse);
      });
    });

    group('pais: required', () {
      test('aceita com +55', () {
        final VString schema = V.string().phone(
          patterns: [
            const TelefonePattern(countryCode: CountryCodeFormat.required),
          ],
        );
        expect(schema.validate('+55 11 98765-4321'), isTrue);
      });

      test('rejeita sem +55', () {
        final VString schema = V.string().phone(
          patterns: [
            const TelefonePattern(countryCode: CountryCodeFormat.required),
          ],
        );
        expect(schema.validate('(11) 98765-4321'), isFalse);
      });
    });

    group('pais: none', () {
      test('rejeita com +55', () {
        final VString schema = V.string().phone(
          patterns: [
            const TelefonePattern(countryCode: CountryCodeFormat.none),
          ],
        );
        expect(schema.validate('+55 11 98765-4321'), isFalse);
      });

      test('aceita sem +55', () {
        final VString schema = V.string().phone(
          patterns: [
            const TelefonePattern(countryCode: CountryCodeFormat.none),
          ],
        );
        expect(schema.validate('(11) 98765-4321'), isTrue);
      });
    });

    group('ddd: required', () {
      test('aceita com DDD', () {
        final VString schema = V.string().phone(
          patterns: [const TelefonePattern(areaCode: FormatoDdd.obrigatorio)],
        );
        expect(schema.validate('11987654321'), isTrue);
      });

      test('rejeita sem DDD', () {
        final VString schema = V.string().phone(
          patterns: [const TelefonePattern(areaCode: FormatoDdd.obrigatorio)],
        );
        expect(schema.validate('987654321'), isFalse);
        expect(schema.validate('98765-4321'), isFalse);
      });
    });

    group('ddd: none', () {
      test('rejeita com DDD', () {
        final VString schema = V.string().phone(
          patterns: [const TelefonePattern(areaCode: FormatoDdd.nenhum)],
        );
        expect(schema.validate('(11) 98765-4321'), isFalse);
      });

      test('aceita sem DDD', () {
        final VString schema = V.string().phone(
          patterns: [const TelefonePattern(areaCode: FormatoDdd.nenhum)],
        );
        expect(schema.validate('98765-4321'), isTrue);
      });
    });

    group('mobileOnly', () {
      test('aceita celular', () {
        final VString schema = V.string().phone(
          patterns: [const TelefonePattern(mobileOnly: true)],
        );
        expect(schema.validate('11987654321'), isTrue);
      });

      test('rejeita fixo', () {
        final VString schema = V.string().phone(
          patterns: [const TelefonePattern(mobileOnly: true)],
        );
        expect(schema.validate('1133334444'), isFalse);
        expect(schema.validate('(11) 3333-4444'), isFalse);
      });
    });

    group('mode', () {
      test('formatted rejeita só dígitos', () {
        final VString schema = V.string().phone(
          patterns: [const TelefonePattern(mode: ValidationMode.formatted)],
        );
        expect(schema.validate('11987654321'), isFalse);
        expect(schema.validate('(11) 98765-4321'), isTrue);
      });

      test('unformatted rejeita com separadores', () {
        final VString schema = V.string().phone(
          patterns: [const TelefonePattern(mode: ValidationMode.unformatted)],
        );
        expect(schema.validate('(11) 98765-4321'), isFalse);
        expect(schema.validate('11987654321'), isTrue);
      });
    });

    test('retorna o código invalid_phone do core', () {
      final VString schema = V.string().phone(
        patterns: [const TelefonePattern()],
      );
      final List<VError>? errors = schema.errors('not-a-phone');
      expect(errors!.first.code, VStringCode.phone);
    });

    test('mensagem em pt-BR é "Telefone inválido"', () {
      V.setLocale(VLocaleBr.ptBr);
      final VString schema = V.string().telefone();
      final List<VError>? errors = schema.errors('not-a-phone');
      expect(errors!.first.message, 'Telefone inválido');
    });

    test('combinação: DDI+DDD required, mobile only', () {
      final VString schema = V.string().phone(
        patterns: [
          const TelefonePattern(
            countryCode: CountryCodeFormat.required,
            areaCode: FormatoDdd.obrigatorio,
            mobileOnly: true,
          ),
        ],
      );
      expect(schema.validate('+5511987654321'), isTrue);
      expect(schema.validate('+551133334444'), isFalse);
      expect(schema.validate('11987654321'), isFalse);
    });
  });
}
