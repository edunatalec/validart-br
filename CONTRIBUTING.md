# Contribuindo

Obrigado pelo tempo. Este documento é o contrato de quem escreve código aqui — o
`README.md` é o contrato de quem usa o `validart_br`.

## Antes de abrir um PR

Um comando precisa estar verde:

```bash
./scripts/verify.sh
```

É o mesmo script que o release roda, menos tag, push e publish: dependências, os dois pins
de versão do README, analyze, testes, `example/example.dart`, os exemplos dentro dos `///`,
`dart doc` com zero warnings, o dry-run do publish e um score pana de 160/160. Se passa
local, passa no CI — o CI roda esse arquivo e mais nada.

Ele precisa de rede (pergunta ao pub.dev qual versão da pana usar) e de um Dart igual ou
acima do floor declarado no `pubspec.yaml`. Rodá-lo troca a sua pana ativada globalmente —
o pub.dev sempre pontua com a mais nova, então o script instala exatamente ela.

O check de pin cobre **duas** linhas do bloco `## Instalação`: `validart_br` tem que bater
com o `version:` do `pubspec.yaml`, e `validart` tem que bater com a constraint da
dependência. Um pacote de extensão que anuncia a versão errada do core quebra o `pub get`
de quem copia o bloco.

## O que o CI verifica

Dois jobs, em todo pull request:

- **Verify** — `./scripts/verify.sh` no Dart estável.
- **Floor** — analyze e testes no **menor** Dart que o pacote suporta, lido direto do
  `pubspec.yaml`. Num pacote Dart-only esse job vale menos do que num pacote Flutter: o SDK
  do Dart anota `@Since`, então o analyzer do topo já emite warning e o gate já falha. O que
  sobra para ele pegar ainda justifica os ~2 minutos — API sem anotação, resolução de
  dependências no floor (uma dev dependency nova costuma exigir um SDK mais recente do que o
  que prometemos) e comportamento em runtime.

## Convenções

- **Nada de comentário `//`.** Um fato que precisa ficar registrado vai para a mensagem de
  commit, para este documento ou para um teste. Diretivas do analyzer (`// ignore:`) não são
  comentário e podem ficar.
- **`///` é obrigatório em todo membro público**, com exemplo executável.
  `public_member_api_docs` está ligado, e `scripts/verify_doc_examples.sh` compila todo
  bloco ```dart encontrado em `lib/`.
- **A prosa dos `///` deste pacote é em pt-BR**, ao contrário dos outros pacotes publicados.
  O público é brasileiro. Identificadores, nomes de parâmetro e mensagens de commit seguem
  em inglês.
- **Mudança de comportamento vem com o teste dela.** Correção de bug começa vermelha:
  escreva o teste que falha, veja falhar pelo motivo certo, e só então corrija.
- **Todo arquivo de teste reseta o locale** em `setUp(() => V.setLocale(const VLocale()))`.
  `V` é estático: o locale que um teste define vaza para o próximo do mesmo arquivo. O
  sintoma é uma asserção de locale padrão (`'Invalid CPF'`) que começa a falhar de forma
  intermitente conforme o arquivo cresce, mas passa isolada. Arquivos focados em locale são
  a exceção — eles setam pt-BR no `setUp` e resetam no `tearDown`.
- **Fixtures de checksum são reais, nunca saída de gerador.** Os boletos de
  `test/src/validators/boleto_validator_test.dart` foram conferidos contra a suite do
  `mcrvaz/boleto-brasileiro-validator`. Um documento novo com dígito verificador precisa do
  mesmo tratamento: cruze com pelo menos uma implementação independente antes de commitar.
- **Os testes de fuzz têm tag própria.** `dart test -t fuzz` roda só eles, `dart test -x
  fuzz` roda o resto. A seed é fixa em `kFuzzSeed` para a falha ser reproduzível; para
  varrer outro espaço enquanto caça uma regressão, edite a constante — `dart test` não
  repassa `--define`, então o `FUZZ_SEED` que `envSeed()` lê nunca chega pela linha de
  comando.
- **Mudança na API pública atualiza README, CHANGELOG e `example/` no mesmo commit.**
- **Commits são convencionais e em minúscula**: `feat:`, `fix:`, `chore:`, `docs:`. Sem
  corpo, sem trailer de co-autoria.

## Decisões que um PR não deve "corrigir"

São ausências por decisão, não por esquecimento.

- **Nenhum código de erro por documento.** CPF, CNPJ, PIS, título de eleitor, CNH e Renavam
  emitem `VStringCode.taxId`; CEP emite `VStringCode.postalCode`; placa emite
  `VStringCode.licensePlate`; telefone emite `VStringCode.phone`. O que distingue um do
  outro é a interpolação de `{name}`, que vem da propriedade `name` do pattern — é assim que
  o ponto de extensão do core foi desenhado, e é o que permite compor patterns de vários
  países na mesma validação. Os códigos de `VStringCodeBr` existem só para os validadores
  que não cabem em nenhum abstract do core.
- **As classes mantêm nomes em inglês.** `CpfPattern(mode:)`, `BoletoValidator(format:)`,
  `ChavePixValidator(allow:)`, `TelefonePattern(areaCode:, countryCode:, mobileOnly:)`. Elas
  são o ponto de extensão do core, e o core é em inglês. A camada pt-BR (`modo`, `mensagem`,
  `formato`, `tipos`, `ddd`, `pais`, `apenasCelular`) mora nos atalhos de
  `VStringBr`, que fazem o depara internamente.
- **`CodigoBancoValidator` não aceita o formato com dígito verificador** (`'001-9'`). A
  tabela COMPE tem 3 dígitos; quem recebe 4 extrai os três primeiros antes de validar.
- **`lib/src/string_utils.dart` não é exportado.** `.onlyDigits` e `.isRepeatedCharacters`
  são utilitários internos, e expô-los criaria superfície pública que este pacote não quer
  manter.

## Release

Releases são cortados pelo mantenedor, a partir de `master`, com `./scripts/release.sh`.
Nada publica a partir do CI.
