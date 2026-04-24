import 'package:validart/validart.dart';

import '../enums.dart';
import '../patterns/br_phone_pattern.dart';
import '../patterns/br_plate_pattern.dart';
import '../patterns/cep_pattern.dart';
import '../patterns/cnh_pattern.dart';
import '../patterns/cnpj_pattern.dart';
import '../patterns/cpf_pattern.dart';
import '../patterns/pis_pattern.dart';
import '../patterns/renavam_pattern.dart';
import '../patterns/titulo_eleitor_pattern.dart';
import '../validators/pix_key_validator.dart';

/// Atalhos de validadores brasileiros em cima de [VString].
///
/// Cada atalho delega ao método equivalente do core com o pattern BR
/// plugado. A forma explícita via pattern é sempre equivalente ao
/// atalho:
///
/// ```dart
/// V.string().cpf();                                        // atalho
/// V.string().taxId(patterns: [const CpfPattern()]);        // explícita
///
/// V.string().cep();
/// V.string().postalCode(patterns: [const CepPattern()]);
///
/// V.string().plate();
/// V.string().licensePlate(patterns: [const BrPlatePattern()]);
///
/// V.string().phoneBr(mobileOnly: true);
/// V.string().phone(patterns: [const BrPhonePattern(mobileOnly: true)]);
/// ```
extension VStringBr on VString {
  /// Valida que a string é um CPF válido (11 dígitos com dois DVs).
  ///
  /// Executa na fase de validação.
  ///
  /// ```dart
  /// V.string().cpf().validate('123.456.789-09');  // true
  /// V.string().cpf().validate('111.111.111-11');  // false
  ///
  /// V.string().cpf(mode: ValidationMode.unformatted)
  ///   .validate('12345678909');                   // true
  /// ```
  VString cpf({ValidationMode mode = ValidationMode.any, String? message}) {
    return taxId(
      patterns: [CpfPattern(mode: mode)],
      message: message,
    );
  }

  /// Valida que a string é um CNPJ válido.
  ///
  /// Por padrão aceita o novo formato alfanumérico da Receita Federal.
  /// Passe `alphanumeric: false` para travar no formato antigo (só
  /// dígitos). Letras devem estar em caixa alta — encadeie
  /// `V.string().toUpperCase()` se o input pode vir em lowercase.
  ///
  /// Executa na fase de validação.
  ///
  /// ```dart
  /// V.string().cnpj().validate('12.345.678/0001-95');  // true (numérico)
  /// V.string().cnpj().validate('12.ABC.345/01DE-35');  // true (alfanumérico)
  ///
  /// V.string().cnpj(alphanumeric: false)
  ///   .validate('12.ABC.345/01DE-35');                 // false
  /// ```
  VString cnpj({
    ValidationMode mode = ValidationMode.any,
    bool alphanumeric = true,
    String? message,
  }) {
    return taxId(
      patterns: [CnpjPattern(mode: mode, alphanumeric: alphanumeric)],
      message: message,
    );
  }

  /// Valida que a string é um CEP válido (8 dígitos).
  ///
  /// Executa na fase de validação.
  ///
  /// ```dart
  /// V.string().cep().validate('01001-000');  // true
  /// V.string().cep().validate('01001000');   // true
  /// V.string().cep().validate('0100100');    // false
  /// ```
  VString cep({ValidationMode mode = ValidationMode.any, String? message}) {
    return postalCode(
      patterns: [CepPattern(mode: mode)],
      message: message,
    );
  }

  /// Valida que a string é um PIS/PASEP/NIS válido (11 dígitos).
  ///
  /// Executa na fase de validação.
  ///
  /// ```dart
  /// V.string().pis().validate('120.54789.01-3');  // true
  /// V.string().pis().validate('12054789013');     // true
  /// ```
  VString pis({ValidationMode mode = ValidationMode.any, String? message}) {
    return taxId(
      patterns: [PisPattern(mode: mode)],
      message: message,
    );
  }

  /// Valida que a string é um título de eleitor válido (12 dígitos,
  /// UF `01..28`).
  ///
  /// Executa na fase de validação.
  ///
  /// ```dart
  /// V.string().tituloEleitor().validate('876543210329');  // true
  /// ```
  VString tituloEleitor({String? message}) {
    return taxId(patterns: [const TituloEleitorPattern()], message: message);
  }

  /// Valida que a string é uma CNH válida (11 dígitos).
  ///
  /// Executa na fase de validação.
  ///
  /// ```dart
  /// V.string().cnh().validate('12345678900');  // true
  /// V.string().cnh().validate('00000000000');  // false
  /// ```
  VString cnh({String? message}) {
    return taxId(patterns: [const CnhPattern()], message: message);
  }

  /// Valida que a string é um Renavam válido (11 dígitos).
  ///
  /// Executa na fase de validação.
  ///
  /// ```dart
  /// V.string().renavam().validate('12345678900');  // true
  /// ```
  VString renavam({String? message}) {
    return taxId(patterns: [const RenavamPattern()], message: message);
  }

  /// Valida que a string é uma placa de veículo brasileira — formato
  /// antigo (`AAA-9999` / `AAA9999`) ou Mercosul (`AAA9A99`).
  ///
  /// Letras devem estar em caixa alta. Encadeie
  /// `V.string().toUpperCase()` para aceitar lowercase.
  ///
  /// Executa na fase de validação.
  ///
  /// ```dart
  /// V.string().plate().validate('ABC-1234');  // true (antiga)
  /// V.string().plate().validate('ABC1D23');   // true (Mercosul)
  ///
  /// V.string().toUpperCase().plate().validate('abc-1234');  // true
  /// ```
  VString plate({ValidationMode mode = ValidationMode.any, String? message}) {
    return licensePlate(
      patterns: [BrPlatePattern(mode: mode)],
      message: message,
    );
  }

  /// Valida que a string é um telefone brasileiro válido.
  ///
  /// Aceita celular (9 dígitos iniciando com `9`) e fixo (8 dígitos),
  /// com ou sem DDD e DDI. Use os parâmetros para restringir a forma.
  ///
  /// Executa na fase de validação.
  ///
  /// ```dart
  /// V.string().phoneBr().validate('(11) 98765-4321');  // true
  /// V.string().phoneBr().validate('11987654321');      // true
  ///
  /// V.string().phoneBr(
  ///   countryCode: CountryCodeFormat.required,
  ///   areaCode: AreaCodeFormat.required,
  ///   mobileOnly: true,
  /// ).validate('+55 (11) 98765-4321');                 // true
  /// ```
  VString phoneBr({
    AreaCodeFormat areaCode = AreaCodeFormat.optional,
    CountryCodeFormat countryCode = CountryCodeFormat.optional,
    bool mobileOnly = false,
    ValidationMode mode = ValidationMode.any,
    String? message,
  }) {
    return phone(
      patterns: [
        BrPhonePattern(
          areaCode: areaCode,
          countryCode: countryCode,
          mobileOnly: mobileOnly,
          mode: mode,
        ),
      ],
      message: message,
    );
  }

  /// Valida que a string é um identificador PIX válido.
  ///
  /// Por padrão aceita as cinco chaves do DICT — CPF, CNPJ, e-mail,
  /// telefone (`+55…`) e UUID v4 (chave aleatória). Inclua
  /// [PixKeyType.brCode] em [allow] para também aceitar o payload
  /// EMVCo de QR Code PIX ("copia e cola"). A validação do BR Code é
  /// estrita — exige estrutura TLV, CRC16 batendo e campos
  /// obrigatórios do Bacen (padrão de mercado).
  ///
  /// Executa na fase de validação.
  ///
  /// ```dart
  /// V.string().pixKey().validate('12345678909');            // true (CPF)
  /// V.string().pixKey().validate('user@example.com');       // true (e-mail)
  /// V.string().pixKey().validate('+5511987654321');         // true (telefone)
  /// V.string().pixKey()
  ///   .validate('123e4567-e89b-12d3-a456-426614174000');    // true (UUID)
  ///
  /// // Restringe a tipos específicos:
  /// V.string().pixKey(allow: const [PixKeyType.email, PixKeyType.phone]);
  ///
  /// // Aceita tudo, inclusive BR Code:
  /// V.string().pixKey(allow: PixKeyType.values);
  /// ```
  VString pixKey({
    List<PixKeyType> allow = PixKeyValidator.defaultAllow,
    String? message,
  }) {
    return add(PixKeyValidator(allow: allow), message: message);
  }
}
