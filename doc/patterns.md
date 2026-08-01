Os documentos brasileiros plugados nos pontos de extensão do core.

Cada pattern implementa uma interface do validart — `taxId`, `postalCode`,
`licensePlate` ou `phone` — e é passado numa lista, então documentos de países
diferentes convivem na mesma validação: `V.string().taxId(patterns: [const
CpfPattern(), const SsnPattern()])` aceita os dois.

O pattern é `const` e carrega o dígito verificador do documento, não só o
formato: `CpfPattern` recusa `111.111.111-11` mesmo com a máscara correta.
