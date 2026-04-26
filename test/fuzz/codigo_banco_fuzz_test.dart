@Tags(['fuzz'])
library;

import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import 'fuzz_helpers.dart';

void main() {
  group('CodigoBancoValidator fuzz', () {
    final VString schema = V.string().codigoBanco();
    const validator = CodigoBancoValidator();

    test('nunca lança com input adversarial', () {
      fuzz('bool out on adversarial', (rng, _) {
        final String input = randomAdversarial(rng, rng.nextInt(20) + 1);

        expect(schema.validate(input), isA<bool>());
      });
    });

    test('strings com tamanho != 3 nunca passam', () {
      fuzz('wrong length rejects', (rng, _) {
        final int len = rng.nextInt(15);
        if (len == 3) return;
        final String input = randomDigits(rng, len);

        expect(validator.validate(input), isNotNull, reason: 'len=$len');
      });
    });

    test('formato com DV (4 dígitos com hífen) nunca passa', () {
      fuzz('with check digit format rejects', (rng, _) {
        final String code = CodigoBancoValidator.codigos.elementAt(
          rng.nextInt(CodigoBancoValidator.codigos.length),
        );
        final int dv = rng.nextInt(10);

        expect(validator.validate('$code-$dv'), isNotNull);
      });
    });

    test('todos os 497 códigos da lista são aceitos', () {
      fuzz('every listed code accepted', (rng, _) {
        final String code = CodigoBancoValidator.codigos.elementAt(
          rng.nextInt(CodigoBancoValidator.codigos.length),
        );

        expect(validator.validate(code), isNull, reason: code);
      });
    });

    test('strings adversariais puras nunca passam', () {
      fuzz('pure adversarial rejects', (rng, _) {
        final int len = rng.nextInt(10) + 1;
        final StringBuffer buf = StringBuffer();

        for (int i = 0; i < len; i++) {
          buf.write(kAdversarialChars[rng.nextInt(kAdversarialChars.length)]);
        }
        expect(schema.validate(buf.toString()), isFalse);
      });
    });

    test('3 dígitos aleatórios — quem passa está na lista oficial', () {
      // Espaço 1000, ~497 válidos (~50%). Property: validar input ⇔ contains.
      fuzz('membership matches list', (rng, _) {
        final String input = randomDigits(rng, 3);
        final bool ok = validator.validate(input) == null;

        expect(ok, CodigoBancoValidator.codigos.contains(input), reason: input);
      });
    });
  });
}
