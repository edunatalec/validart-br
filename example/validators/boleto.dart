import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import '../shared/fixtures.dart';

/// Exemplos de `V.string().boleto()` — boleto bancário ou de
/// arrecadação, em linha digitável (47/48 dígitos) ou código de
/// barras (44 dígitos). Aceita máscara — qualquer caractere não
/// numérico é descartado antes da validação.
void runBoletoExamples() {
  section('Boleto bancário — linha digitável e código de barras');

  print(V.string().boleto().validate(kBoletoBancarioLinha)); // true
  print(V.string().boleto().validate(kBoletoBancarioLinhaFormatada)); // true
  print(V.string().boleto().validate(kBoletoBancarioBarras)); // true

  section('Boleto de arrecadação — mod-10 e mod-11');

  print(V.string().boleto().validate(kBoletoArrecadacaoLinhaMod10)); // true
  print(V.string().boleto().validate(kBoletoArrecadacaoLinhaMod11)); // true

  section('Boleto — restrição via [format]');

  // format pin'a o tipo aceito.
  final soBancario = V.string().boleto(format: BoletoFormat.bancario);
  print(soBancario.validate(kBoletoBancarioLinha)); // true
  print(soBancario.validate(kBoletoArrecadacaoLinhaMod10)); // false

  final soArrecadacao = V.string().boleto(format: BoletoFormat.arrecadacao);
  print(soArrecadacao.validate(kBoletoArrecadacaoLinhaMod11)); // true
  print(soArrecadacao.validate(kBoletoBancarioLinha)); // false
}

void main() => runBoletoExamples();
