import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('VStringBr — fluent API', () {
    test('cpf encadeia com trim', () {
      final schema = V.string().trim().cpf();
      expect(schema.validate('  123.456.789-09  '), isTrue);
      expect(schema.validate('000.000.000-00'), isFalse);
    });

    test('cnpj respeita mode', () {
      final schema = V.string().cnpj(mode: ValidationMode.unformatted);
      expect(schema.validate('12345678000195'), isTrue);
      expect(schema.validate('12.345.678/0001-95'), isFalse);
    });

    test('cep aceita ambos por default', () {
      final schema = V.string().cep();
      expect(schema.validate('01001-000'), isTrue);
      expect(schema.validate('01001000'), isTrue);
    });

    test('phoneBr com flags combinadas', () {
      final schema = V.string().phoneBr(
        areaCode: AreaCodeFormat.required,
        countryCode: CountryCodeFormat.required,
        mobileOnly: true,
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
      final schema = V.string().pixKey();
      expect(schema.validate('12345678909'), isTrue);
      expect(schema.validate('user@example.com'), isTrue);
      expect(schema.validate('+5511987654321'), isTrue);
      expect(schema.validate('123e4567-e89b-12d3-a456-426614174000'), isTrue);
    });

    test('plate encadeia com toUpperCase', () {
      final schema = V.string().toUpperCase().plate();
      expect(schema.validate('abc-1234'), isTrue);
      expect(schema.validate('abc1d23'), isTrue);
    });
  });

  group('VStringBr — mensagem customizada', () {
    test('cpf', () {
      final schema = V.string().cpf(message: 'CPF obrigatório!');
      expect(schema.errors('xxxx')!.first.message, 'CPF obrigatório!');
    });

    test('cnpj', () {
      final schema = V.string().cnpj(message: 'CNPJ incorreto');
      expect(schema.errors('xx')!.first.message, 'CNPJ incorreto');
    });

    test('cnh usa feminino explícito', () {
      final schema = V.string().cnh(message: 'CNH inválida');
      expect(schema.errors('00000000000')!.first.message, 'CNH inválida');
    });

    test('plate', () {
      final schema = V.string().plate(message: 'Placa fora do padrão');
      expect(schema.errors('xyz')!.first.message, 'Placa fora do padrão');
    });

    test('phoneBr', () {
      final schema = V.string().phoneBr(message: 'Telefone BR inválido');
      expect(schema.errors('abc')!.first.message, 'Telefone BR inválido');
    });

    test('pixKey', () {
      final schema = V.string().pixKey(message: 'Chave PIX ruim');
      expect(schema.errors('nope')!.first.message, 'Chave PIX ruim');
    });
  });

  group('VStringBr — integração com o core', () {
    test('nullable aceita null e valida quando tem valor', () {
      final schemas = <VString>[
        V.string().cpf().nullable(),
        V.string().cnpj().nullable(),
        V.string().cep().nullable(),
        V.string().plate().nullable(),
        V.string().phoneBr().nullable(),
        V.string().pixKey().nullable(),
      ];
      for (final schema in schemas) {
        expect(schema.validate(null), isTrue);
      }
      expect(V.string().cpf().nullable().validate('123.456.789-09'), isTrue);
      expect(V.string().cpf().nullable().validate('xxxx'), isFalse);
    });

    test('defaultValue passa pela validação do core', () {
      final schema = V.string().defaultValue('123.456.789-09').cpf();
      expect(schema.parse(null), '123.456.789-09');

      // Default inválido é rejeitado (comportamento do core 1.1.0)
      final bad = V.string().defaultValue('xxxx').cpf();
      expect(bad.validate(null), isFalse);
    });

    test('schema composto retorna erros por campo', () {
      V.setLocale(VLocaleBr.ptBr);
      final schema = V.map({
        'cpf': V.string().cpf(),
        'cnpj': V.string().cnpj(),
        'cep': V.string().cep(),
        'placa': V.string().plate(),
      });

      final result = schema.safeParse({
        'cpf': '000.000.000-00',
        'cnpj': '00.000.000/0000-00',
        'cep': '00000-000',
        'placa': 'invalid',
      });

      expect(result, isA<VFailure>());
      final map = (result as VFailure).toMap();
      expect(map['cpf'], 'CPF inválido');
      expect(map['cnpj'], 'CNPJ inválido');
      expect(map['cep'], 'CEP inválido');
      expect(map['placa'], 'Placa inválida');
    });

    test('locale pt-BR interpola {name} dos patterns do core', () {
      V.setLocale(VLocaleBr.ptBr);
      expect(V.string().cpf().errors('xx')!.first.message, 'CPF inválido');
      expect(V.string().cnh().errors('0')!.first.message, 'CNH inválido');
    });
  });
}
