import 'package:validart/validart.dart';

import '../enums.dart';
import '../v_code_br.dart';

/// Valida boletos brasileiros — bancário (cobrança) ou de
/// arrecadação (concessionárias e tributos), em qualquer das quatro
/// formas:
///
/// - **Linha digitável bancária** (47 dígitos);
/// - **Código de barras bancário** (44 dígitos), primeiro dígito ≠ `8`;
/// - **Linha digitável de arrecadação** (48 dígitos);
/// - **Código de barras de arrecadação** (44 dígitos), primeiro
///   dígito = `8`.
///
/// Aceita máscara — qualquer caractere não numérico é descartado
/// antes da validação.
///
/// ### Algoritmos
///
/// **Bancário** — DVs mod-10 nos campos 1, 2 e 3 da linha digitável,
/// mais o DV geral mod-11 (posição 5 do código de barras / posição
/// 33 da linha digitável).
///
/// **Arrecadação** — o terceiro dígito do código de barras determina
/// o módulo dos DVs dos quatro blocos da linha digitável: `6`/`7` →
/// mod-10, `8`/`9` → mod-11. O DV geral está na posição 4 do código
/// de barras.
///
/// Use [format] para restringir a um único tipo. `null` (default)
/// aceita qualquer um.
///
/// Emite [VStringCodeBr.invalidBoleto] em caso de falha.
///
/// Executa na fase de validação.
///
/// ```dart
/// V.string().boleto().validate(
///   '34191790010104351004791020150008291070026000',
/// ); // true (linha digitável bancária)
///
/// V.string().boleto(format: BoletoFormat.bancario)
///   .validate('xx'); // false
/// ```
class BoletoValidator extends Validator<String> {
  /// Restringe o formato aceito. `null` aceita os 4 layouts.
  final BoletoFormat? format;

  /// Cria um [BoletoValidator].
  const BoletoValidator({this.format});

  @override
  String get code => VStringCodeBr.invalidBoleto;

  @override
  Map<String, dynamic>? validate(String value) {
    final String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return {};

    final bool isArrecadacao = digits.startsWith('8');

    if (format == BoletoFormat.bancario && isArrecadacao) return {};
    if (format == BoletoFormat.arrecadacao && !isArrecadacao) return {};

    final bool valid = isArrecadacao
        ? _validateArrecadacao(digits)
        : _validateBancario(digits);

    return valid ? null : {};
  }

  // -------------------------------------------------------------- bancário

  /// Bancário — aceita 44 dígitos (código de barras) ou 47 dígitos
  /// (linha digitável).
  static bool _validateBancario(String digits) {
    if (digits.length == 44) return _validateBancarioBarcode(digits);
    if (digits.length == 47) return _validateBancarioLinha(digits);
    return false;
  }

  static bool _validateBancarioBarcode(String barcode) {
    final int dv = int.parse(barcode[4]);
    final String rest = barcode.substring(0, 4) + barcode.substring(5);

    return _mod11Bancario(rest) == dv;
  }

  static bool _validateBancarioLinha(String linha) {
    // Campo 1: posições 0-8 + DV em 9.
    final String c1 = linha.substring(0, 9);
    final int dv1 = int.parse(linha[9]);
    if (_mod10(c1) != dv1) return false;

    // Campo 2: posições 10-19 + DV em 20.
    final String c2 = linha.substring(10, 20);
    final int dv2 = int.parse(linha[20]);
    if (_mod10(c2) != dv2) return false;

    // Campo 3: posições 21-30 + DV em 31.
    final String c3 = linha.substring(21, 31);
    final int dv3 = int.parse(linha[31]);
    if (_mod10(c3) != dv3) return false;

    // DV geral em 32 — calculado sobre o código de barras reconstituído.
    final String barcode = _linhaToBarcodeBancario(linha);
    return _validateBancarioBarcode(barcode);
  }

  /// Reconstitui o código de barras (44 dígitos) a partir da linha
  /// digitável bancária (47 dígitos).
  static String _linhaToBarcodeBancario(String linha) {
    final StringBuffer b = StringBuffer();
    b.write(linha.substring(0, 4)); // banco + moeda
    b.write(linha[32]); // DV geral
    b.write(linha.substring(33, 47)); // fator (4) + valor (10)
    b.write(linha.substring(4, 9)); // 5 do campo livre
    b.write(linha.substring(10, 20)); // 10 do campo livre
    b.write(linha.substring(21, 31)); // 10 do campo livre
    return b.toString();
  }

  // ----------------------------------------------------------- arrecadação

  /// Arrecadação — aceita 44 dígitos (código de barras) ou 48 dígitos
  /// (linha digitável). Sempre começa com `8`.
  static bool _validateArrecadacao(String digits) {
    if (digits.length == 44) return _validateArrecadacaoBarcode(digits);
    if (digits.length == 48) return _validateArrecadacaoLinha(digits);
    return false;
  }

  static bool _validateArrecadacaoBarcode(String barcode) {
    final int identificador = int.parse(barcode[2]);
    final int Function(String) algoritmo = _isMod10Arrecadacao(identificador)
        ? _mod10
        : _mod11Arrecadacao;

    final int dv = int.parse(barcode[3]);
    final String rest = barcode.substring(0, 3) + barcode.substring(4);
    return algoritmo(rest) == dv;
  }

  static bool _validateArrecadacaoLinha(String linha) {
    // 4 blocos de 11 dígitos + 1 DV cada (12 chars/bloco).
    // Bloco 1: linha[0..10] + DV em [11]
    // Bloco 2: linha[12..22] + DV em [23]
    // Bloco 3: linha[24..34] + DV em [35]
    // Bloco 4: linha[36..46] + DV em [47]
    final int identificador = int.parse(linha[2]);
    final int Function(String) algoritmo = _isMod10Arrecadacao(identificador)
        ? _mod10
        : _mod11Arrecadacao;

    for (int bloco = 0; bloco < 4; bloco++) {
      final int start = bloco * 12;
      final String dados = linha.substring(start, start + 11);
      final int dv = int.parse(linha[start + 11]);
      if (algoritmo(dados) != dv) return false;
    }
    return true;
  }

  /// Conforme layout FEBRABAN — 3º dígito do código de barras de
  /// arrecadação: `6`/`7` → mod-10; `8`/`9` → mod-11.
  static bool _isMod10Arrecadacao(int identificador) {
    return identificador == 6 || identificador == 7;
  }

  // --------------------------------------------------------------- módulos

  /// Módulo 10 — usado nos campos da linha digitável bancária e nos
  /// blocos da linha digitável de arrecadação que usam mod-10.
  ///
  /// Multiplica os dígitos da direita para a esquerda por 2,1,2,1…
  /// Se o produto for maior que 9, soma os dígitos do produto. O DV
  /// é o complemento de 10 da soma final (ou 0 quando o complemento
  /// dá 10).
  static int _mod10(String digits) {
    int sum = 0;
    int weight = 2;
    for (int i = digits.length - 1; i >= 0; i--) {
      int product = int.parse(digits[i]) * weight;
      if (product > 9) product = (product ~/ 10) + (product % 10);
      sum += product;
      weight = weight == 2 ? 1 : 2;
    }
    final int rem = sum % 10;
    return rem == 0 ? 0 : 10 - rem;
  }

  /// Módulo 11 do boleto bancário — multiplicadores 2..9 cíclicos da
  /// direita para a esquerda. Se o resto for 0, 10 ou 11, o DV é 1.
  static int _mod11Bancario(String digits) {
    int sum = 0;
    int weight = 2;
    for (int i = digits.length - 1; i >= 0; i--) {
      sum += int.parse(digits[i]) * weight;
      weight = weight == 9 ? 2 : weight + 1;
    }
    final int rem = sum % 11;
    final int dv = 11 - rem;
    if (dv == 0 || dv == 10 || dv == 11) return 1;
    return dv;
  }

  /// Módulo 11 do boleto de arrecadação — mesma multiplicação cíclica
  /// 2..9, mas DV é 0 quando o resto dá 0, 10 ou 11.
  static int _mod11Arrecadacao(String digits) {
    int sum = 0;
    int weight = 2;
    for (int i = digits.length - 1; i >= 0; i--) {
      sum += int.parse(digits[i]) * weight;
      weight = weight == 9 ? 2 : weight + 1;
    }
    final int rem = sum % 11;
    final int dv = 11 - rem;
    if (dv == 0 || dv == 10 || dv == 11) return 0;
    return dv;
  }
}
