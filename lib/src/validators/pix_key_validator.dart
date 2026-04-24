import 'package:validart/validart.dart';

import '../enums.dart';
import '../patterns/br_phone_pattern.dart';
import '../patterns/cnpj_pattern.dart';
import '../patterns/cpf_pattern.dart';
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
/// Emite [VStringCodeBr.invalidPixKey] em caso de falha.
///
/// Executa na fase de validação.
///
/// ```dart
/// V.string().pixKey().validate('12345678909');             // true (CPF)
/// V.string().pixKey().validate('user@example.com');        // true (e-mail)
/// V.string().pixKey().validate('+5511987654321');          // true (telefone)
/// V.string().pixKey()
///   .validate('123e4567-e89b-12d3-a456-426614174000');     // true (UUID)
///
/// // Só aceita BR Code:
/// V.string().pixKey(allow: const [PixKeyType.brCode])
///   .validate('00020126...6304ABCD');                      // true/false
///
/// // Aceita tudo (5 chaves + BR Code):
/// V.string().pixKey(allow: PixKeyType.values);
/// ```
class PixKeyValidator extends Validator<String> {
  /// Conjunto padrão de tipos aceitos — apenas as cinco chaves PIX do
  /// DICT. BR Code precisa ser habilitado explicitamente em [allow].
  static const List<PixKeyType> defaultAllow = <PixKeyType>[
    PixKeyType.cpf,
    PixKeyType.cnpj,
    PixKeyType.email,
    PixKeyType.phone,
    PixKeyType.random,
  ];

  /// Tipos de identificador PIX aceitos. Uma lista vazia rejeita
  /// qualquer entrada (nenhum formato casa).
  final List<PixKeyType> allow;

  /// Cria um [PixKeyValidator] que aceita os tipos listados em [allow].
  const PixKeyValidator({this.allow = defaultAllow});

  static const _cpf = CpfPattern(mode: ValidationMode.unformatted);
  static const _cnpj = CnpjPattern(
    mode: ValidationMode.unformatted,
    alphanumeric: false,
  );
  static const _phone = BrPhonePattern(
    countryCode: CountryCodeFormat.required,
    areaCode: AreaCodeFormat.required,
    mobileOnly: true,
    mode: ValidationMode.unformatted,
  );

  static final _emailRegex = RegExp(
    r"^(?!.*\.\.)[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*\.[a-zA-Z]{2,}$",
  );

  static final _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  @override
  String get code => VStringCodeBr.invalidPixKey;

  @override
  Map<String, dynamic>? validate(String value) {
    for (final type in allow) {
      final matched = switch (type) {
        PixKeyType.cpf => _cpf.matches(value),
        PixKeyType.cnpj => _cnpj.matches(value),
        PixKeyType.email => _emailRegex.hasMatch(value),
        PixKeyType.phone => _phone.validate(value) == null,
        PixKeyType.random => _uuidRegex.hasMatch(value),
        PixKeyType.brCode => PixBrCode.isValid(value),
      };
      if (matched) return null;
    }
    return {};
  }
}
