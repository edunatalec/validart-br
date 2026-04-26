/// Fixtures e helpers compartilhados pelos exemplos do `validart_br`.
///
/// Cada arquivo em `validators/` e `features/` importa este aqui para
/// reutilizar boletos válidos, BR Codes do PIX e o helper de seção
/// que dá uma estrutura visual consistente ao output.
library;

/// Helper que imprime um cabeçalho de seção. Mantém o output dos
/// exemplos visualmente consistente quando rodados standalone ou via
/// o aggregator em `example.dart`.
void section(String name) {
  print('\n--- $name ---');
}

// --- Boletos -------------------------------------------------------------

/// Boleto bancário válido — linha digitável (47 dígitos sem máscara).
/// Origem: vetor de teste do `mcrvaz/boleto-brasileiro-validator`.
const String kBoletoBancarioLinha =
    '23793381286000782713695000063305975520000370000';

/// Mesmo boleto da [kBoletoBancarioLinha], mas formatado com pontos
/// e espaços como aparece em representações impressas.
const String kBoletoBancarioLinhaFormatada =
    '23793.38128 60007.827136 95000.063305 9 75520000370000';

/// Boleto bancário válido — código de barras (44 dígitos).
const String kBoletoBancarioBarras =
    '00193373700000001000500940144816060680935031';

/// Boleto de arrecadação válido com DVs em mod-10 (3º dígito = `6`).
/// Linha digitável de 48 dígitos.
const String kBoletoArrecadacaoLinhaMod10 =
    '836200000005667800481000180975657313001589636081';

/// Boleto de arrecadação válido com DVs em mod-11 (3º dígito = `8`).
/// Linha digitável de 48 dígitos.
const String kBoletoArrecadacaoLinhaMod11 =
    '848900000002404201622015806051904292586034111220';

// --- BR Codes do PIX -----------------------------------------------------

/// BR Code estático com chave UUID e valor (R$ 1,00). CRC16 batendo,
/// campos obrigatórios do Bacen presentes (moeda 986, país BR, GUID
/// `br.gov.bcb.pix`).
const String kPixBrCodeUuid =
    '00020126580014br.gov.bcb.pix0136123e4567-e89b-12d3-a456-42661417400052040000530398654041.005802BR5913Fulano de Tal6009Sao Paulo62070503***63046982';

/// BR Code estático com chave de e-mail.
const String kPixBrCodeEmail =
    '00020126430014br.gov.bcb.pix0121fulano@example.com.br5204000053039865802BR5913Fulano de Tal6009Sao Paulo62070503***63048EB4';
