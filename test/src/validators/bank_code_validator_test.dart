import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('BankCodeValidator — direto', () {
    test('aceita os principais bancos por código', () {
      const validator = BankCodeValidator();
      expect(validator.validate('001'), isNull); // Banco do Brasil
      expect(validator.validate('033'), isNull); // Santander
      expect(validator.validate('104'), isNull); // Caixa
      expect(validator.validate('237'), isNull); // Bradesco
      expect(validator.validate('341'), isNull); // Itaú
      expect(validator.validate('260'), isNull); // Nubank
      expect(validator.validate('077'), isNull); // Inter
      expect(validator.validate('212'), isNull); // Banco Original
      expect(validator.validate('336'), isNull); // C6 Bank
      expect(validator.validate('756'), isNull); // Sicoob
    });

    test('lista atualizada cobre 497 instituições', () {
      expect(BankCodeValidator.codes.length, 497);
    });

    test('rejeita códigos não atribuídos', () {
      const validator = BankCodeValidator();
      expect(validator.validate('999'), isNotNull);
      expect(validator.validate('000'), isNotNull);
      expect(validator.validate('002'), isNotNull); // não consta na tabela
      expect(validator.validate('200'), isNotNull); // não consta
    });

    test('rejeita formato sem zero à esquerda', () {
      const validator = BankCodeValidator();
      expect(validator.validate('1'), isNotNull); // deveria ser '001'
      expect(validator.validate('33'), isNotNull); // deveria ser '033'
    });

    test('rejeita tamanho diferente de 3', () {
      const validator = BankCodeValidator();
      expect(validator.validate(''), isNotNull);
      expect(validator.validate('00'), isNotNull);
      expect(validator.validate('0001'), isNotNull);
    });

    test('rejeita formato com DV (4 dígitos com hífen)', () {
      const validator = BankCodeValidator();
      expect(validator.validate('001-9'), isNotNull);
      expect(validator.validate('033-7'), isNotNull);
    });

    test('rejeita strings com letras', () {
      const validator = BankCodeValidator();
      expect(validator.validate('00A'), isNotNull);
      expect(validator.validate('abc'), isNotNull);
    });
  });

  group('BankCodeValidator — integração via V.string().bankCode()', () {
    test('aceita código válido', () {
      final schema = V.string().bankCode();
      expect(schema.validate('001'), isTrue);
      expect(schema.validate('260'), isTrue);
    });

    test('rejeita código inválido', () {
      final schema = V.string().bankCode();
      expect(schema.validate('999'), isFalse);
    });

    test('código de erro é invalid_bank_code', () {
      final schema = V.string().bankCode();
      final errors = schema.errors('999');
      expect(errors!.first.code, VStringCodeBr.invalidBankCode);
    });

    test('respeita message customizada', () {
      final schema = V.string().bankCode(message: 'Banco não autorizado');
      expect(schema.errors('999')!.first.message, 'Banco não autorizado');
    });
  });

  group('BankCodeValidator — locale pt-BR', () {
    setUp(() => V.setLocale(VLocaleBr.ptBr));
    tearDown(() => V.setLocale(const VLocale()));

    test('mensagem em pt-BR é "Código de banco inválido"', () {
      final schema = V.string().bankCode();
      final errors = schema.errors('999');
      expect(errors!.first.message, 'Código de banco inválido');
    });
  });
}
