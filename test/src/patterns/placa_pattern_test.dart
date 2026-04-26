import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('PlacaPattern', () {
    test('name é Placa', () {
      expect(const PlacaPattern().name, 'Placa');
    });

    test('aceita formato antigo (com e sem hífen) e Mercosul', () {
      const pattern = PlacaPattern();
      expect(pattern.matches('ABC-1234'), isTrue);
      expect(pattern.matches('ABC1234'), isTrue);
      expect(pattern.matches('ABC1D23'), isTrue);
      expect(pattern.matches('BRA0S17'), isTrue);
    });

    test('rejeita lowercase / formato inválido', () {
      const pattern = PlacaPattern();
      expect(pattern.matches('abc-1234'), isFalse);
      expect(pattern.matches('AB-1234'), isFalse);
      expect(pattern.matches('ABC-12345'), isFalse);
      expect(pattern.matches(''), isFalse);
    });

    test('mode: formatted exige hífen (mas Mercosul sempre passa)', () {
      const pattern = PlacaPattern(mode: ValidationMode.formatted);
      expect(pattern.matches('ABC-1234'), isTrue);
      expect(pattern.matches('ABC1234'), isFalse);
      expect(pattern.matches('ABC1D23'), isTrue);
    });

    test('mode: unformatted rejeita hífen (mas Mercosul sempre passa)', () {
      const pattern = PlacaPattern(mode: ValidationMode.unformatted);
      expect(pattern.matches('ABC1234'), isTrue);
      expect(pattern.matches('ABC-1234'), isFalse);
      expect(pattern.matches('ABC1D23'), isTrue);
    });

    group('integração', () {
      test('V.string().licensePlate(patterns:) valida', () {
        final VString schema = V.string().licensePlate(
          patterns: [const PlacaPattern()],
        );
        expect(schema.validate('ABC-1234'), isTrue);
      });

      test('error code é license_plate', () {
        final VString schema = V.string().licensePlate(
          patterns: [const PlacaPattern()],
        );
        final List<VError>? errors = schema.errors('invalid');
        expect(errors!.first.code, VStringCode.licensePlate);
      });

      test('mensagem em pt-BR interpola {name} como "Placa" (feminino)', () {
        V.setLocale(VLocaleBr.ptBr);
        final VString schema = V.string().placa();
        final List<VError>? errors = schema.errors('invalid');
        expect(errors!.first.message, 'Placa inválida');
      });

      test('atalho V.string().placa() encadeia com toUpperCase', () {
        final VString schema = V.string().toUpperCase().placa();
        expect(schema.validate('abc-1234'), isTrue);
        expect(schema.validate('abc1d23'), isTrue);
      });
    });
  });
}
