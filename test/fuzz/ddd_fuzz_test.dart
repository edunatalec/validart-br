@Tags(['fuzz'])
library;

import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import 'fuzz_helpers.dart';

void main() {
  group('DddValidator fuzz', () {
    final VString schema = V.string().ddd();
    const validator = DddValidator();

    test('nunca lança com input adversarial', () {
      fuzz('bool out on adversarial', (rng, _) {
        final String input = randomAdversarial(rng, rng.nextInt(15) + 1);

        expect(schema.validate(input), isA<bool>());
      });
    });

    test('strings com tamanho != 2 nunca passam', () {
      fuzz('wrong length rejects', (rng, _) {
        final int len = rng.nextInt(10);
        if (len == 2) return;
        final String input = randomDigits(rng, len);

        expect(validator.validate(input), isNotNull, reason: 'len=$len');
      });
    });

    test('formato com parênteses ou espaços nunca passa', () {
      fuzz('mask rejects', (rng, _) {
        final String ddd = DddValidator.ddds.elementAt(
          rng.nextInt(DddValidator.ddds.length),
        );
        final List<String> formats = [
          '($ddd)',
          ' $ddd ',
          '$ddd ',
          '0$ddd',
          '$ddd-',
        ];
        final String input = formats[rng.nextInt(formats.length)];

        expect(validator.validate(input), isNotNull, reason: input);
      });
    });

    test('todos os 67 DDDs da lista são aceitos', () {
      fuzz('every listed DDD accepted', (rng, _) {
        final String ddd = DddValidator.ddds.elementAt(
          rng.nextInt(DddValidator.ddds.length),
        );

        expect(validator.validate(ddd), isNull, reason: ddd);
      });
    });

    test('2 dígitos aleatórios — quem passa está na lista', () {
      // Espaço 100, ~67 válidos. Property: validar ⇔ contains.
      fuzz('membership matches list', (rng, _) {
        final String input = randomDigits(rng, 2);
        final bool ok = validator.validate(input) == null;

        expect(ok, DddValidator.ddds.contains(input), reason: input);
      });
    });
  });
}
