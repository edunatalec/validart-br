import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('BrPlatePattern', () {
    test('name é Placa', () {
      expect(const BrPlatePattern().name, 'Placa');
    });

    test('aceita formato antigo (com e sem hífen) e Mercosul', () {
      const pattern = BrPlatePattern();
      expect(pattern.matches('ABC-1234'), isTrue);
      expect(pattern.matches('ABC1234'), isTrue);
      expect(pattern.matches('ABC1D23'), isTrue);
      expect(pattern.matches('BRA0S17'), isTrue);
    });

    test('rejeita lowercase / formato inválido', () {
      const pattern = BrPlatePattern();
      expect(pattern.matches('abc-1234'), isFalse);
      expect(pattern.matches('AB-1234'), isFalse);
      expect(pattern.matches('ABC-12345'), isFalse);
      expect(pattern.matches(''), isFalse);
    });

    test('mode: formatted exige hífen (mas Mercosul sempre passa)', () {
      const pattern = BrPlatePattern(mode: ValidationMode.formatted);
      expect(pattern.matches('ABC-1234'), isTrue);
      expect(pattern.matches('ABC1234'), isFalse);
      expect(pattern.matches('ABC1D23'), isTrue);
    });

    test('mode: unformatted rejeita hífen (mas Mercosul sempre passa)', () {
      const pattern = BrPlatePattern(mode: ValidationMode.unformatted);
      expect(pattern.matches('ABC1234'), isTrue);
      expect(pattern.matches('ABC-1234'), isFalse);
      expect(pattern.matches('ABC1D23'), isTrue);
    });

    group('integração', () {
      test('V.string().licensePlate(patterns:) valida', () {
        final schema = V.string().licensePlate(
          patterns: [const BrPlatePattern()],
        );
        expect(schema.validate('ABC-1234'), isTrue);
      });

      test('error code é license_plate', () {
        final schema = V.string().licensePlate(
          patterns: [const BrPlatePattern()],
        );
        final errors = schema.errors('invalid');
        expect(errors!.first.code, VStringCode.licensePlate);
      });

      test('mensagem em pt-BR interpola {name} como "Placa" (feminino)', () {
        V.setLocale(VLocaleBr.ptBr);
        final schema = V.string().plate();
        final errors = schema.errors('invalid');
        expect(errors!.first.message, 'Placa inválida');
      });

      test('atalho V.string().plate() encadeia com toUpperCase', () {
        final schema = V.string().toUpperCase().plate();
        expect(schema.validate('abc-1234'), isTrue);
        expect(schema.validate('abc1d23'), isTrue);
      });
    });
  });
}
