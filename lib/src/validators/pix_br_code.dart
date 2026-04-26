/// Validação do payload EMVCo de QR Code PIX ("BR Code" / "copia e
/// cola"). Uso interno pelo `ChavePixValidator`.
///
/// A validação é **estrita** (padrão de mercado): estrutura TLV
/// completa, CRC16-CCITT-FALSE batendo, e campos obrigatórios do Bacen
/// (moeda BRL, país BR, GUID `br.gov.bcb.pix`).
sealed class PixBrCode {
  /// Retorna `true` se [value] é um BR Code PIX válido.
  static bool isValid(String value) {
    // Sanity + ponto inicial fixo: Payload Format Indicator = "01".
    if (value.length < 24) return false;
    if (!value.startsWith('000201')) return false;

    // CRC fica sempre nos últimos 8 chars no formato "6304XXXX".
    if (value.length < 8) return false;
    final crcTagStart = value.length - 8;
    if (value.substring(crcTagStart, crcTagStart + 4) != '6304') return false;

    final declared = value.substring(crcTagStart + 4).toUpperCase();
    if (!_hex4Regex.hasMatch(declared)) return false;

    final expected = _crc16CcittFalse(
      value.substring(0, crcTagStart + 4),
    ).toRadixString(16).toUpperCase().padLeft(4, '0');
    if (declared != expected) return false;

    final fields = _parseTlv(value);
    if (fields == null) return false;

    final byId = <String, String>{};
    for (final f in fields) {
      byId[f.$1] = f.$2;
    }

    // Campos obrigatórios EMVCo + PIX.
    if (byId['00'] != '01') return false;
    if (byId['53'] != '986') return false; // BRL
    if ((byId['58'] ?? '').toUpperCase() != 'BR') return false;
    if (byId['52'] == null) return false; // MCC
    if (byId['59'] == null) return false; // Merchant name
    if (byId['60'] == null) return false; // Merchant city

    // Pelo menos um Merchant Account Info (26..51) com GUID do PIX.
    bool hasPixMerchant = false;
    for (final (id, val) in fields) {
      final idInt = int.tryParse(id);
      if (idInt == null || idInt < 26 || idInt > 51) continue;
      final sub = _parseTlv(val);
      if (sub == null) continue;
      for (final s in sub) {
        if (s.$1 == '00' && s.$2.toLowerCase() == 'br.gov.bcb.pix') {
          hasPixMerchant = true;
          break;
        }
      }

      if (hasPixMerchant) break;
    }

    return hasPixMerchant;
  }

  static final RegExp _hex4Regex = RegExp(r'^[0-9A-F]{4}$');

  /// Parse TLV (Tag-Length-Value) EMVCo: `IIll<value>` repetido.
  /// Retorna `null` se a estrutura estiver corrompida.
  static List<(String, String)>? _parseTlv(String s) {
    final out = <(String, String)>[];

    int i = 0;
    while (i < s.length) {
      if (i + 4 > s.length) return null;
      final id = s.substring(i, i + 2);
      final lenStr = s.substring(i + 2, i + 4);
      final len = int.tryParse(lenStr);
      if (len == null || len < 0) return null;
      final valueStart = i + 4;
      final valueEnd = valueStart + len;
      if (valueEnd > s.length) return null;
      out.add((id, s.substring(valueStart, valueEnd)));
      i = valueEnd;
    }

    return out;
  }

  /// CRC16-CCITT-FALSE (poly 0x1021, init 0xFFFF, sem reflexão) — o
  /// algoritmo exigido pelo EMVCo/Bacen para o campo 63 do BR Code.
  static int _crc16CcittFalse(String data) {
    int crc = 0xFFFF;
    for (final byte in data.codeUnits) {
      crc ^= (byte & 0xFF) << 8;
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }

    return crc;
  }
}
