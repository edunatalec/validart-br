/// Controla se o DDD é obrigatório, opcional ou proibido num telefone
/// brasileiro.
///
/// ```dart
/// V.string().phoneBr(areaCode: AreaCodeFormat.required);
/// ```
enum AreaCodeFormat {
  /// DDD deve estar presente — ex.: `(11) 98765-4321`.
  required,

  /// DDD é aceito quando presente, mas não é obrigatório.
  optional,

  /// DDD deve estar ausente — ex.: `98765-4321`.
  none,
}

/// Tipos de identificador aceitos por `V.string().pixKey(...)`.
///
/// Os cinco primeiros são as chaves PIX do DICT; [brCode] é o payload
/// EMVCo do QR Code ("copia e cola").
///
/// ```dart
/// V.string().pixKey(allow: const [PixKeyType.email, PixKeyType.phone]);
/// V.string().pixKey(allow: PixKeyType.values); // aceita tudo, inclusive BR Code
/// ```
enum PixKeyType {
  /// CPF em 11 dígitos sem máscara.
  cpf,

  /// CNPJ numérico em 14 dígitos sem máscara.
  cnpj,

  /// E-mail.
  email,

  /// Telefone E.164 brasileiro, celular (`+55DDDNNNNNNNNN`).
  phone,

  /// Chave aleatória — UUID v4 (36 caracteres).
  random,

  /// BR Code — payload EMVCo do QR Code PIX ("copia e cola"), validado
  /// com CRC16 e campos obrigatórios do padrão Bacen.
  brCode,
}
