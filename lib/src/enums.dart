/// Controla se o DDD é obrigatório, opcional ou proibido num
/// telefone brasileiro.
///
/// ```dart
/// V.string().telefone(ddd: FormatoDdd.required);
/// ```
enum FormatoDdd {
  /// DDD deve estar presente — ex.: `(11) 98765-4321`.
  required,

  /// DDD é aceito quando presente, mas não é obrigatório.
  optional,

  /// DDD deve estar ausente — ex.: `98765-4321`.
  none,
}

/// Tipos de identificador aceitos por `V.string().chavePix(...)`.
///
/// Os cinco primeiros são as chaves PIX do DICT; [brCode] é o
/// payload EMVCo do QR Code ("copia e cola").
///
/// ```dart
/// V.string().chavePix(allow: const [TipoChavePix.email, TipoChavePix.telefone]);
/// V.string().chavePix(allow: TipoChavePix.values); // tudo, inclusive BR Code
/// ```
enum TipoChavePix {
  /// CPF em 11 dígitos sem máscara.
  cpf,

  /// CNPJ numérico em 14 dígitos sem máscara.
  cnpj,

  /// E-mail.
  email,

  /// Telefone E.164 brasileiro, celular (`+55DDDNNNNNNNNN`).
  telefone,

  /// Chave aleatória — UUID v4 (36 caracteres).
  aleatoria,

  /// BR Code — payload EMVCo do QR Code PIX ("copia e cola"),
  /// validado com CRC16 e campos obrigatórios do padrão Bacen.
  brCode,
}

/// Restringe a forma aceita por `V.string().boleto(...)`.
///
/// - [bancario]: cobrança bancária. Linha digitável de 47 dígitos
///   (`bbbmA AAAAd BBBBB BBBBBd CCCCC CCCCCd D EEEE FFFFFFFFFF`) ou
///   código de barras de 44 dígitos. DV geral em mod-11; DVs dos
///   campos 1, 2 e 3 da linha digitável em mod-10.
/// - [arrecadacao]: contas (água, luz, gás, telecom, IPTU, GRU, …).
///   Começa com `8`. Linha digitável de 48 dígitos (4 blocos de 11
///   dígitos + 1 DV cada) ou código de barras de 44 dígitos. O 3º
///   dígito do código de barras determina mod-10 (`6`/`7`) ou
///   mod-11 (`8`/`9`).
///
/// Sem restringir formato, `V.string().boleto()` aceita qualquer um
/// dos quatro layouts.
///
/// ```dart
/// V.string().boleto(); // qualquer formato
/// V.string().boleto(formato: FormatoBoleto.bancario); // só bancário
/// V.string().boleto(formato: FormatoBoleto.arrecadacao); // só arrecadação
/// ```
enum FormatoBoleto {
  /// Boleto de cobrança bancária — linha digitável 47 ou código de
  /// barras 44, primeiro dígito ≠ `8`.
  bancario,

  /// Boleto de arrecadação (concessionárias e tributos) — linha
  /// digitável 48 ou código de barras 44, primeiro dígito = `8`.
  arrecadacao,
}
