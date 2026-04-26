import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import '../shared/fixtures.dart';

/// Exemplos do locale pt-BR — `VLocaleBr.ptBr`, `ptBrWith()` para
/// overrides pontuais e acesso direto aos mapas (`coreMessages`,
/// `brMessages`, `messages`).
void runLocaleExamples() {
  section('VLocaleBr.ptBr — pronto pra usar');

  V.setLocale(VLocaleBr.ptBr);

  // Mensagens do core do validart.
  print(V.string().email().errors('x')!.first.message); // 'E-mail inválido'
  print(
    V.string().min(3).errors('a')!.first.message,
  ); // 'Deve ter no mínimo 3 caracteres'

  // Patterns BR (interpolação de {name}).
  print(V.string().cpf().errors('xxx')!.first.message); // 'CPF inválido'
  print(V.string().cnpj().errors('xxx')!.first.message); // 'CNPJ inválido'
  print(V.string().placa().errors('xxx')!.first.message); // 'Placa inválida'

  // Códigos exclusivos do validart_br.
  print(
    V.string().chavePix().errors('x')!.first.message,
  ); // 'Chave PIX inválida'
  print(V.string().uf().errors('XY')!.first.message); // 'UF inválida'
  print(V.string().boleto().errors('x')!.first.message); // 'Boleto inválido'

  section('VLocaleBr.ptBrWith — overrides pontuais');

  V.setLocale(
    VLocaleBr.ptBrWith({
      VCode.required: 'Obrigatório',
      VStringCode.taxId: '{name} fora do padrão',
    }),
  );

  print(V.string().errors(null)!.first.message); // 'Obrigatório'
  print(
    V.string().cpf().errors('111.111.111-11')!.first.message,
  ); // 'CPF fora do padrão'

  section('Override por chamada — útil pra gênero gramatical');

  V.setLocale(VLocaleBr.ptBr);
  // "CNH inválido" (default masculino) → "CNH inválida" (feminino).
  print(
    V.string().cnh(message: 'CNH inválida').errors('x')!.first.message,
  ); // 'CNH inválida'

  V.setLocale(const VLocale());
}

void main() => runLocaleExamples();
