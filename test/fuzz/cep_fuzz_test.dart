@Tags(['fuzz'])
library;

import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import 'fuzz_helpers.dart';

void main() {
  group('CepPattern fuzz', () {
    final schema = V.string().cep();
    const pattern = CepPattern();

    test('nunca lança com input adversarial', () {
      fuzz('bool out on adversarial', (rng, _) {
        final input = randomAdversarial(rng, rng.nextInt(40) + 1);

        expect(schema.validate(input), isA<bool>());
      });
    });

    test('tamanhos (dígitos) fora de 8/9 nunca passam', () {
      fuzz('wrong length rejects', (rng, _) {
        final len = rng.nextInt(20);
        if (len == 8 || len == 9) return;
        final input = randomDigits(rng, len);

        expect(pattern.matches(input), isFalse, reason: input);
      });
    });

    test('dígitos repetidos nunca passam', () {
      fuzz('repeated rejects', (rng, _) {
        final d = rng.nextInt(10);
        final input = List.filled(8, d).join();

        expect(pattern.matches(input), isFalse);
      });
    });

    test('strings adversariais puras nunca passam', () {
      fuzz('pure adversarial rejects', (rng, _) {
        final len = rng.nextInt(15) + 1;
        final buf = StringBuffer();

        for (int i = 0; i < len; i++) {
          buf.write(kAdversarialChars[rng.nextInt(kAdversarialChars.length)]);
        }
        expect(schema.validate(buf.toString()), isFalse);
      });
    });
  });
}
