/// Controla se a máscara é obrigatória, opcional ou proibida num
/// validador que aceita máscaras (como CPF, CNPJ, CEP, placa, etc.).
///
/// É o pareamento pt-BR de `ValidationMode` do core — a camada de
/// atalhos (`V.string().cpf(modo: ...)`, etc.) faz o depara
/// internamente.
///
/// ```dart
/// V.string().cpf(modo: ModoValidacao.comMascara);
///   // exige '123.456.789-09', rejeita '12345678909'
///
/// V.string().cep(modo: ModoValidacao.semMascara);
///   // exige '01001000', rejeita '01001-000'
/// ```
enum ModoValidacao {
  /// Aceita o input com ou sem máscara (default).
  qualquer,

  /// Exige a máscara — ex.: CPF `123.456.789-09`, CEP `01001-000`.
  comMascara,

  /// Rejeita a máscara — ex.: CPF só dígitos, CEP só dígitos.
  semMascara,
}

/// Controla se o DDD é obrigatório, opcional ou ausente num
/// telefone brasileiro.
///
/// ```dart
/// V.string().telefone(ddd: FormatoDdd.obrigatorio);
/// ```
enum FormatoDdd {
  /// DDD deve estar presente — ex.: `(11) 98765-4321`.
  obrigatorio,

  /// DDD é aceito quando presente, mas não é obrigatório.
  opcional,

  /// DDD não deve estar presente — ex.: `98765-4321`.
  nenhum,
}

/// Controla se o DDI (`+55`) é obrigatório, opcional ou ausente num
/// telefone brasileiro.
///
/// É o pareamento pt-BR de `CountryCodeFormat` do core — a camada
/// de atalhos (`V.string().telefone(pais: ...)`) faz o depara
/// internamente.
///
/// ```dart
/// V.string().telefone(pais: FormatoPais.obrigatorio);
///   // exige '+55 11 98765-4321'
///
/// V.string().telefone(pais: FormatoPais.nenhum);
///   // exige '11 98765-4321' (sem +55)
/// ```
enum FormatoPais {
  /// DDI deve estar presente — ex.: `+55 11 98765-4321`.
  obrigatorio,

  /// DDI é aceito quando presente, mas não é obrigatório (default).
  opcional,

  /// DDI não deve estar presente — ex.: `(11) 98765-4321`.
  nenhum,
}

/// Tipos de identificador aceitos por `V.string().chavePix(...)`.
///
/// Os cinco primeiros são as chaves PIX do DICT; [brCode] é o
/// payload EMVCo do QR Code ("copia e cola").
///
/// ```dart
/// V.string().chavePix(tipos: const [TipoChavePix.email, TipoChavePix.telefone]);
/// V.string().chavePix(tipos: TipoChavePix.values); // tudo, inclusive BR Code
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
