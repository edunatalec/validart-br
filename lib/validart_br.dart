/// Validadores brasileiros e locale pt-BR para o
/// [validart](https://pub.dev/packages/validart).
///
/// Plugam-se patterns BR nos pontos de extensão do core ([`TaxIdPattern`],
/// [`PostalCodePattern`], [`LicensePlatePattern`], [`PhonePattern`]);
/// adiciona validators standalone para chave PIX, UF, código de
/// banco, DDD e boleto; e entrega um [`VLocale`] pt-BR completo.
///
/// ```dart
/// import 'package:validart/validart.dart';
/// import 'package:validart_br/validart_br.dart';
///
/// V.setLocale(VLocaleBr.ptBr);
///
/// V.string().cpf().validate('123.456.789-09');
/// V.string().cnpj().validate('12.ABC.345/01DE-35');
/// V.string().chavePix().validate('user@example.com');
/// V.string().uf().validate('SP');
/// ```
library;

// Re-exporta os enums do core que aparecem na API pública deste
// pacote, pra que `import 'package:validart_br/validart_br.dart'`
// baste.
export 'package:validart/validart.dart' show ValidationMode, CountryCodeFormat;

export 'src/enums.dart';
export 'src/v_code_br.dart';
export 'src/extensions/vstring_br.dart';
export 'src/locales/pt_br.dart';

// Patterns — plugam nos validators plugáveis do core.
export 'src/patterns/cpf_pattern.dart' show CpfPattern;
export 'src/patterns/cnpj_pattern.dart' show CnpjPattern;
export 'src/patterns/cep_pattern.dart' show CepPattern;
export 'src/patterns/pis_pattern.dart' show PisPattern;
export 'src/patterns/titulo_eleitor_pattern.dart' show TituloEleitorPattern;
export 'src/patterns/cnh_pattern.dart' show CnhPattern;
export 'src/patterns/renavam_pattern.dart' show RenavamPattern;
export 'src/patterns/placa_pattern.dart' show PlacaPattern;
export 'src/patterns/telefone_pattern.dart' show TelefonePattern;

// Validators standalone — formatos que validam contra listas oficiais
// finitas (UF, COMPE, DDD), agregam múltiplos checksums (boleto) ou
// que são uniões heterogêneas de formatos (chave PIX).
export 'src/validators/chave_pix_validator.dart' show ChavePixValidator;
export 'src/validators/uf_validator.dart' show UfValidator;
export 'src/validators/codigo_banco_validator.dart' show CodigoBancoValidator;
export 'src/validators/ddd_validator.dart' show DddValidator;
export 'src/validators/boleto_validator.dart' show BoletoValidator;
