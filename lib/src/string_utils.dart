/// Helpers internos de manipulação de string.
extension StringUtils on String {
  /// Retorna apenas os dígitos da string.
  String get onlyDigits => replaceAll(RegExp(r'[^\d]'), '');

  /// `true` se todos os caracteres da string são iguais (ex.: `'11111111111'`).
  /// Retorna `false` para string vazia.
  bool get isRepeatedCharacters {
    if (isEmpty) return false;

    final String first = this[0];
    for (int i = 1; i < length; i++) {
      if (this[i] != first) return false;
    }

    return true;
  }
}
