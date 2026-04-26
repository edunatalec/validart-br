import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('VStringBr — fluent API', () {
    test('cpf encadeia com trim', () {
      final VString schema = V.string().trim().cpf();
      expect(schema.validate('  123.456.789-09  '), isTrue);
      expect(schema.validate('000.000.000-00'), isFalse);
    });

    test('cnpj respeita mode', () {
      final VString schema = V.string().cnpj(mode: ValidationMode.unformatted);
      expect(schema.validate('12345678000195'), isTrue);
      expect(schema.validate('12.345.678/0001-95'), isFalse);
    });

    test('cep aceita ambos por default', () {
      final VString schema = V.string().cep();
      expect(schema.validate('01001-000'), isTrue);
      expect(schema.validate('01001000'), isTrue);
    });

    test('phoneBr com flags combinadas', () {
      final VString schema = V.string().telefone(
        ddd: FormatoDdd.required,
        pais: CountryCodeFormat.required,
        apenasCelular: true,
      );
      expect(schema.validate('+55 (11) 98765-4321'), isTrue);
      expect(schema.validate('11987654321'), isFalse);
    });

    test('pis / tituloEleitor / cnh / renavam', () {
      expect(V.string().pis().validate('12054789013'), isTrue);
      expect(V.string().tituloEleitor().validate('876543210329'), isTrue);
      expect(V.string().cnh().validate('12345678900'), isTrue);
      expect(V.string().renavam().validate('12345678900'), isTrue);
    });

    test('pixKey aceita CPF, e-mail, telefone ou UUID', () {
      final VString schema = V.string().chavePix();
      expect(schema.validate('12345678909'), isTrue);
      expect(schema.validate('user@example.com'), isTrue);
      expect(schema.validate('+5511987654321'), isTrue);
      expect(schema.validate('123e4567-e89b-12d3-a456-426614174000'), isTrue);
    });

    test('plate encadeia com toUpperCase', () {
      final VString schema = V.string().toUpperCase().placa();
      expect(schema.validate('abc-1234'), isTrue);
      expect(schema.validate('abc1d23'), isTrue);
    });

    test('state / bankCode / ddd', () {
      expect(V.string().uf().validate('SP'), isTrue);
      expect(V.string().uf().validate('XY'), isFalse);
      expect(V.string().codigoBanco().validate('001'), isTrue);
      expect(V.string().codigoBanco().validate('999'), isFalse);
      expect(V.string().ddd().validate('11'), isTrue);
      expect(V.string().ddd().validate('20'), isFalse);
    });

    test('boleto bancário e arrecadação', () {
      final VString schema = V.string().boleto();
      expect(
        schema.validate('23793381286000782713695000063305975520000370000'),
        isTrue,
      );
      expect(
        schema.validate('836200000005667800481000180975657313001589636081'),
        isTrue,
      );
      expect(schema.validate('xxxx'), isFalse);
    });

    test('boleto restringido por format', () {
      final VString schema = V.string().boleto(formato: FormatoBoleto.bancario);
      expect(
        schema.validate('23793381286000782713695000063305975520000370000'),
        isTrue,
      );
      expect(
        schema.validate('836200000005667800481000180975657313001589636081'),
        isFalse,
      );
    });
  });

  group('VStringBr — mensagem customizada', () {
    test('cpf', () {
      final VString schema = V.string().cpf(message: 'CPF obrigatório!');
      expect(schema.errors('xxxx')!.first.message, 'CPF obrigatório!');
    });

    test('cnpj', () {
      final VString schema = V.string().cnpj(message: 'CNPJ incorreto');
      expect(schema.errors('xx')!.first.message, 'CNPJ incorreto');
    });

    test('cnh usa feminino explícito', () {
      final VString schema = V.string().cnh(message: 'CNH inválida');
      expect(schema.errors('00000000000')!.first.message, 'CNH inválida');
    });

    test('plate', () {
      final VString schema = V.string().placa(message: 'Placa fora do padrão');
      expect(schema.errors('xyz')!.first.message, 'Placa fora do padrão');
    });

    test('phoneBr', () {
      final VString schema = V.string().telefone(
        message: 'Telefone BR inválido',
      );
      expect(schema.errors('abc')!.first.message, 'Telefone BR inválido');
    });

    test('pixKey', () {
      final VString schema = V.string().chavePix(message: 'Chave PIX ruim');
      expect(schema.errors('nope')!.first.message, 'Chave PIX ruim');
    });

    test('state', () {
      final VString schema = V.string().uf(message: 'UF não reconhecida');
      expect(schema.errors('XY')!.first.message, 'UF não reconhecida');
    });

    test('bankCode', () {
      final VString schema = V.string().codigoBanco(
        message: 'Banco não autorizado',
      );
      expect(schema.errors('999')!.first.message, 'Banco não autorizado');
    });

    test('ddd', () {
      final VString schema = V.string().ddd(message: 'DDD fora da Anatel');
      expect(schema.errors('00')!.first.message, 'DDD fora da Anatel');
    });

    test('boleto', () {
      final VString schema = V.string().boleto(
        message: 'Boleto fora do padrão',
      );
      expect(schema.errors('xxx')!.first.message, 'Boleto fora do padrão');
    });
  });

  group('VStringBr — integração com o core', () {
    test('nullable aceita null e valida quando tem valor', () {
      final List<VString> schemas = <VString>[
        V.string().cpf().nullable(),
        V.string().cnpj().nullable(),
        V.string().cep().nullable(),
        V.string().placa().nullable(),
        V.string().telefone().nullable(),
        V.string().chavePix().nullable(),
        V.string().uf().nullable(),
        V.string().codigoBanco().nullable(),
        V.string().ddd().nullable(),
        V.string().boleto().nullable(),
      ];
      for (final schema in schemas) {
        expect(schema.validate(null), isTrue);
      }
      expect(V.string().cpf().nullable().validate('123.456.789-09'), isTrue);
      expect(V.string().cpf().nullable().validate('xxxx'), isFalse);
    });

    test('defaultValue passa pela validação do core', () {
      final VString schema = V.string().defaultValue('123.456.789-09').cpf();
      expect(schema.parse(null), '123.456.789-09');

      // Default inválido é rejeitado (comportamento do core 1.1.0)
      final VString bad = V.string().defaultValue('xxxx').cpf();
      expect(bad.validate(null), isFalse);
    });

    test('schema composto retorna erros por campo', () {
      V.setLocale(VLocaleBr.ptBr);
      final VMap schema = V.map({
        'cpf': V.string().cpf(),
        'cnpj': V.string().cnpj(),
        'cep': V.string().cep(),
        'placa': V.string().placa(),
        'uf': V.string().uf(),
        'banco': V.string().codigoBanco(),
        'ddd': V.string().ddd(),
        'boleto': V.string().boleto(),
      });

      final VResult<Map<String, dynamic>?> result = schema.safeParse({
        'cpf': '000.000.000-00',
        'cnpj': '00.000.000/0000-00',
        'cep': '00000-000',
        'placa': 'invalid',
        'uf': 'XY',
        'banco': '999',
        'ddd': '00',
        'boleto': 'xxx',
      });

      expect(result, isA<VFailure>());
      final Map<String, String> map = (result as VFailure).toMap();
      expect(map['cpf'], 'CPF inválido');
      expect(map['cnpj'], 'CNPJ inválido');
      expect(map['cep'], 'CEP inválido');
      expect(map['placa'], 'Placa inválida');
      expect(map['uf'], 'UF inválida');
      expect(map['banco'], 'Código de banco inválido');
      expect(map['ddd'], 'DDD inválido');
      expect(map['boleto'], 'Boleto inválido');
    });

    test('locale pt-BR interpola {name} dos patterns do core', () {
      V.setLocale(VLocaleBr.ptBr);
      expect(V.string().cpf().errors('xx')!.first.message, 'CPF inválido');
      expect(V.string().cnh().errors('0')!.first.message, 'CNH inválido');
    });
  });
}
