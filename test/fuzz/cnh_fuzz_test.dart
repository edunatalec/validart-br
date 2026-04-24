@Tags(['fuzz'])
library;

import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import 'fuzz_helpers.dart';

void main() {
  group('CnhPattern fuzz', () {
    final schema = V.string().cnh();
    const pattern = CnhPattern();

    test('nunca lança com input adversarial', () {
      fuzz('bool out on adversarial', (rng, _) {
        final input = randomAdversarial(rng, rng.nextInt(60) + 1);

        expect(schema.validate(input), isA<bool>());
      });
    });

    test('tamanho != 11 nunca passa', () {
      fuzz('wrong length rejects', (rng, _) {
        final len = rng.nextInt(20);
        if (len == 11) return;
        final input = randomDigits(rng, len);

        expect(pattern.matches(input), isFalse);
      });
    });

    test('dígitos repetidos não passam', () {
      fuzz('repeated rejects', (rng, _) {
        final d = rng.nextInt(10);
        final input = List.filled(11, d).join();

        expect(pattern.matches(input), isFalse);
      });
    });

    test('flip do último DV quebra checksum', () {
      const valid = '12345678900';
      fuzz('flip DV invalidates', (rng, _) {
        final delta = 1 + rng.nextInt(9);
        final bumped = ((int.parse(valid[10]) + delta) % 10).toString();
        final tampered = valid.replaceRange(10, 11, bumped);

        expect(pattern.matches(tampered), isFalse, reason: tampered);
      });
    });
  });
}
