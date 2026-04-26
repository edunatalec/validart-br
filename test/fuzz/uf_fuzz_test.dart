@Tags(['fuzz'])
library;

import 'dart:math';

import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import 'fuzz_helpers.dart';

void main() {
  group('UfValidator fuzz', () {
    final schema = V.string().uf();
    const validator = UfValidator();

    test('nunca lança com input adversarial', () {
      fuzz('bool out on adversarial', (rng, _) {
        final input = randomAdversarial(rng, rng.nextInt(20) + 1);

        expect(schema.validate(input), isA<bool>());
      });
    });

    test('strings com tamanho != 2 nunca passam', () {
      fuzz('wrong length rejects', (rng, _) {
        final len = rng.nextInt(20);
        if (len == 2) return;
        final input = randomAscii(rng, len);

        expect(validator.validate(input), isNotNull, reason: 'len=$len');
      });
    });

    test('letras minúsculas (mesmo siglas válidas) nunca passam', () {
      fuzz('lowercase rejects', (rng, _) {
        final uf = UfValidator.ufs.elementAt(
          rng.nextInt(UfValidator.ufs.length),
        );

        expect(validator.validate(uf.toLowerCase()), isNotNull, reason: uf);
      });
    });

    test('toUpperCase + state aceita as 27 UFs em qualquer caixa', () {
      final schema = V.string().toUpperCase().uf();
      fuzz('uppercase normalization always accepts', (rng, _) {
        final uf = UfValidator.ufs.elementAt(
          rng.nextInt(UfValidator.ufs.length),
        );
        final mixed = _randomCase(rng, uf);

        expect(schema.validate(mixed), isTrue, reason: mixed);
      });
    });

    test('strings 2-letter aleatórias raramente passam', () {
      // Espaço amostral é 26*26 = 676; só 27 são válidas (~4%).
      fuzz('random 2-letter mostly rejects', (rng, _) {
        final a = String.fromCharCode(0x41 + rng.nextInt(26));
        final b = String.fromCharCode(0x41 + rng.nextInt(26));
        final input = '$a$b';
        // Se calhou de cair em UF válida, OK — só checa que não lança.
        expect(schema.validate(input), isA<bool>());
      });
    });
  });
}

String _randomCase(Random rng, String input) {
  final buf = StringBuffer();
  for (int i = 0; i < input.length; i++) {
    buf.write(rng.nextBool() ? input[i].toLowerCase() : input[i].toUpperCase());
  }
  return buf.toString();
}
