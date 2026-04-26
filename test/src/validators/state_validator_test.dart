import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('StateValidator — direto', () {
    test('aceita as 27 UFs brasileiras', () {
      const validator = StateValidator();
      for (final uf in StateValidator.states) {
        expect(validator.validate(uf), isNull, reason: 'UF $uf deveria passar');
      }
      expect(StateValidator.states.length, 27);
    });

    test('rejeita siglas que não são UF', () {
      const validator = StateValidator();
      expect(validator.validate('XY'), isNotNull);
      expect(validator.validate('ZZ'), isNotNull);
      expect(validator.validate('US'), isNotNull);
      expect(validator.validate('RG'), isNotNull); // não existe
    });

    test('rejeita caixa baixa (UF é uppercase)', () {
      const validator = StateValidator();
      expect(validator.validate('sp'), isNotNull);
      expect(validator.validate('Sp'), isNotNull);
      expect(validator.validate('rj'), isNotNull);
    });

    test('rejeita tamanho diferente de 2', () {
      const validator = StateValidator();
      expect(validator.validate(''), isNotNull);
      expect(validator.validate('S'), isNotNull);
      expect(validator.validate('SPP'), isNotNull);
      expect(validator.validate('São Paulo'), isNotNull);
    });

    test('rejeita strings com dígitos ou caracteres especiais', () {
      const validator = StateValidator();
      expect(validator.validate('S1'), isNotNull);
      expect(validator.validate('S '), isNotNull);
      expect(validator.validate('S-'), isNotNull);
    });
  });

  group('StateValidator — integração via V.string().state()', () {
    test('aceita UF válida', () {
      final schema = V.string().state();
      expect(schema.validate('SP'), isTrue);
      expect(schema.validate('TO'), isTrue);
      expect(schema.validate('DF'), isTrue);
    });

    test('rejeita UF inválida', () {
      final schema = V.string().state();
      expect(schema.validate('XY'), isFalse);
      expect(schema.validate('sp'), isFalse);
    });

    test('encadeia com toUpperCase para aceitar lowercase', () {
      final schema = V.string().toUpperCase().state();
      expect(schema.validate('sp'), isTrue);
      expect(schema.validate('rj'), isTrue);
    });

    test('código de erro é invalid_state', () {
      final schema = V.string().state();
      final errors = schema.errors('XX');
      expect(errors!.first.code, VStringCodeBr.invalidState);
    });

    test('respeita message customizada', () {
      final schema = V.string().state(message: 'Estado fora da Federação');
      expect(schema.errors('XX')!.first.message, 'Estado fora da Federação');
    });
  });

  group('StateValidator — locale pt-BR', () {
    setUp(() => V.setLocale(VLocaleBr.ptBr));
    tearDown(() => V.setLocale(const VLocale()));

    test('mensagem em pt-BR é "UF inválida"', () {
      final schema = V.string().state();
      final errors = schema.errors('ZZ');
      expect(errors!.first.message, 'UF inválida');
    });
  });
}
