@Tags(['fuzz'])
library;

import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import 'fuzz_helpers.dart';

void main() {
  group('TituloEleitorPattern fuzz', () {
    final schema = V.string().tituloEleitor();
    const pattern = TituloEleitorPattern();

    test('nunca lança com input adversarial', () {
      fuzz('bool out on adversarial', (rng, _) {
        final input = randomAdversarial(rng, rng.nextInt(60) + 1);

        expect(schema.validate(input), isA<bool>());
      });
    });

    test('tamanho != 12 nunca passa', () {
      fuzz('wrong length rejects', (rng, _) {
        final len = rng.nextInt(20);
        if (len == 12) return;
        final input = randomDigits(rng, len);

        expect(pattern.matches(input), isFalse);
      });
    });

    test('UF fora de 01..28 rejeita mesmo com DVs numéricos', () {
      fuzz('invalid UF rejects', (rng, _) {
        // 8 dígitos + UF fora de faixa + 2 dígitos aleatórios
        final uf = rng.nextBool()
            ? 0 // 00
            : 29 + rng.nextInt(71); // 29..99
        final sequencia = randomDigits(rng, 8);
        final dvs = randomDigits(rng, 2);
        final input = '$sequencia${uf.toString().padLeft(2, '0')}$dvs';

        expect(pattern.matches(input), isFalse, reason: 'UF=$uf: $input');
      });
    });

    test('flip do último DV num título válido quebra', () {
      const valid = '876543210329';
      fuzz('flip DV invalidates', (rng, _) {
        final delta = 1 + rng.nextInt(9);
        final bumped = ((int.parse(valid[11]) + delta) % 10).toString();
        final tampered = valid.replaceRange(11, 12, bumped);

        expect(pattern.matches(tampered), isFalse, reason: tampered);
      });
    });
  });
}
