import 'package:validart/validart.dart';

/// Valida placas de veículos brasileiras — formato antigo
/// (`AAA-9999` / `AAA9999`) e Mercosul (`AAA9A99`).
///
/// Letras devem estar em caixa alta. Encadeie
/// `V.string().toUpperCase()` para aceitar lowercase. [mode] controla
/// o hífen do formato antigo; placas Mercosul passam sempre,
/// independente de [mode].
///
/// ```dart
/// V.string().licensePlate(patterns: [const PlacaPattern()]);
/// V.string().placa(); // atalho
///
/// V.string().toUpperCase().placa()
///   .validate('abc-1234'); // true
/// ```
class PlacaPattern extends LicensePlatePattern {
  static final _oldWithDash = RegExp(r'^[A-Z]{3}-\d{4}$');
  static final _oldNoDash = RegExp(r'^[A-Z]{3}\d{4}$');
  static final _mercosul = RegExp(r'^[A-Z]{3}\d[A-Z]\d{2}$');

  /// Controla se o hífen do formato antigo é obrigatório, proibido ou
  /// opcional. Placas Mercosul não são afetadas. Padrão:
  /// [ValidationMode.any].
  final ValidationMode mode;

  /// Cria um [PlacaPattern].
  const PlacaPattern({this.mode = ValidationMode.any});

  @override
  String get name => 'Placa';

  @override
  bool matches(String value) {
    if (_mercosul.hasMatch(value)) return true;

    switch (mode) {
      case ValidationMode.any:
        return _oldWithDash.hasMatch(value) || _oldNoDash.hasMatch(value);
      case ValidationMode.formatted:
        return _oldWithDash.hasMatch(value);
      case ValidationMode.unformatted:
        return _oldNoDash.hasMatch(value);
    }
  }
}
