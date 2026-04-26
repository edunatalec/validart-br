@Tags(['fuzz'])
library;

import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import 'fuzz_helpers.dart';

void main() {
  group('ChavePixValidator fuzz', () {
    final VString schemaDict = V.string().chavePix();
    final VString schemaAll = V.string().chavePix(tipos: TipoChavePix.values);

    test('nunca lança com input adversarial (default)', () {
      fuzz('bool out on adversarial', (rng, _) {
        final String input = randomAdversarial(rng, rng.nextInt(80) + 1);

        expect(schemaDict.validate(input), isA<bool>());
      });
    });

    test('nunca lança com input adversarial (all, incluindo brCode)', () {
      fuzz('bool out on adversarial (all)', (rng, _) {
        final String input = randomAdversarial(rng, rng.nextInt(300) + 1);

        expect(schemaAll.validate(input), isA<bool>());
      });
    });

    test('adversarial puro nunca é aceito como chave', () {
      fuzz('pure adversarial rejects', (rng, _) {
        final int len = rng.nextInt(30) + 1;
        final StringBuffer buf = StringBuffer();

        for (int i = 0; i < len; i++) {
          buf.write(kAdversarialChars[rng.nextInt(kAdversarialChars.length)]);
        }
        expect(schemaDict.validate(buf.toString()), isFalse);
      });
    });

    test('tipos vazio rejeita qualquer input', () {
      final VString schemaNone = V.string()
        ..add(const ChavePixValidator(allow: []));
      fuzz('empty tipos rejects all', (rng, _) {
        final int choice = rng.nextInt(5);
        final String input = switch (choice) {
          0 => '12345678909', // CPF válido
          1 => 'user@example.com', // email válido
          2 => '+5511987654321', // phone válido
          3 => '123e4567-e89b-12d3-a456-426614174000', // uuid
          _ => randomAdversarial(rng, 20),
        };
        expect(schemaNone.validate(input), isFalse);
      });
    });

    test('tipos: [email] nunca aceita CPF/CNPJ/UUID válidos', () {
      final VString emailOnly = V.string().chavePix(
        tipos: const [TipoChavePix.email],
      );
      const validos = [
        '12345678909', // CPF
        '12345678000195', // CNPJ
        '123e4567-e89b-12d3-a456-426614174000', // UUID
        '+5511987654321', // phone
      ];
      fuzz('email-only rejects non-email', (rng, _) {
        final String input = validos[rng.nextInt(validos.length)];
        expect(emailOnly.validate(input), isFalse);
      });
    });
  });
}
