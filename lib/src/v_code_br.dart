/// Códigos de erro específicos do `validart_br` — usados apenas por
/// validadores que não se encaixam nos patterns genéricos do core.
///
/// CPF, CNPJ, PIS, título de eleitor, CNH e Renavam emitem
/// `VStringCode.taxId`. CEP emite `VStringCode.postalCode`. Placa emite
/// `VStringCode.licensePlate`. Telefone BR emite `VStringCode.phone`.
/// Os códigos BR abaixo existem para validadores que validam contra
/// listas oficiais finitas (UF, COMPE, DDD), agregam múltiplos
/// checksums (boleto) ou que são uniões heterogêneas de formatos
/// (chave PIX).
///
/// ```dart
/// V.setLocale(const VLocale({
///   VStringCodeBr.invalidPixKey: 'Chave PIX inválida',
///   VStringCodeBr.invalidState: 'UF inválida',
/// }));
/// ```
sealed class VStringCodeBr {
  /// A string não é uma chave PIX válida (CPF, CNPJ, e-mail, telefone
  /// BR ou UUID v4).
  static const invalidPixKey = 'invalid_pix_key';

  /// A string não é uma UF brasileira válida (sigla de 2 letras em
  /// caixa alta, dentre as 27 unidades federativas).
  static const invalidState = 'invalid_state';

  /// A string não é um código de banco brasileiro válido (3 dígitos da
  /// tabela COMPE do Banco Central).
  static const invalidBankCode = 'invalid_bank_code';

  /// A string não é um DDD brasileiro válido (2 dígitos da lista
  /// oficial Anatel).
  static const invalidDdd = 'invalid_ddd';

  /// A string não é um boleto brasileiro válido — linha digitável (47
  /// dígitos bancário ou 48 dígitos arrecadação) ou código de barras
  /// (44 dígitos), com checksums mod-10/mod-11 batendo.
  static const invalidBoleto = 'invalid_boleto';
}
