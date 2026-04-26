import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('DddValidator — direto', () {
    test('aceita os 67 DDDs em uso', () {
      const validator = DddValidator();
      for (final ddd in DddValidator.ddds) {
        expect(
          validator.validate(ddd),
          isNull,
          reason: 'DDD $ddd deveria passar',
        );
      }
      expect(DddValidator.ddds.length, 67);
    });

    test('aceita capitais clássicas', () {
      const validator = DddValidator();
      expect(validator.validate('11'), isNull); // São Paulo
      expect(validator.validate('21'), isNull); // Rio de Janeiro
      expect(validator.validate('31'), isNull); // Belo Horizonte
      expect(validator.validate('41'), isNull); // Curitiba
      expect(validator.validate('51'), isNull); // Porto Alegre
      expect(validator.validate('61'), isNull); // Brasília
      expect(validator.validate('71'), isNull); // Salvador
      expect(validator.validate('81'), isNull); // Recife
      expect(validator.validate('85'), isNull); // Fortaleza
      expect(validator.validate('92'), isNull); // Manaus
    });

    test('rejeita DDDs não atribuídos', () {
      const validator = DddValidator();
      expect(validator.validate('20'), isNotNull);
      expect(validator.validate('23'), isNotNull);
      expect(validator.validate('25'), isNotNull);
      expect(validator.validate('26'), isNotNull);
      expect(validator.validate('29'), isNotNull);
      expect(validator.validate('30'), isNotNull);
      expect(validator.validate('36'), isNotNull);
      expect(validator.validate('39'), isNotNull);
      expect(validator.validate('40'), isNotNull);
      expect(validator.validate('50'), isNotNull);
      expect(validator.validate('52'), isNotNull);
      expect(validator.validate('60'), isNotNull);
      expect(validator.validate('70'), isNotNull);
      expect(validator.validate('72'), isNotNull);
      expect(validator.validate('76'), isNotNull);
      expect(validator.validate('78'), isNotNull);
      expect(validator.validate('80'), isNotNull);
      expect(validator.validate('90'), isNotNull);
    });

    test('rejeita tamanho diferente de 2', () {
      const validator = DddValidator();
      expect(validator.validate(''), isNotNull);
      expect(validator.validate('1'), isNotNull);
      expect(validator.validate('111'), isNotNull);
    });

    test('rejeita formato com máscara ou letras', () {
      const validator = DddValidator();
      expect(validator.validate('(11)'), isNotNull);
      expect(validator.validate('11 '), isNotNull);
      expect(validator.validate('1A'), isNotNull);
    });
  });

  group('DddValidator — integração via V.string().ddd()', () {
    test('aceita DDD válido', () {
      final schema = V.string().ddd();
      expect(schema.validate('11'), isTrue);
      expect(schema.validate('99'), isTrue);
    });

    test('rejeita DDD inválido', () {
      final schema = V.string().ddd();
      expect(schema.validate('00'), isFalse);
      expect(schema.validate('20'), isFalse);
    });

    test('código de erro é invalid_ddd', () {
      final schema = V.string().ddd();
      final errors = schema.errors('00');
      expect(errors!.first.code, VStringCodeBr.dddInvalido);
    });

    test('respeita message customizada', () {
      final schema = V.string().ddd(message: 'DDD fora da Anatel');
      expect(schema.errors('00')!.first.message, 'DDD fora da Anatel');
    });
  });

  group('DddValidator — locale pt-BR', () {
    setUp(() => V.setLocale(VLocaleBr.ptBr));
    tearDown(() => V.setLocale(const VLocale()));

    test('mensagem em pt-BR é "DDD inválido"', () {
      final schema = V.string().ddd();
      final errors = schema.errors('00');
      expect(errors!.first.message, 'DDD inválido');
    });
  });
}
