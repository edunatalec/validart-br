import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('UfValidator — direto', () {
    test('aceita as 27 UFs brasileiras', () {
      const validator = UfValidator();
      for (final uf in UfValidator.ufs) {
        expect(validator.validate(uf), isNull, reason: 'UF $uf deveria passar');
      }
      expect(UfValidator.ufs.length, 27);
    });

    test('rejeita siglas que não são UF', () {
      const validator = UfValidator();
      expect(validator.validate('XY'), isNotNull);
      expect(validator.validate('ZZ'), isNotNull);
      expect(validator.validate('US'), isNotNull);
      expect(validator.validate('RG'), isNotNull); // não existe
    });

    test('rejeita caixa baixa (UF é uppercase)', () {
      const validator = UfValidator();
      expect(validator.validate('sp'), isNotNull);
      expect(validator.validate('Sp'), isNotNull);
      expect(validator.validate('rj'), isNotNull);
    });

    test('rejeita tamanho diferente de 2', () {
      const validator = UfValidator();
      expect(validator.validate(''), isNotNull);
      expect(validator.validate('S'), isNotNull);
      expect(validator.validate('SPP'), isNotNull);
      expect(validator.validate('São Paulo'), isNotNull);
    });

    test('rejeita strings com dígitos ou caracteres especiais', () {
      const validator = UfValidator();
      expect(validator.validate('S1'), isNotNull);
      expect(validator.validate('S '), isNotNull);
      expect(validator.validate('S-'), isNotNull);
    });
  });

  group('UfValidator — integração via V.string().uf()', () {
    test('aceita UF válida', () {
      final schema = V.string().uf();
      expect(schema.validate('SP'), isTrue);
      expect(schema.validate('TO'), isTrue);
      expect(schema.validate('DF'), isTrue);
    });

    test('rejeita UF inválida', () {
      final schema = V.string().uf();
      expect(schema.validate('XY'), isFalse);
      expect(schema.validate('sp'), isFalse);
    });

    test('encadeia com toUpperCase para aceitar lowercase', () {
      final schema = V.string().toUpperCase().uf();
      expect(schema.validate('sp'), isTrue);
      expect(schema.validate('rj'), isTrue);
    });

    test('código de erro é invalid_state', () {
      final schema = V.string().uf();
      final errors = schema.errors('XX');
      expect(errors!.first.code, VStringCodeBr.ufInvalida);
    });

    test('respeita message customizada', () {
      final schema = V.string().uf(message: 'Estado fora da Federação');
      expect(schema.errors('XX')!.first.message, 'Estado fora da Federação');
    });
  });

  group('UfValidator — locale pt-BR', () {
    setUp(() => V.setLocale(VLocaleBr.ptBr));
    tearDown(() => V.setLocale(const VLocale()));

    test('mensagem em pt-BR é "UF inválida"', () {
      final schema = V.string().uf();
      final errors = schema.errors('ZZ');
      expect(errors!.first.message, 'UF inválida');
    });
  });
}
