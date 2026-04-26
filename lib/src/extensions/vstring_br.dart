import 'package:validart/validart.dart';

import '../enums.dart';
import '../patterns/cep_pattern.dart';
import '../patterns/cnh_pattern.dart';
import '../patterns/cnpj_pattern.dart';
import '../patterns/cpf_pattern.dart';
import '../patterns/pis_pattern.dart';
import '../patterns/placa_pattern.dart';
import '../patterns/renavam_pattern.dart';
import '../patterns/telefone_pattern.dart';
import '../patterns/titulo_eleitor_pattern.dart';
import '../validators/boleto_validator.dart';
import '../validators/chave_pix_validator.dart';
import '../validators/codigo_banco_validator.dart';
import '../validators/ddd_validator.dart';
import '../validators/uf_validator.dart';

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
/// V.string().placa();
/// V.string().licensePlate(patterns: [const PlacaPattern()]);
///
/// V.string().telefone(apenasCelular: true);
/// V.string().phone(patterns: [const TelefonePattern(apenasCelular: true)]);
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
  /// V.string().placa().validate('ABC-1234');  // true (antiga)
  /// V.string().placa().validate('ABC1D23');   // true (Mercosul)
  ///
  /// V.string().toUpperCase().placa().validate('abc-1234');  // true
  /// ```
  VString placa({ValidationMode mode = ValidationMode.any, String? message}) {
    return licensePlate(
      patterns: [PlacaPattern(mode: mode)],
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
  /// V.string().telefone().validate('(11) 98765-4321');  // true
  /// V.string().telefone().validate('11987654321');      // true
  ///
  /// V.string().telefone(
  ///   pais: CountryCodeFormat.required,
  ///   ddd: FormatoDdd.required,
  ///   apenasCelular: true,
  /// ).validate('+55 (11) 98765-4321');                  // true
  /// ```
  VString telefone({
    FormatoDdd ddd = FormatoDdd.optional,
    CountryCodeFormat pais = CountryCodeFormat.optional,
    bool apenasCelular = false,
    ValidationMode mode = ValidationMode.any,
    String? message,
  }) {
    return phone(
      patterns: [
        TelefonePattern(
          ddd: ddd,
          pais: pais,
          apenasCelular: apenasCelular,
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
  /// [TipoChavePix.brCode] em [allow] para também aceitar o payload
  /// EMVCo de QR Code PIX ("copia e cola"). A validação do BR Code
  /// é estrita — exige estrutura TLV, CRC16 batendo e campos
  /// obrigatórios do Bacen (padrão de mercado).
  ///
  /// Executa na fase de validação.
  ///
  /// ```dart
  /// V.string().chavePix().validate('12345678909');            // true (CPF)
  /// V.string().chavePix().validate('user@example.com');       // true (e-mail)
  /// V.string().chavePix().validate('+5511987654321');         // true (telefone)
  /// V.string().chavePix()
  ///   .validate('123e4567-e89b-12d3-a456-426614174000');      // true (UUID)
  ///
  /// // Restringe a tipos específicos:
  /// V.string().chavePix(
  ///   allow: const [TipoChavePix.email, TipoChavePix.telefone],
  /// );
  ///
  /// // Aceita tudo, inclusive BR Code:
  /// V.string().chavePix(allow: TipoChavePix.values);
  /// ```
  VString chavePix({
    List<TipoChavePix> allow = ChavePixValidator.defaultAllow,
    String? message,
  }) {
    return add(ChavePixValidator(allow: allow), message: message);
  }

  /// Valida que a string é uma sigla de UF brasileira válida — uma
  /// das 27 unidades federativas em caixa alta (`AC`, `AL`, ...,
  /// `TO`).
  ///
  /// Letras devem estar em caixa alta. Encadeie
  /// `V.string().toUpperCase()` para aceitar lowercase.
  ///
  /// Executa na fase de validação.
  ///
  /// ```dart
  /// V.string().uf().validate('SP'); // true
  /// V.string().uf().validate('XY'); // false
  ///
  /// V.string().toUpperCase().uf().validate('rj'); // true
  /// ```
  VString uf({String? message}) {
    return add(const UfValidator(), message: message);
  }

  /// Valida que a string é um código de banco brasileiro válido —
  /// 3 dígitos da tabela COMPE do Banco Central.
  ///
  /// A entrada deve ser exatamente 3 dígitos numéricos com zero à
  /// esquerda quando aplicável. Não aceita formato com DV (`'001-9'`).
  ///
  /// Executa na fase de validação.
  ///
  /// ```dart
  /// V.string().codigoBanco().validate('001'); // true (Banco do Brasil)
  /// V.string().codigoBanco().validate('260'); // true (Nubank)
  /// V.string().codigoBanco().validate('999'); // false
  /// ```
  VString codigoBanco({String? message}) {
    return add(const CodigoBancoValidator(), message: message);
  }

  /// Valida que a string é um DDD brasileiro válido — 2 dígitos da
  /// lista oficial Anatel.
  ///
  /// A entrada deve ser exatamente 2 dígitos numéricos, sem
  /// parênteses ou separadores. Para validar o telefone completo,
  /// use [`telefone`].
  ///
  /// Executa na fase de validação.
  ///
  /// ```dart
  /// V.string().ddd().validate('11'); // true (São Paulo)
  /// V.string().ddd().validate('20'); // false (não atribuído)
  /// ```
  VString ddd({String? message}) {
    return add(const DddValidator(), message: message);
  }

  /// Valida boletos brasileiros — bancário (cobrança) ou de
  /// arrecadação (concessionárias e tributos), tanto na forma de
  /// linha digitável (47/48 dígitos) quanto código de barras (44
  /// dígitos). Aceita máscara — caracteres não numéricos são
  /// descartados.
  ///
  /// Use [formato] para restringir a um único tipo. `null` (default)
  /// aceita os 4 layouts.
  ///
  /// Executa na fase de validação.
  ///
  /// ```dart
  /// V.string().boleto().validate(
  ///   '34191790010104351004791020150008291070026000',
  /// ); // true (linha digitável bancária)
  ///
  /// V.string().boleto(formato: FormatoBoleto.bancario)
  ///   .validate('xx'); // false
  /// ```
  VString boleto({FormatoBoleto? formato, String? message}) {
    return add(BoletoValidator(formato: formato), message: message);
  }
}
