/// @docImport 'package:validart/validart.dart';
///
/// Validadores brasileiros e locale pt-BR para o
/// [validart](https://pub.dev/packages/validart).
///
/// Plugam-se patterns BR nos pontos de extensão do core ([TaxIdPattern],
/// [PostalCodePattern], [LicensePlatePattern], [PhonePattern]); adiciona
/// validators standalone para chave PIX, UF, código de banco, DDD e
/// boleto; e entrega um [VLocale] pt-BR completo.
///
/// ```dart
/// V.setLocale(VLocaleBr.ptBr);
///
/// V.string().cpf().validate('123.456.789-09');
/// V.string().cnpj().validate('12.ABC.345/01DE-35');
/// V.string().chavePix().validate('user@example.com');
/// V.string().uf().validate('SP');
/// ```
///
/// Cada validador tem duas formas equivalentes: o atalho pt-BR
/// ([VStringBr.cpf]) e a forma explícita via pattern do core
/// (`V.string().taxId(patterns: [const CpfPattern()])`). Use o atalho em
/// código BR-only e o pattern quando precisar compor vários países na
/// mesma validação.
///
/// See also:
///
///  * [VStringBr], os atalhos pt-BR sobre `V.string()`.
///  * [VLocaleBr], o locale pt-BR completo — core mais os códigos daqui.
///  * [VStringCodeBr], os códigos de erro próprios deste pacote.
///  * [CpfPattern], [CnpjPattern], [CepPattern], [PisPattern],
///    [TituloEleitorPattern], [CnhPattern], [RenavamPattern],
///    [PlacaPattern] e [TelefonePattern], os patterns de documento.
///  * [ChavePixValidator], [UfValidator], [CodigoBancoValidator],
///    [DddValidator] e [BoletoValidator], os validators standalone.
library;

export 'package:validart/validart.dart' show ValidationMode, CountryCodeFormat;

export 'src/enums.dart';
export 'src/extensions/vstring_br.dart';
export 'src/locales/pt_br.dart';
export 'src/patterns/cep_pattern.dart' show CepPattern;
export 'src/patterns/cnh_pattern.dart' show CnhPattern;
export 'src/patterns/cnpj_pattern.dart' show CnpjPattern;
export 'src/patterns/cpf_pattern.dart' show CpfPattern;
export 'src/patterns/pis_pattern.dart' show PisPattern;
export 'src/patterns/placa_pattern.dart' show PlacaPattern;
export 'src/patterns/renavam_pattern.dart' show RenavamPattern;
export 'src/patterns/telefone_pattern.dart' show TelefonePattern;
export 'src/patterns/titulo_eleitor_pattern.dart' show TituloEleitorPattern;
export 'src/v_code_br.dart';
export 'src/validators/boleto_validator.dart' show BoletoValidator;
export 'src/validators/chave_pix_validator.dart' show ChavePixValidator;
export 'src/validators/codigo_banco_validator.dart' show CodigoBancoValidator;
export 'src/validators/ddd_validator.dart' show DddValidator;
export 'src/validators/uf_validator.dart' show UfValidator;
