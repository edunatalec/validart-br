/// Códigos de erro específicos do `validart_br` — usados apenas por
/// validadores que não se encaixam nos patterns genéricos do core.
///
/// CPF, CNPJ, PIS, título de eleitor, CNH e Renavam emitem
/// `VStringCode.taxId`. CEP emite `VStringCode.postalCode`. Placa
/// emite `VStringCode.licensePlate`. Telefone BR emite
/// `VStringCode.phone`. Os códigos BR abaixo existem para
/// validadores que validam contra listas oficiais finitas (UF,
/// COMPE, DDD), agregam múltiplos checksums (boleto) ou que são
/// uniões heterogêneas de formatos (chave PIX).
///
/// ```dart
/// V.setLocale(const VLocale({
///   VStringCodeBr.chavePixInvalida: 'Chave PIX inválida',
///   VStringCodeBr.ufInvalida: 'UF inválida',
/// }));
/// ```
sealed class VStringCodeBr {
  /// A string não é uma chave PIX válida (CPF, CNPJ, e-mail,
  /// telefone BR ou UUID v4).
  static const chavePixInvalida = 'chave_pix_invalida';

  /// A string não é uma UF brasileira válida (sigla de 2 letras em
  /// caixa alta, dentre as 27 unidades federativas).
  static const ufInvalida = 'uf_invalida';

  /// A string não é um código de banco brasileiro válido (3 dígitos
  /// da tabela COMPE do Banco Central).
  static const codigoBancoInvalido = 'codigo_banco_invalido';

  /// A string não é um DDD brasileiro válido (2 dígitos da lista
  /// oficial Anatel).
  static const dddInvalido = 'ddd_invalido';

  /// A string não é um boleto brasileiro válido — linha digitável
  /// (47 dígitos bancário ou 48 dígitos arrecadação) ou código de
  /// barras (44 dígitos), com checksums mod-10/mod-11 batendo.
  static const boletoInvalido = 'boleto_invalido';
}
