@Tags(['fuzz'])
library;

import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import 'fuzz_helpers.dart';

void main() {
  group('BrPhonePattern fuzz', () {
    final schema = V.string().phoneBr();

    test('nunca lança com input adversarial', () {
      fuzz('bool out on adversarial', (rng, _) {
        final input = randomAdversarial(rng, rng.nextInt(40) + 1);

        expect(schema.validate(input), isA<bool>());
      });
    });

    test('strings adversariais puras nunca passam', () {
      fuzz('pure adversarial rejects', (rng, _) {
        final len = rng.nextInt(20) + 1;
        final buf = StringBuffer();

        for (int i = 0; i < len; i++) {
          buf.write(kAdversarialChars[rng.nextInt(kAdversarialChars.length)]);
        }
        expect(schema.validate(buf.toString()), isFalse);
      });
    });

    test('DDDs inexistentes (00, 10, 20, 23, etc.) são sempre rejeitados', () {
      final mobileSchema = V.string().phoneBr(
        areaCode: AreaCodeFormat.required,
        mobileOnly: true,
      );
      const invalidDdds = [0, 10, 20, 23, 25, 26, 29, 30, 36, 39, 40, 50, 52];
      fuzz('invalid ddd rejects', (rng, _) {
        final ddd = invalidDdds[rng.nextInt(invalidDdds.length)];
        final input = '${ddd.toString().padLeft(2, '0')}987654321';

        expect(mobileSchema.validate(input), isFalse, reason: input);
      });
    });

    test('celular sem dígito "9" inicial é rejeitado em mobileOnly', () {
      final mobileSchema = V.string().phoneBr(
        areaCode: AreaCodeFormat.required,
        mobileOnly: true,
      );
      fuzz('no leading 9 rejects', (rng, _) {
        final leading = rng.nextInt(9); // 0..8 (qualquer coisa != 9)
        final digits = '11$leading${randomDigits(rng, 8)}';

        expect(mobileSchema.validate(digits), isFalse, reason: digits);
      });
    });
  });
}
