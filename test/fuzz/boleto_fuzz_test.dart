@Tags(['fuzz'])
library;

import 'dart:math';

import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import 'fuzz_helpers.dart';

// Conjunto de boletos sabidamente válidos (cross-checked com
// `mcrvaz/boleto-brasileiro-validator`). Usados como "seeds" para
// mutações no fuzz.
const _validBoletos = <String>[
  // bancário linha 47
  '23793381286000782713695000063305975520000370000',
  // bancário barcode 44
  '00193373700000001000500940144816060680935031',
  // arrecadação linha 48 mod-10
  '836200000005667800481000180975657313001589636081',
  // arrecadação linha 48 mod-11
  '848900000002404201622015806051904292586034111220',
  // arrecadação barcode 44 mod-10
  '83620000000667800481001809756573100158963608',
  // arrecadação barcode 44 mod-11
  '84890000000404201622018060519042958603411122',
];

void main() {
  group('BoletoValidator fuzz', () {
    final VString schema = V.string().boleto();
    const validator = BoletoValidator();

    test('nunca lança com input adversarial', () {
      fuzz('bool out on adversarial', (rng, _) {
        final String input = randomAdversarial(rng, rng.nextInt(60) + 1);

        expect(schema.validate(input), isA<bool>());
      });
    });

    test('dígitos puros com tamanho ∉ {44,47,48} nunca passam', () {
      fuzz('wrong length rejects', (rng, _) {
        final int len = rng.nextInt(60);
        if (len == 44 || len == 47 || len == 48) return;
        final String input = randomDigits(rng, len);

        expect(validator.validate(input), isNotNull, reason: 'len=$len');
      });
    });

    test('strings adversariais puras nunca passam', () {
      fuzz('pure adversarial rejects', (rng, _) {
        final int len = rng.nextInt(50) + 1;
        final StringBuffer buf = StringBuffer();

        for (int i = 0; i < len; i++) {
          buf.write(kAdversarialChars[rng.nextInt(kAdversarialChars.length)]);
        }
        expect(schema.validate(buf.toString()), isFalse);
      });
    });

    test('boletos válidos seguem válidos com máscara aleatória', () {
      // Inserir caracteres não-numéricos quaisquer não pode invalidar
      // — o validator faz strip antes da validação.
      fuzz('mask noise preserves validity', (rng, _) {
        final String boleto = _validBoletos[rng.nextInt(_validBoletos.length)];
        final String masked = _injectMask(rng, boleto);

        expect(validator.validate(masked), isNull, reason: masked);
      });
    });

    test('flip de DV em posição-chave invalida boleto bancário 47', () {
      // O DV geral está na posição 32 da linha digitável bancária.
      const valid = '23793381286000782713695000063305975520000370000';
      fuzz('flip general DV invalidates', (rng, _) {
        final int delta = 1 + rng.nextInt(9);
        final int original = int.parse(valid[32]);
        final String novo = ((original + delta) % 10).toString();
        final String tampered = valid.replaceRange(32, 33, novo);

        expect(validator.validate(tampered), isNotNull, reason: tampered);
      });
    });

    test('flip de qualquer DV de campo no bancário 47 invalida', () {
      const valid = '23793381286000782713695000063305975520000370000';
      fuzz('flip field DV invalidates', (rng, _) {
        // DVs de campo nas posições 9, 20, 31 da linha digitável.
        const dvPositions = [9, 20, 31];
        final int pos = dvPositions[rng.nextInt(dvPositions.length)];
        final int delta = 1 + rng.nextInt(9);
        final int original = int.parse(valid[pos]);
        final String novo = ((original + delta) % 10).toString();
        final String tampered = valid.replaceRange(pos, pos + 1, novo);

        expect(
          validator.validate(tampered),
          isNotNull,
          reason: 'pos=$pos: $tampered',
        );
      });
    });

    test('format=bancario rejeita arrecadação válida', () {
      const validator = BoletoValidator(format: FormatoBoleto.bancario);
      const arrecadacoes = [
        '836200000005667800481000180975657313001589636081',
        '848900000002404201622015806051904292586034111220',
        '83620000000667800481001809756573100158963608',
        '84890000000404201622018060519042958603411122',
      ];
      fuzz('bancario format rejects arrecadacao', (rng, _) {
        final String input = arrecadacoes[rng.nextInt(arrecadacoes.length)];
        expect(validator.validate(input), isNotNull);
      });
    });
  });
}

String _injectMask(Random rng, String digits) {
  const mask = ' .-/';
  final StringBuffer buf = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    buf.write(digits[i]);
    if (rng.nextInt(5) == 0) {
      buf.write(mask[rng.nextInt(mask.length)]);
    }
  }
  return buf.toString();
}
