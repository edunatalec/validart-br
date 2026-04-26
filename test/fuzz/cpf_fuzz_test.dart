@Tags(['fuzz'])
library;

import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import 'fuzz_helpers.dart';

void main() {
  group('CpfPattern fuzz', () {
    final VString schema = V.string().cpf();
    const pattern = CpfPattern(mode: ValidationMode.unformatted);

    test('nunca lança com input adversarial', () {
      fuzz('bool out on adversarial', (rng, _) {
        final String input = randomAdversarial(rng, rng.nextInt(60) + 1);

        expect(schema.validate(input), isA<bool>());
      });
    });

    test('dígitos repetidos (11 chars) são sempre rejeitados', () {
      fuzz('repeated rejects', (rng, _) {
        final int d = rng.nextInt(10);
        final String input = List.filled(11, d).join();

        expect(pattern.matches(input), isFalse, reason: input);
      });
    });

    test('dígitos puros com tamanho != 11 nunca passam', () {
      fuzz('wrong length rejects', (rng, _) {
        final int len = rng.nextInt(20);
        if (len == 11) return;
        final String input = randomDigits(rng, len);

        expect(pattern.matches(input), isFalse, reason: 'len=$len: $input');
      });
    });

    test('strings puramente adversariais (sem dígitos) não passam', () {
      fuzz('pure adversarial rejects', (rng, _) {
        final int len = rng.nextInt(15) + 1;
        final StringBuffer buf = StringBuffer();

        for (int i = 0; i < len; i++) {
          buf.write(kAdversarialChars[rng.nextInt(kAdversarialChars.length)]);
        }
        expect(schema.validate(buf.toString()), isFalse);
      });
    });

    test('flip do último DV num CPF válido quebra o checksum', () {
      // Flipar dígitos da parte sequencial pode coincidir com outro CPF
      // válido (colisão mod-11). Flipar o último DV sempre invalida,
      // porque o afirmado muda e o esperado (função dos 10 anteriores)
      // não.
      const valid = '12345678909';
      fuzz('flip DV invalidates', (rng, _) {
        final int delta = 1 + rng.nextInt(9); // 1..9 — sempre diferente
        final String bumped = ((int.parse(valid[10]) + delta) % 10).toString();
        final String tampered = valid.replaceRange(10, 11, bumped);

        expect(pattern.matches(tampered), isFalse, reason: tampered);
      });
    });
  });
}
