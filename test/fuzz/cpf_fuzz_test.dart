@Tags(['fuzz'])
library;

import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import 'fuzz_helpers.dart';

void main() {
  group('CpfPattern fuzz', () {
    final schema = V.string().cpf();
    const pattern = CpfPattern(mode: ValidationMode.unformatted);

    test('nunca lança com input adversarial', () {
      fuzz('bool out on adversarial', (rng, _) {
        final input = randomAdversarial(rng, rng.nextInt(60) + 1);

        expect(schema.validate(input), isA<bool>());
      });
    });

    test('dígitos repetidos (11 chars) são sempre rejeitados', () {
      fuzz('repeated rejects', (rng, _) {
        final d = rng.nextInt(10);
        final input = List.filled(11, d).join();

        expect(pattern.matches(input), isFalse, reason: input);
      });
    });

    test('dígitos puros com tamanho != 11 nunca passam', () {
      fuzz('wrong length rejects', (rng, _) {
        final len = rng.nextInt(20);
        if (len == 11) return;
        final input = randomDigits(rng, len);

        expect(pattern.matches(input), isFalse, reason: 'len=$len: $input');
      });
    });

    test('strings puramente adversariais (sem dígitos) não passam', () {
      fuzz('pure adversarial rejects', (rng, _) {
        final len = rng.nextInt(15) + 1;
        final buf = StringBuffer();

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
        final delta = 1 + rng.nextInt(9); // 1..9 — sempre diferente
        final bumped = ((int.parse(valid[10]) + delta) % 10).toString();
        final tampered = valid.replaceRange(10, 11, bumped);

        expect(pattern.matches(tampered), isFalse, reason: tampered);
      });
    });
  });
}
