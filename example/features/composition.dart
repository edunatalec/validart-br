import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

import '../shared/fixtures.dart';

/// Exemplos de composição — schemas com vários validadores BR
/// combinados em `V.map(...)` ou `V.object<T>()`, mensagens em pt-BR
/// agregadas por campo.
void runCompositionExamples() {
  V.setLocale(VLocaleBr.ptBr);

  section('V.map — cadastro com múltiplos validadores BR');

  final VMap usuario = V.map({
    'nome': V.string().min(3).max(120),
    'cpf': V.string().cpf(),
    'email': V.string().email(),
    'celular': V.string().telefone(apenasCelular: true),
    'cep': V.string().cep(),
    'uf': V.string().toUpperCase().uf(),
    'banco': V.string().codigoBanco(),
  });

  final VResult<Map<String, dynamic>?> result = usuario.safeParse({
    'nome': 'Maria',
    'cpf': '123.456.789-09',
    'email': 'maria@example.com',
    'celular': '11987654321',
    'cep': '01001-000',
    'uf': 'sp',
    'banco': '260',
  });

  switch (result) {
    case VSuccess(:final value):
      print('Cadastro válido: $value');
    case VFailure(:final errors):
      print('Erros:');
      for (final e in errors) {
        print('  ${e.pathString}: ${e.message}');
      }
  }

  section('V.map — erros agregados por campo');

  final VResult<Map<String, dynamic>?> ruim = usuario.safeParse({
    'nome': 'A',
    'cpf': '000.000.000-00',
    'email': 'invalido',
    'celular': 'xxx',
    'cep': '0',
    'uf': 'XY',
    'banco': '999',
  });

  if (ruim case VFailure(:final errors)) {
    final Map<String, String> map = (ruim).toMap();

    for (final MapEntry<String, String> entry in map.entries) {
      print('  ${entry.key}: ${entry.value}');
    }

    print('total de erros: ${errors.length}');
  }

  V.setLocale(const VLocale());
}

void main() => runCompositionExamples();
