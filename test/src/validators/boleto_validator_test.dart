import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

// Fixtures reais — boletos com checksum batendo conferidos contra a
// suite do `mcrvaz/boleto-brasileiro-validator` (Node.js, 200+ stars).
// Não confiar em geradores online: estes foram cruzados com a
// implementação independente de geração no script de validação que
// vive fora do repo.
const _bancarioLinhaSemMascara =
    '23793381286000782713695000063305975520000370000';
const _bancarioLinhaComMascara =
    '23793.38128 60007.827136 95000.063305 9 75520000370000';
const _bancarioBarras = '00193373700000001000500940144816060680935031';

const _arrecadacaoLinhaMod10 =
    '836200000005667800481000180975657313001589636081';
const _arrecadacaoLinhaMod11 =
    '848900000002404201622015806051904292586034111220';
const _arrecadacaoBarrasMod10 = '83620000000667800481001809756573100158963608';
const _arrecadacaoBarrasMod11 = '84890000000404201622018060519042958603411122';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('BoletoValidator — boleto bancário', () {
    test('aceita linha digitável (47 dígitos) válida sem máscara', () {
      const validator = BoletoValidator();
      expect(validator.validate(_bancarioLinhaSemMascara), isNull);
    });

    test('aceita linha digitável com máscara (espaços e pontos)', () {
      const validator = BoletoValidator();
      expect(validator.validate(_bancarioLinhaComMascara), isNull);
    });

    test('aceita código de barras (44 dígitos) válido', () {
      const validator = BoletoValidator();
      expect(validator.validate(_bancarioBarras), isNull);
    });

    test('rejeita linha digitável com DV geral trocado', () {
      const validator = BoletoValidator();
      // mesma linha, com o `9` na posição 33 (DV geral) trocado por `4`.
      expect(
        validator.validate('23793381286000782713695000063305475520000370000'),
        isNotNull,
      );
    });

    test('rejeita linha digitável com tamanho errado', () {
      const validator = BoletoValidator();
      expect(
        validator.validate('2379338128600078271369500006975520000370000'), // 43
        isNotNull,
      );
    });

    test('rejeita código de barras com 43 dígitos', () {
      const validator = BoletoValidator();
      expect(
        validator.validate('0019337370000000100050094014481606068093503'),
        isNotNull,
      );
    });

    test('rejeita string vazia ou só máscara', () {
      const validator = BoletoValidator();
      expect(validator.validate(''), isNotNull);
      expect(validator.validate('. - '), isNotNull);
    });
  });

  group('BoletoValidator — boleto de arrecadação', () {
    test('aceita linha digitável (48) mod-10 válida', () {
      const validator = BoletoValidator();
      expect(validator.validate(_arrecadacaoLinhaMod10), isNull);
    });

    test('aceita linha digitável (48) mod-11 válida', () {
      const validator = BoletoValidator();
      expect(validator.validate(_arrecadacaoLinhaMod11), isNull);
    });

    test('aceita código de barras (44) mod-10 válido', () {
      const validator = BoletoValidator();
      expect(validator.validate(_arrecadacaoBarrasMod10), isNull);
    });

    test('aceita código de barras (44) mod-11 válido', () {
      const validator = BoletoValidator();
      expect(validator.validate(_arrecadacaoBarrasMod11), isNull);
    });

    test('rejeita linha de arrecadação com bloco corrompido', () {
      const validator = BoletoValidator();
      // mesmo de cima, mas com um dígito alterado no segundo bloco.
      expect(
        validator.validate('836200000005667800481800180975657313001589636081'),
        isNotNull,
      );
    });

    test('aceita máscara em arrecadação mod-11', () {
      const validator = BoletoValidator();
      // Mesmo conteúdo de _arrecadacaoLinhaMod11, apenas com hífens
      // separando os 4 blocos de 11+DV.
      expect(
        validator.validate(
          '84890000000-2 40420162201-5 80605190429-2 58603411122-0',
        ),
        isNull,
      );
    });
  });

  group('BoletoValidator — restrição via [format]', () {
    test('format: bancario rejeita arrecadação', () {
      const validator = BoletoValidator(format: FormatoBoleto.bancario);
      expect(validator.validate(_bancarioLinhaSemMascara), isNull);
      expect(validator.validate(_arrecadacaoLinhaMod10), isNotNull);
      expect(validator.validate(_arrecadacaoBarrasMod11), isNotNull);
    });

    test('format: arrecadacao rejeita bancário', () {
      const validator = BoletoValidator(format: FormatoBoleto.arrecadacao);
      expect(validator.validate(_arrecadacaoLinhaMod10), isNull);
      expect(validator.validate(_bancarioLinhaSemMascara), isNotNull);
      expect(validator.validate(_bancarioBarras), isNotNull);
    });
  });

  group('BoletoValidator — integração via V.string().boleto()', () {
    test('aceita qualquer formato sem restrição', () {
      final VString schema = V.string().boleto();
      expect(schema.validate(_bancarioLinhaSemMascara), isTrue);
      expect(schema.validate(_bancarioLinhaComMascara), isTrue);
      expect(schema.validate(_bancarioBarras), isTrue);
      expect(schema.validate(_arrecadacaoLinhaMod10), isTrue);
      expect(schema.validate(_arrecadacaoLinhaMod11), isTrue);
      expect(schema.validate(_arrecadacaoBarrasMod10), isTrue);
      expect(schema.validate(_arrecadacaoBarrasMod11), isTrue);
    });

    test('respeita format', () {
      final VString schema = V.string().boleto(formato: FormatoBoleto.bancario);
      expect(schema.validate(_bancarioLinhaSemMascara), isTrue);
      expect(schema.validate(_arrecadacaoLinhaMod10), isFalse);
    });

    test('código de erro é invalid_boleto', () {
      final VString schema = V.string().boleto();
      final List<VError>? errors = schema.errors('00000');
      expect(errors!.first.code, VStringCodeBr.boletoInvalido);
    });

    test('respeita message customizada', () {
      final VString schema = V.string().boleto(
        mensagem: 'Boleto fora do padrão',
      );
      expect(schema.errors('xxx')!.first.message, 'Boleto fora do padrão');
    });
  });

  group('BoletoValidator — locale pt-BR', () {
    setUp(() => V.setLocale(VLocaleBr.ptBr));
    tearDown(() => V.setLocale(const VLocale()));

    test('mensagem em pt-BR é "Boleto inválido"', () {
      final VString schema = V.string().boleto();
      final List<VError>? errors = schema.errors('xxx');
      expect(errors!.first.message, 'Boleto inválido');
    });
  });
}
