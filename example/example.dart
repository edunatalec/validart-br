// Aggregator entry-point — roda cada arquivo de `validators/` e
// `features/` em sequência. Cada arquivo é também runnable standalone
// (todos têm seu próprio `main()`), então este aggregator é só uma
// conveniência para `dart run example/example.dart`.
//
// Layout:
//   example/validators/<documento>.dart  — um arquivo por validador BR
//   example/features/<feature>.dart      — locale, composition, patterns
//   example/shared/fixtures.dart         — boletos válidos, BR Codes,
//                                          helper section()

import 'features/composition.dart';
import 'features/locale.dart';
import 'features/patterns.dart';
import 'validators/bank_code.dart';
import 'validators/boleto.dart';
import 'validators/cep.dart';
import 'validators/cnh.dart';
import 'validators/cnpj.dart';
import 'validators/cpf.dart';
import 'validators/ddd.dart';
import 'validators/phone_br.dart';
import 'validators/pis.dart';
import 'validators/pix_key.dart';
import 'validators/plate.dart';
import 'validators/renavam.dart';
import 'validators/state.dart';
import 'validators/titulo_eleitor.dart';

void main() {
  print('=== Validadores ===');
  runCpfExamples();
  runCnpjExamples();
  runCepExamples();
  runPisExamples();
  runTituloEleitorExamples();
  runCnhExamples();
  runRenavamExamples();
  runPhoneBrExamples();
  runPlateExamples();
  runPixKeyExamples();
  runStateExamples();
  runBankCodeExamples();
  runDddExamples();
  runBoletoExamples();

  print('\n=== Features ===');
  runLocaleExamples();
  runPatternsExamples();
  runCompositionExamples();
}
