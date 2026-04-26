import 'package:validart/validart.dart';

import '../v_code_br.dart';

/// Mensagens em pt-BR para os códigos do core do validart.
const Map<String, String> _kValidartPtBrMessages = <String, String>{
  // Geral (fallbacks do VCode que cobrem required/invalid_type de todos os
  // tipos via o lookup hierárquico do VLocale: `string.required` → `required`).
  VCode.required: 'Campo obrigatório',
  VCode.invalidType: 'Tipo inválido: esperado {expected}, recebido {received}',
  VCode.custom: 'Valor inválido',

  // String
  VStringCode.notEmpty: 'Não pode ser vazio',
  VStringCode.tooSmall: 'Deve ter no mínimo {min} caracteres',
  VStringCode.tooBig: 'Deve ter no máximo {max} caracteres',
  VStringCode.length: 'Deve ter exatamente {length} caracteres',
  VStringCode.integer: 'Deve ser um inteiro válido',
  VStringCode.numeric: 'Deve ser um número válido',
  VStringCode.email: 'E-mail inválido',
  VStringCode.url: 'URL inválida',
  VStringCode.uuid: 'UUID inválido',
  VStringCode.ip: 'Endereço IP inválido',
  VStringCode.format: 'Formato inválido',
  VStringCode.date: 'Data inválida',
  VStringCode.time: 'Hora inválida',
  VStringCode.contains: 'Deve conter "{substring}"',
  VStringCode.startsWith: 'Deve começar com "{prefix}"',
  VStringCode.endsWith: 'Deve terminar com "{suffix}"',
  VStringCode.equals: 'Deve ser igual a "{expected}"',
  VStringCode.alpha: 'Deve conter apenas letras',
  VStringCode.alphanumeric: 'Deve conter apenas letras e números',
  VStringCode.slug: 'Deve ser um slug válido',
  VStringCode.password:
      'A senha deve ter no mínimo 8 caracteres, incluindo maiúscula, minúscula, dígito e caractere especial',
  VStringCode.jwt: 'JWT inválido',
  VStringCode.card: 'Número de cartão de crédito inválido',
  VStringCode.phone: 'Telefone inválido',
  VStringCode.base64: 'Base64 inválido',
  VStringCode.hexColor: 'Cor hexadecimal inválida',
  VStringCode.mac: 'Endereço MAC inválido',
  VStringCode.semver: 'Versão SemVer inválida',
  VStringCode.mongoId: 'ObjectId MongoDB inválido',
  VStringCode.ulid: 'ULID inválido',
  VStringCode.nanoId: 'NanoID inválido',
  VStringCode.iban: 'IBAN inválido',
  VStringCode.json: 'JSON inválido',
  VStringCode.cvv: 'CVV inválido',

  // Patterns plugáveis do core — usam {name} pra interpolar o tipo
  VStringCode.taxId: '{name} inválido',
  VStringCode.postalCode: '{name} inválido',
  VStringCode.licensePlate: '{name} inválida',

  // Number (compartilhado por int e double)
  VNumberCode.tooSmall: 'Deve ser no mínimo {min}',
  VNumberCode.tooBig: 'Deve ser no máximo {max}',
  VNumberCode.notInRange: 'Deve estar entre {min} e {max}',
  VNumberCode.positive: 'Deve ser positivo',
  VNumberCode.negative: 'Deve ser negativo',
  VNumberCode.multipleOf: 'Deve ser múltiplo de {factor}',
  VNumberCode.finite: 'Deve ser finito',

  // Int
  VIntCode.even: 'Deve ser par',
  VIntCode.odd: 'Deve ser ímpar',
  VIntCode.prime: 'Deve ser primo',

  // Double
  VDoubleCode.decimal: 'Deve ser um número decimal',
  VDoubleCode.integer: 'Deve ser um número inteiro',

  // Bool
  VBoolCode.isTrue: 'Deve ser verdadeiro',
  VBoolCode.isFalse: 'Deve ser falso',

  // Date
  VDateCode.tooSmall: 'Deve ser depois de {date}',
  VDateCode.tooBig: 'Deve ser antes de {date}',
  VDateCode.notInRange: 'Deve estar entre {min} e {max}',
  VDateCode.weekday: 'Deve ser um dia útil',
  VDateCode.weekend: 'Deve ser um fim de semana',
  VDateCode.age: 'Idade fora da faixa permitida',

  // Array
  VArrayCode.tooSmall: 'Deve ter no mínimo {min} itens',
  VArrayCode.tooBig: 'Deve ter no máximo {max} itens',
  VArrayCode.unique: 'Deve conter valores únicos',
  VArrayCode.containsAll: 'Deve conter todos os valores obrigatórios',

  // Map
  VMapCode.unrecognizedKey: 'Chave não reconhecida "{key}"',
  VMapCode.fieldsNotEqual: '{field} deve ser igual a {other}',

  // Object — novo em validart 2.0.0 (V.object<T>().equalFields()).
  VObjectCode.fieldsNotEqual: '{field} deve ser igual a {other}',

  // Composite
  VEnumCode.invalid: 'Valor inválido. Esperado um de: {values}',
  VLiteralCode.invalid: 'Esperado "{expected}", recebido "{received}"',
  VUnionCode.invalid: 'Valor não corresponde a nenhum dos tipos da união',
};

/// Mensagens em pt-BR dos códigos específicos do `validart_br`.
const Map<String, String> _kValidartBrMessages = <String, String>{
  VStringCodeBr.chavePixInvalida: 'Chave PIX inválida',
  VStringCodeBr.ufInvalida: 'UF inválida',
  VStringCodeBr.codigoBancoInvalido: 'Código de banco inválido',
  VStringCodeBr.dddInvalido: 'DDD inválido',
  VStringCodeBr.boletoInvalido: 'Boleto inválido',
};

/// Locale em português do Brasil para o validart.
///
/// Três formas de uso, da mais simples à mais flexível:
///
/// ```dart
/// // 1. Pronto para uso (core + BR):
/// V.setLocale(VLocaleBr.ptBr);
///
/// // 2. Override pontual de uma ou mais mensagens:
/// V.setLocale(VLocaleBr.ptBrWith({
///   VCode.required: 'Obrigatório',
///   VStringCode.taxId: '{name} incorreto',
/// }));
///
/// // 3. Acesso direto aos mapas, quando for preciso compor com outras
/// //    fontes:
/// V.setLocale(const VLocale({
///   ...VLocaleBr.coreMessages,
///   ...VLocaleBr.brMessages,
///   VCode.required: 'Obrigatório',
/// }));
/// ```
sealed class VLocaleBr {
  /// Mensagens dos códigos do core do validart em pt-BR.
  static const Map<String, String> coreMessages = _kValidartPtBrMessages;

  /// Mensagens dos códigos específicos do `validart_br` em pt-BR.
  static const Map<String, String> brMessages = _kValidartBrMessages;

  /// União das mensagens do core com as do `validart_br`.
  static const Map<String, String> messages = <String, String>{
    ..._kValidartPtBrMessages,
    ..._kValidartBrMessages,
  };

  /// [VLocale] pt-BR completo — core + BR, pronto para uso.
  static const VLocale ptBr = VLocale(messages);

  /// [VLocale] pt-BR com [overrides] aplicados em cima das mensagens
  /// padrão.
  ///
  /// ```dart
  /// V.setLocale(VLocaleBr.ptBrWith({
  ///   VCode.required: 'Obrigatório',
  /// }));
  /// ```
  static VLocale ptBrWith(Map<String, String> overrides) {
    return VLocale(<String, String>{...messages, ...overrides});
  }
}
