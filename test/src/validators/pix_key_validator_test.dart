import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

// BR Codes válidos gerados pela implementação de referência (CRC16-CCITT-FALSE
// validada contra o vetor canônico "123456789" → 0x29B1). Payloads montados
// conforme EMVCo/Bacen com GUID `br.gov.bcb.pix` no campo 26, moeda 986 e país
// BR.
const _brCodeUuidComValor =
    '00020126580014br.gov.bcb.pix0136123e4567-e89b-12d3-a456-42661417400052040000530398654041.005802BR5913Fulano de Tal6009Sao Paulo62070503***63046982';
const _brCodeUuidSemValor =
    '00020126580014br.gov.bcb.pix0136123e4567-e89b-12d3-a456-4266141740005204000053039865802BR5913Fulano de Tal6009Sao Paulo62070503***6304774A';
const _brCodeEmail =
    '00020126430014br.gov.bcb.pix0121fulano@example.com.br5204000053039865802BR5913Fulano de Tal6009Sao Paulo62070503***63048EB4';
const _brCodePhone =
    '00020126360014BR.GOV.BCB.PIX0114+5561999999999520400005303986540510.005802BR5919BARBEARIA DO FULANO6009SAO PAULO62070503***6304E6B2';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('PixKeyValidator — defaults (5 chaves DICT, sem BR Code)', () {
    test('aceita CPF válido sem máscara', () {
      final schema = V.string()..add(const PixKeyValidator());
      expect(schema.validate('12345678909'), isTrue);
      expect(schema.validate('11144477735'), isTrue);
    });

    test('rejeita CPF formatado (PIX exige só dígitos)', () {
      final schema = V.string()..add(const PixKeyValidator());
      expect(schema.validate('123.456.789-09'), isFalse);
    });

    test('aceita CNPJ válido sem máscara', () {
      final schema = V.string()..add(const PixKeyValidator());
      expect(schema.validate('12345678000195'), isTrue);
    });

    test('rejeita CNPJ formatado', () {
      final schema = V.string()..add(const PixKeyValidator());
      expect(schema.validate('12.345.678/0001-95'), isFalse);
    });

    test('rejeita CNPJ alfanumérico (PIX aceita só dígitos)', () {
      final schema = V.string()..add(const PixKeyValidator());
      expect(schema.validate('12ABC34501DE35'), isFalse);
    });

    test('aceita e-mail válido', () {
      final schema = V.string()..add(const PixKeyValidator());
      expect(schema.validate('user@example.com'), isTrue);
      expect(schema.validate('fulano.da.silva@empresa.com.br'), isTrue);
    });

    test('rejeita e-mail inválido', () {
      final schema = V.string()..add(const PixKeyValidator());
      expect(schema.validate('invalid'), isFalse);
      expect(schema.validate('@example.com'), isFalse);
    });

    test('aceita telefone +55 com celular', () {
      final schema = V.string()..add(const PixKeyValidator());
      expect(schema.validate('+5511987654321'), isTrue);
    });

    test('rejeita telefone sem DDI +55', () {
      final schema = V.string()..add(const PixKeyValidator());
      expect(schema.validate('11987654321'), isFalse);
    });

    test('rejeita telefone fixo como chave PIX', () {
      final schema = V.string()..add(const PixKeyValidator());
      expect(schema.validate('+551133334444'), isFalse);
    });

    test('aceita UUID v4', () {
      final schema = V.string()..add(const PixKeyValidator());
      expect(schema.validate('123e4567-e89b-12d3-a456-426614174000'), isTrue);
      expect(schema.validate('f47ac10b-58cc-4372-a567-0e02b2c3d479'), isTrue);
    });

    test('rejeita UUID em formato errado', () {
      final schema = V.string()..add(const PixKeyValidator());
      expect(schema.validate('123e4567e89b12d3a456426614174000'), isFalse);
      expect(schema.validate('not-a-uuid'), isFalse);
    });

    test('rejeita BR Code (brCode não está no default)', () {
      final schema = V.string()..add(const PixKeyValidator());
      expect(schema.validate(_brCodeUuidComValor), isFalse);
    });

    test('rejeita string vazia', () {
      final schema = V.string()..add(const PixKeyValidator());
      expect(schema.validate(''), isFalse);
    });

    test('retorna código de erro invalid_pix_key', () {
      final schema = V.string()..add(const PixKeyValidator());
      final errors = schema.errors('not a key');
      expect(errors!.first.code, VStringCodeBr.invalidPixKey);
    });

    test('mensagem em pt-BR é "Chave PIX inválida"', () {
      V.setLocale(VLocaleBr.ptBr);
      final schema = V.string().pixKey();
      final errors = schema.errors('not a key');
      expect(errors!.first.message, 'Chave PIX inválida');
    });
  });

  group('PixKeyValidator — allow restrito', () {
    test('allow: [email] aceita só e-mail', () {
      final schema = V.string()
        ..add(const PixKeyValidator(allow: [PixKeyType.email]));
      expect(schema.validate('user@example.com'), isTrue);
      expect(schema.validate('12345678909'), isFalse); // CPF rejeitado
      expect(schema.validate('+5511987654321'), isFalse); // phone rejeitado
    });

    test('allow: [cpf, cnpj] aceita só documentos', () {
      final schema = V.string()
        ..add(const PixKeyValidator(allow: [PixKeyType.cpf, PixKeyType.cnpj]));
      expect(schema.validate('12345678909'), isTrue);
      expect(schema.validate('12345678000195'), isTrue);
      expect(schema.validate('user@example.com'), isFalse);
    });

    test('allow: [random] aceita só UUID', () {
      final schema = V.string()
        ..add(const PixKeyValidator(allow: [PixKeyType.random]));
      expect(schema.validate('123e4567-e89b-12d3-a456-426614174000'), isTrue);
      expect(schema.validate('12345678909'), isFalse);
    });

    test('allow vazia rejeita tudo', () {
      final schema = V.string()..add(const PixKeyValidator(allow: []));
      expect(schema.validate('user@example.com'), isFalse);
      expect(schema.validate('12345678909'), isFalse);
    });

    test('atalho V.string().pixKey(allow: …) propaga o filtro', () {
      final schema = V.string().pixKey(
        allow: const [PixKeyType.email, PixKeyType.phone],
      );
      expect(schema.validate('user@example.com'), isTrue);
      expect(schema.validate('+5511987654321'), isTrue);
      expect(schema.validate('12345678909'), isFalse);
    });
  });

  group('PixKeyValidator — BR Code (allow inclui brCode)', () {
    const validator = PixKeyValidator(allow: [PixKeyType.brCode]);

    test('aceita BR Code estático com UUID e valor', () {
      final schema = V.string()..add(validator);
      expect(schema.validate(_brCodeUuidComValor), isTrue);
    });

    test('aceita BR Code estático sem valor (dinâmico equivalente)', () {
      final schema = V.string()..add(validator);
      expect(schema.validate(_brCodeUuidSemValor), isTrue);
    });

    test('aceita BR Code com chave de e-mail', () {
      final schema = V.string()..add(validator);
      expect(schema.validate(_brCodeEmail), isTrue);
    });

    test('aceita BR Code com chave de telefone (GUID em CAIXA ALTA)', () {
      final schema = V.string()..add(validator);
      expect(schema.validate(_brCodePhone), isTrue);
    });

    test('rejeita BR Code com CRC alterado (1 char)', () {
      final schema = V.string()..add(validator);
      // Troca último hex do CRC.
      final quebrado = _brCodeUuidComValor.replaceRange(
        _brCodeUuidComValor.length - 1,
        _brCodeUuidComValor.length,
        '0',
      );
      expect(schema.validate(quebrado), isFalse);
    });

    test('rejeita BR Code truncado (CRC some)', () {
      final schema = V.string()..add(validator);
      final truncado = _brCodeUuidComValor.substring(
        0,
        _brCodeUuidComValor.length - 4,
      );
      expect(schema.validate(truncado), isFalse);
    });

    test('rejeita BR Code sem campo "6304" antes do CRC', () {
      final schema = V.string()..add(validator);
      // Substitui a tag "6304" pelos próprios 4 chars (ainda que parça
      // válido de tamanho, a tag ID quebra).
      final corrompido = _brCodeUuidComValor.replaceRange(
        _brCodeUuidComValor.length - 8,
        _brCodeUuidComValor.length - 4,
        '6204',
      );
      expect(schema.validate(corrompido), isFalse);
    });

    test('rejeita string curta (não chega no tamanho mínimo do header)', () {
      final schema = V.string()..add(validator);
      expect(schema.validate('000201'), isFalse);
      expect(schema.validate(''), isFalse);
    });

    test('rejeita string sem o Payload Format Indicator "000201"', () {
      final schema = V.string()..add(validator);
      expect(
        schema.validate(
          '99020126430014br.gov.bcb.pix0121fulano@example.com.br5204000053039865802BR5913Fulano de Tal6009Sao Paulo62070503***63048EB4',
        ),
        isFalse,
      );
    });

    test('mensagem em pt-BR para BR Code inválido é "Chave PIX inválida"', () {
      V.setLocale(VLocaleBr.ptBr);
      final schema = V.string().pixKey(allow: const [PixKeyType.brCode]);
      final errors = schema.errors('not a br code');
      expect(errors!.first.message, 'Chave PIX inválida');
    });
  });

  group('PixKeyValidator — união de chaves DICT + BR Code', () {
    test('allow: PixKeyType.values aceita chave e BR Code', () {
      final schema = V.string().pixKey(allow: PixKeyType.values);
      expect(schema.validate('user@example.com'), isTrue); // chave
      expect(schema.validate(_brCodeUuidComValor), isTrue); // BR Code
      expect(schema.validate('not-a-key'), isFalse);
    });
  });
}
