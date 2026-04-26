@Tags(['fuzz'])
library;

import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import 'fuzz_helpers.dart';

void main() {
  group('BankCodeValidator fuzz', () {
    final schema = V.string().bankCode();
    const validator = BankCodeValidator();

    test('nunca lança com input adversarial', () {
      fuzz('bool out on adversarial', (rng, _) {
        final input = randomAdversarial(rng, rng.nextInt(20) + 1);

        expect(schema.validate(input), isA<bool>());
      });
    });

    test('strings com tamanho != 3 nunca passam', () {
      fuzz('wrong length rejects', (rng, _) {
        final len = rng.nextInt(15);
        if (len == 3) return;
        final input = randomDigits(rng, len);

        expect(validator.validate(input), isNotNull, reason: 'len=$len');
      });
    });

    test('formato com DV (4 dígitos com hífen) nunca passa', () {
      fuzz('with check digit format rejects', (rng, _) {
        final code = BankCodeValidator.codes.elementAt(
          rng.nextInt(BankCodeValidator.codes.length),
        );
        final dv = rng.nextInt(10);

        expect(validator.validate('$code-$dv'), isNotNull);
      });
    });

    test('todos os 497 códigos da lista são aceitos', () {
      fuzz('every listed code accepted', (rng, _) {
        final code = BankCodeValidator.codes.elementAt(
          rng.nextInt(BankCodeValidator.codes.length),
        );

        expect(validator.validate(code), isNull, reason: code);
      });
    });

    test('strings adversariais puras nunca passam', () {
      fuzz('pure adversarial rejects', (rng, _) {
        final len = rng.nextInt(10) + 1;
        final buf = StringBuffer();

        for (int i = 0; i < len; i++) {
          buf.write(kAdversarialChars[rng.nextInt(kAdversarialChars.length)]);
        }
        expect(schema.validate(buf.toString()), isFalse);
      });
    });

    test('3 dígitos aleatórios — quem passa está na lista oficial', () {
      // Espaço 1000, ~497 válidos (~50%). Property: validar input ⇔ contains.
      fuzz('membership matches list', (rng, _) {
        final input = randomDigits(rng, 3);
        final ok = validator.validate(input) == null;

        expect(ok, BankCodeValidator.codes.contains(input), reason: input);
      });
    });
  });
}
