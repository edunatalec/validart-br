import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';

void main() {
  // Aplica as traduções pt-BR do core e dos validadores BR.
  V.setLocale(VLocaleBr.ptBr);

  // --- Duas formas equivalentes de uso ---
  // 1. Atalho da extension VStringBr
  V.string().cpf();
  // 2. Forma explícita via pattern plugável do core
  V.string().taxId(patterns: [const CpfPattern()]);

  // CPF
  final cpf = V.string().trim().cpf();
  print('CPF válido?   ${cpf.validate('123.456.789-09')}'); // true
  print('CPF inválido: ${cpf.errors('111.111.111-11')?.first.message}');
  //                                                           -> CPF inválido

  // CNPJ (default aceita novo formato alfanumérico da Receita)
  print(
    'CNPJ alfanum: ${V.string().cnpj().validate('12ABC34501DE35')}',
  ); // true
  print(
    'CNPJ numérico: ${V.string().cnpj(alphanumeric: false).validate('12345678000195')}',
  ); // true

  // CEP
  final cep = V.string().cep();
  print('CEP: ${cep.validate('01001-000')}'); // true

  // Telefone — atalho phoneBr() ou phone(patterns:)
  final tel = V.string().phoneBr(
    countryCode: CountryCodeFormat.required,
    areaCode: AreaCodeFormat.required,
    mobileOnly: true,
  );
  print('Telefone: ${tel.validate('+55 (11) 98765-4321')}'); // true

  // Chave PIX — default aceita as cinco chaves do DICT
  final pix = V.string().pixKey();
  print('PIX CPF:    ${pix.validate('12345678909')}'); // true
  print('PIX e-mail: ${pix.validate('user@example.com.br')}'); // true
  print('PIX tel:    ${pix.validate('+5511987654321')}'); // true
  print(
    'PIX UUID:   ${pix.validate('123e4567-e89b-12d3-a456-426614174000')}',
  ); // true

  // PIX restrito: só e-mail ou telefone
  final pixEmailOuTel = V.string().pixKey(
    allow: const [PixKeyType.email, PixKeyType.phone],
  );
  print('PIX restrito aceita CPF? ${pixEmailOuTel.validate('12345678909')}');
  // -> false

  // PIX aceitando BR Code do QR Code ("copia e cola"); CRC16 obrigatório.
  final pixCompleto = V.string().pixKey(allow: PixKeyType.values);
  const brCode =
      '00020126580014br.gov.bcb.pix0136123e4567-e89b-12d3-a456-42661417400052040000530398654041.005802BR5913Fulano de Tal6009Sao Paulo62070503***63046982';
  print('PIX BR Code: ${pixCompleto.validate(brCode)}'); // true

  // Placa (antiga e Mercosul, encadeia com toUpperCase)
  final placa = V.string().toUpperCase().plate();
  print('Placa antiga:   ${placa.validate('abc-1234')}'); // true
  print('Placa Mercosul: ${placa.validate('abc1d23')}'); // true

  // Schema de cadastro
  final usuario = V.map({
    'nome': V.string().min(3).max(120),
    'cpf': V.string().cpf(),
    'email': V.string().email(),
    'celular': V.string().phoneBr(mobileOnly: true),
    'cep': V.string().cep(),
  });

  final result = usuario.safeParse({
    'nome': 'Maria',
    'cpf': '123.456.789-09',
    'email': 'maria@example.com',
    'celular': '11987654321',
    'cep': '01001-000',
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
}
