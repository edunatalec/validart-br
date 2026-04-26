@Tags(['fuzz'])
library;

import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import 'fuzz_helpers.dart';

void main() {
  group('PlacaPattern fuzz', () {
    final VString schema = V.string().placa();
    const pattern = PlacaPattern();

    test('nunca lança com input adversarial', () {
      fuzz('bool out on adversarial', (rng, _) {
        final String input = randomAdversarial(rng, rng.nextInt(20) + 1);

        expect(schema.validate(input), isA<bool>());
      });
    });

    test('lowercase nunca passa (letras devem ser uppercase)', () {
      fuzz('lowercase rejects', (rng, _) {
        const letters = 'abcdefghijklmnopqrstuvwxyz';
        // Monta formato antigo em lowercase.
        final StringBuffer buf = StringBuffer();

        for (int i = 0; i < 3; i++) {
          buf.write(letters[rng.nextInt(letters.length)]);
        }
        if (rng.nextBool()) buf.write('-');
        for (int i = 0; i < 4; i++) {
          buf.write(rng.nextInt(10));
        }
        expect(pattern.matches(buf.toString()), isFalse);
      });
    });

    test('7 dígitos puros nunca passam', () {
      fuzz('all digits rejects', (rng, _) {
        final String input = randomDigits(rng, 7);

        expect(pattern.matches(input), isFalse);
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
  });
}
