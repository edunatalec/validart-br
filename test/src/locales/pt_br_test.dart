import 'package:test/test.dart';
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

void main() {
  tearDown(() => V.setLocale(const VLocale()));

  group('VLocaleBr.ptBr', () {
    setUp(() => V.setLocale(VLocaleBr.ptBr));

    test('traduz mensagens do core do validart', () {
      expect(V.t(VCode.required), 'Campo obrigatório');
      expect(V.t(VStringCode.email), 'E-mail inválido');
      expect(V.t(VStringCode.notEmpty), 'Não pode ser vazio');
      expect(V.t(VNumberCode.positive), 'Deve ser positivo');
    });

    test('traduz mensagens com interpolação', () {
      expect(
        V.t(VStringCode.tooSmall, {'min': 3}),
        'Deve ter no mínimo 3 caracteres',
      );
      expect(
        V.t(VNumberCode.notInRange, {'min': 0, 'max': 10}),
        'Deve estar entre 0 e 10',
      );
    });

    test('traduz patterns genéricos com {name}', () {
      expect(V.t(VStringCode.taxId, {'name': 'CPF'}), 'CPF inválido');
      expect(V.t(VStringCode.taxId, {'name': 'CNPJ'}), 'CNPJ inválido');
      expect(V.t(VStringCode.postalCode, {'name': 'CEP'}), 'CEP inválido');
      expect(
        V.t(VStringCode.licensePlate, {'name': 'Placa'}),
        'Placa inválida',
      );
    });

    test('traduz códigos específicos do validart_br', () {
      expect(V.t(VStringCodeBr.chavePixInvalida), 'Chave PIX inválida');
      expect(V.t(VStringCodeBr.ufInvalida), 'UF inválida');
      expect(
        V.t(VStringCodeBr.codigoBancoInvalido),
        'Código de banco inválido',
      );
      expect(V.t(VStringCodeBr.dddInvalido), 'DDD inválido');
      expect(V.t(VStringCodeBr.boletoInvalido), 'Boleto inválido');
    });

    test('traduz fields_not_equal de VObject (novo em validart 2.0.0)', () {
      expect(
        V.t(VObjectCode.fieldsNotEqual, {'field': 'p1', 'other': 'p2'}),
        'p1 deve ser igual a p2',
      );
    });

    test('telefone BR usa o code do core (invalid_phone)', () {
      expect(V.t(VStringCode.phone), 'Telefone inválido');
    });

    test('mensagens de erro aparecem em português no schema', () {
      final schema = V.string().cpf();
      final errors = schema.errors('111.111.111-11');
      expect(errors!.first.message, 'CPF inválido');
    });

    test('placa usa feminino (inválida)', () {
      final schema = V.string().placa();
      final errors = schema.errors('xxx');
      expect(errors!.first.message, 'Placa inválida');
    });

    test('V.object<T>().equalFields() emite mensagem em pt-BR (pin do gap '
        'do validart 2.0.0 — VObjectCode.fieldsNotEqual)', () {
      final schema = V
          .object<_Pwd>()
          .field('p1', (x) => x.p1, V.string())
          .field('p2', (x) => x.p2, V.string())
          .equalFields('p1', 'p2');
      final errors = schema.errors(_Pwd('a', 'b'));
      expect(errors!.first.message, 'p1 deve ser igual a p2');
    });
  });

  group('VLocaleBr.coreMessages / brMessages', () {
    test('coreMessages inclui codes dos patterns plugáveis', () {
      expect(VLocaleBr.coreMessages[VStringCode.taxId], '{name} inválido');
      expect(VLocaleBr.coreMessages[VStringCode.postalCode], '{name} inválido');
      expect(
        VLocaleBr.coreMessages[VStringCode.licensePlate],
        '{name} inválida',
      );
    });

    test('brMessages cobre só os codes específicos do validart_br', () {
      expect(
        VLocaleBr.brMessages[VStringCodeBr.chavePixInvalida],
        'Chave PIX inválida',
      );
      expect(VLocaleBr.brMessages[VStringCodeBr.ufInvalida], 'UF inválida');
      expect(
        VLocaleBr.brMessages[VStringCodeBr.codigoBancoInvalido],
        'Código de banco inválido',
      );
      expect(VLocaleBr.brMessages[VStringCodeBr.dddInvalido], 'DDD inválido');
      expect(
        VLocaleBr.brMessages[VStringCodeBr.boletoInvalido],
        'Boleto inválido',
      );
      expect(VLocaleBr.brMessages.length, 5);
    });

    test('messages é a união de core + br', () {
      expect(
        VLocaleBr.messages.length,
        VLocaleBr.coreMessages.length + VLocaleBr.brMessages.length,
      );
      expect(VLocaleBr.messages[VCode.required], 'Campo obrigatório');
      expect(
        VLocaleBr.messages[VStringCodeBr.chavePixInvalida],
        'Chave PIX inválida',
      );
    });
  });

  group('VLocaleBr.ptBrWith', () {
    test('permite override de uma mensagem do core', () {
      V.setLocale(VLocaleBr.ptBrWith({VCode.required: 'Obrigatório'}));
      expect(V.t(VCode.required), 'Obrigatório');
      expect(V.t(VStringCode.email), 'E-mail inválido');
    });

    test('permite override do template de taxId', () {
      V.setLocale(VLocaleBr.ptBrWith({VStringCode.taxId: '{name} incorreto'}));
      expect(V.t(VStringCode.taxId, {'name': 'CPF'}), 'CPF incorreto');
    });

    test('override vale para mensagens em schemas', () {
      V.setLocale(
        VLocaleBr.ptBrWith({VStringCode.taxId: '{name} fora do padrão'}),
      );
      final errors = V.string().cpf().errors('111.111.111-11');
      expect(errors!.first.message, 'CPF fora do padrão');
    });
  });
}

class _Pwd {
  final String p1;
  final String p2;
  _Pwd(this.p1, this.p2);
}
