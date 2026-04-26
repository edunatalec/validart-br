@Tags(['fuzz'])
library;

import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import 'fuzz_helpers.dart';

void main() {
  group('TelefonePattern fuzz', () {
    final VString schema = V.string().telefone();

    test('nunca lança com input adversarial', () {
      fuzz('bool out on adversarial', (rng, _) {
        final String input = randomAdversarial(rng, rng.nextInt(40) + 1);

        expect(schema.validate(input), isA<bool>());
      });
    });

    test('strings adversariais puras nunca passam', () {
      fuzz('pure adversarial rejects', (rng, _) {
        final int len = rng.nextInt(20) + 1;
        final StringBuffer buf = StringBuffer();

        for (int i = 0; i < len; i++) {
          buf.write(kAdversarialChars[rng.nextInt(kAdversarialChars.length)]);
        }
        expect(schema.validate(buf.toString()), isFalse);
      });
    });

    test('DDDs inexistentes (00, 10, 20, 23, etc.) são sempre rejeitados', () {
      final VString mobileSchema = V.string().telefone(
        ddd: FormatoDdd.required,
        apenasCelular: true,
      );
      const dddInvalidos = [0, 10, 20, 23, 25, 26, 29, 30, 36, 39, 40, 50, 52];
      fuzz('invalid ddd rejects', (rng, _) {
        final int ddd = dddInvalidos[rng.nextInt(dddInvalidos.length)];
        final String input = '${ddd.toString().padLeft(2, '0')}987654321';

        expect(mobileSchema.validate(input), isFalse, reason: input);
      });
    });

    test('celular sem dígito "9" inicial é rejeitado em mobileOnly', () {
      final VString mobileSchema = V.string().telefone(
        ddd: FormatoDdd.required,
        apenasCelular: true,
      );
      fuzz('no leading 9 rejects', (rng, _) {
        final int leading = rng.nextInt(9); // 0..8 (qualquer coisa != 9)
        final String digits = '11$leading${randomDigits(rng, 8)}';

        expect(mobileSchema.validate(digits), isFalse, reason: digits);
      });
    });
  });
}
