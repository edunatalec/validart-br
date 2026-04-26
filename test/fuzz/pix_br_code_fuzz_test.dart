@Tags(['fuzz'])
library;

import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import 'fuzz_helpers.dart';

// BR Code estático válido (CRC16 conferido contra o vetor canônico
// "123456789" → 0x29B1). Base para flips.
const _brCodeValido =
    '00020126580014br.gov.bcb.pix0136123e4567-e89b-12d3-a456-42661417400052040000530398654041.005802BR5913Fulano de Tal6009Sao Paulo62070503***63046982';

void main() {
  group('PixBrCode fuzz', () {
    final schema = V.string().chavePix(allow: const [TipoChavePix.brCode]);

    test('nunca lança com input adversarial', () {
      fuzz('bool out on adversarial', (rng, _) {
        final len = rng.nextInt(300) + 1;
        final input = randomAdversarial(rng, len);

        expect(schema.validate(input), isA<bool>());
      });
    });

    test('input não começando com 000201 é sempre rejeitado', () {
      fuzz('bad header rejects', (rng, _) {
        final len = rng.nextInt(200) + 6;
        // Força header diferente.
        final header = randomDigits(rng, 6);
        if (header == '000201') return;
        final tail = randomAscii(rng, len - 6);

        expect(schema.validate('$header$tail'), isFalse);
      });
    });

    test('flip de 1 char na parte dinâmica quebra CRC', () {
      // Flipa qualquer char entre 6 e (fim - 8) — ou seja, fora do
      // header fixo "000201" e fora do "6304XXXX" final.
      const start = 6;
      const end = _brCodeValido.length - 8;
      fuzz('single-char flip invalidates CRC', (rng, _) {
        final idx = start + rng.nextInt(end - start);
        final original = _brCodeValido[idx];
        // Substitui por um char diferente do original.
        const pool = '0123456789abcdefghijklmnopqrstuvwxyz';
        String replacement;
        do {
          replacement = pool[rng.nextInt(pool.length)];
        } while (replacement == original);
        final tampered = _brCodeValido.replaceRange(idx, idx + 1, replacement);

        expect(
          schema.validate(tampered),
          isFalse,
          reason: 'idx=$idx replacement=$replacement',
        );
      });
    });

    test('CRC alterado (últimos 4 chars) sempre invalida', () {
      fuzz('bad crc rejects', (rng, _) {
        // Gera CRC aleatório diferente do correto (6982).
        const hex = '0123456789ABCDEF';
        String crc;
        do {
          final buf = StringBuffer();
          for (int i = 0; i < 4; i++) {
            buf.write(hex[rng.nextInt(hex.length)]);
          }
          crc = buf.toString();
        } while (crc == '6982');
        final tampered =
            _brCodeValido.substring(0, _brCodeValido.length - 4) + crc;

        expect(schema.validate(tampered), isFalse);
      });
    });

    test('strings curtas (< 24 chars) nunca passam', () {
      fuzz('too short rejects', (rng, _) {
        final len = rng.nextInt(23) + 1;
        final input = randomAscii(rng, len);

        expect(schema.validate(input), isFalse);
      });
    });

    test('TLV corrompido (length maior que resto) rejeita sem crashar', () {
      fuzz('malformed TLV', (rng, _) {
        // Monta: "0002" + "LL" com len absurdo + payload curto + CRC falso.
        final fakeLen = (90 + rng.nextInt(10)).toString().padLeft(2, '0');
        final input = '00$fakeLen${randomAscii(rng, 10)}6304ABCD';

        expect(schema.validate(input), isA<bool>());
        expect(schema.validate(input), isFalse);
      });
    });
  });
}
