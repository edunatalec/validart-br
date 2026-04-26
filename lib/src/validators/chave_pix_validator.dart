import 'package:validart/validart.dart';

import '../enums.dart';
import '../patterns/cnpj_pattern.dart';
import '../patterns/cpf_pattern.dart';
import '../patterns/telefone_pattern.dart';
import '../v_code_br.dart';
import 'pix_br_code.dart';

/// Valida que a string é um identificador PIX — chave do DICT (CPF,
/// CNPJ, e-mail, telefone `+55…`, UUID v4) e/ou BR Code (payload
/// EMVCo do QR Code PIX).
///
/// O parâmetro [allow] controla quais tipos são aceitos — por padrão
/// apenas as cinco chaves do DICT (sem BR Code). Cada formato é
/// verificado no modo estrito exigido pelo PIX: CPF/CNPJ só com
/// dígitos, telefone em E.164 com DDI `+55`, BR Code com CRC16
/// batendo e campos obrigatórios do Bacen.
///
/// Emite [VStringCodeBr.chavePixInvalida] em caso de falha.
///
/// Executa na fase de validação.
///
/// ```dart
/// V.string().chavePix().validate('12345678909');             // true (CPF)
/// V.string().chavePix().validate('user@example.com');        // true (e-mail)
/// V.string().chavePix().validate('+5511987654321');          // true (telefone)
/// V.string().chavePix()
///   .validate('123e4567-e89b-12d3-a456-426614174000');       // true (UUID)
///
/// // Só aceita BR Code:
/// V.string().chavePix(allow: const [TipoChavePix.brCode])
///   .validate('00020126...6304ABCD');                        // true/false
///
/// // Aceita tudo (5 chaves + BR Code):
/// V.string().chavePix(allow: TipoChavePix.values);
/// ```
class ChavePixValidator extends Validator<String> {
  /// Conjunto padrão de tipos aceitos — apenas as cinco chaves PIX
  /// do DICT. BR Code precisa ser habilitado explicitamente em [allow].
  static const List<TipoChavePix> defaultAllow = <TipoChavePix>[
    TipoChavePix.cpf,
    TipoChavePix.cnpj,
    TipoChavePix.email,
    TipoChavePix.telefone,
    TipoChavePix.aleatoria,
  ];

  /// Tipos de identificador PIX aceitos. Uma lista vazia rejeita
  /// qualquer entrada (nenhum formato casa).
  final List<TipoChavePix> allow;

  /// Cria um [ChavePixValidator] que aceita os tipos listados em [allow].
  const ChavePixValidator({this.allow = defaultAllow});

  static const _cpf = CpfPattern(mode: ValidationMode.unformatted);
  static const _cnpj = CnpjPattern(
    mode: ValidationMode.unformatted,
    alphanumeric: false,
  );
  static const _telefone = TelefonePattern(
    pais: CountryCodeFormat.required,
    ddd: FormatoDdd.required,
    apenasCelular: true,
    mode: ValidationMode.unformatted,
  );

  static final _emailRegex = RegExp(
    r"^(?!.*\.\.)[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*\.[a-zA-Z]{2,}$",
  );

  static final _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  @override
  String get code => VStringCodeBr.chavePixInvalida;

  @override
  Map<String, dynamic>? validate(String value) {
    for (final type in allow) {
      final matched = switch (type) {
        TipoChavePix.cpf => _cpf.matches(value),
        TipoChavePix.cnpj => _cnpj.matches(value),
        TipoChavePix.email => _emailRegex.hasMatch(value),
        TipoChavePix.telefone => _telefone.validate(value) == null,
        TipoChavePix.aleatoria => _uuidRegex.hasMatch(value),
        TipoChavePix.brCode => PixBrCode.isValid(value),
      };
      if (matched) return null;
    }
    return {};
  }
}
