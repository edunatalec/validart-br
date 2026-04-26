@Tags(['fuzz'])
library;

import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import 'fuzz_helpers.dart';

void main() {
  group('CnpjPattern fuzz', () {
    final VString schema = V.string().cnpj();
    const numericPattern = CnpjPattern(
      mode: ValidationMode.unformatted,
      alphanumeric: false,
    );

    test('nunca lança com input adversarial', () {
      fuzz('bool out on adversarial', (rng, _) {
        final String input = randomAdversarial(rng, rng.nextInt(60) + 1);

        expect(schema.validate(input), isA<bool>());
      });
    });

    test('dígitos repetidos (14) são sempre rejeitados', () {
      fuzz('repeated rejects', (rng, _) {
        final int d = rng.nextInt(10);
        final String input = List.filled(14, d).join();

        expect(numericPattern.matches(input), isFalse, reason: input);
      });
    });

    test('dígitos puros fora de 14 de tamanho nunca passam', () {
      fuzz('wrong length rejects', (rng, _) {
        final int len = rng.nextInt(20);
        if (len == 14) return;
        final String input = randomDigits(rng, len);

        expect(numericPattern.matches(input), isFalse);
      });
    });

    test('lowercase no formato alfanumérico é rejeitado', () {
      const pattern = CnpjPattern();
      fuzz('lowercase rejects', (rng, _) {
        final StringBuffer buf = StringBuffer();
        const letters = 'abcdefghijklmnopqrstuvwxyz';

        for (int i = 0; i < 12; i++) {
          buf.write(letters[rng.nextInt(letters.length)]);
        }
        buf.write(rng.nextInt(10));
        buf.write(rng.nextInt(10));
        expect(pattern.matches(buf.toString()), isFalse);
      });
    });

    test('flip do último DV num CNPJ válido quebra', () {
      // Flipar só o último DV sempre invalida (evita colisão mod-11 de
      // dígitos do meio).
      const valid = '12345678000195';
      fuzz('flip DV invalidates', (rng, _) {
        final int delta = 1 + rng.nextInt(9);
        final String bumped = ((int.parse(valid[13]) + delta) % 10).toString();
        final String tampered = valid.replaceRange(13, 14, bumped);

        expect(numericPattern.matches(tampered), isFalse, reason: tampered);
      });
    });
  });
}
