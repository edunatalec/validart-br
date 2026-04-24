/// Códigos de erro específicos do `validart_br` — usados apenas por
/// validadores que não se encaixam nos patterns genéricos do core.
///
/// CPF, CNPJ, PIS, título de eleitor, CNH e Renavam emitem
/// `VStringCode.taxId`. CEP emite `VStringCode.postalCode`. Placa emite
/// `VStringCode.licensePlate`. Telefone BR emite `VStringCode.phone`.
/// Os códigos BR abaixo existem só para validadores compostos que não
/// cabem num único pattern.
///
/// ```dart
/// V.setLocale(const VLocale({
///   VStringCodeBr.invalidPixKey: 'Chave PIX inválida',
/// }));
/// ```
sealed class VStringCodeBr {
  /// A string não é uma chave PIX válida (CPF, CNPJ, e-mail, telefone
  /// BR ou UUID v4).
  static const invalidPixKey = 'invalid_pix_key';
}
