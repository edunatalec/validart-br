# Changelog

## [1.1.0] - 2026-05-01

### Adicionado

- **Tradução pt-BR de `VStringCode.domain`** (novo em validart 2.1.0)
  → `'Domínio inválido'`. Sem essa entrada, `V.string().domain()` com
  `VLocaleBr.ptBr` aplicado caía no template inglês `'Invalid domain'`
  do core. Pinning em `test/src/locales/pt_br_test.dart`.
- **README ganhou o snippet `pubspec.yaml`** na seção `## Instalação`,
  pinando explicitamente `validart` e `validart_br` na versão atual —
  é o que o script de release verifica.

### Alterado

- Bump da dependência `validart` de `^2.0.0` para `^2.1.0`. Sem breaking
  changes — 2.1.0 é minor (novos `domain()`, `distinct(by:)`, `partial()`
  em `VObject`, `whenMatches`, `applyIf`, scheme-optional `url()`). O
  `validart_br` apenas absorve o novo código de erro.

## [1.0.0] - 2026-04-26

### Adicionado

- **`V.string().uf({mensagem})`** — valida sigla de UF brasileira
  (2 letras em caixa alta, dentre as 27 unidades federativas). Backed
  by `UfValidator` com a lista finita.
- **`V.string().codigoBanco({mensagem})`** — valida código de banco
  brasileiro (COMPE, 3 dígitos da tabela do Banco Central). Backed by
  `CodigoBancoValidator` com 497 instituições ativas. Não aceita
  formato com DV (`'001-9'`).
- **`V.string().ddd({mensagem})`** — valida DDD brasileiro isolado
  (2 dígitos da lista oficial Anatel, 67 códigos).
- **`V.string().boleto({formato, mensagem})`** — valida boleto
  brasileiro nas quatro formas: linha digitável bancária (47 dígitos),
  linha digitável de arrecadação (48 dígitos), código de barras
  bancário (44 dígitos) e código de barras de arrecadação (44 dígitos
  começando com `8`). Aceita máscara — qualquer caractere não numérico
  é descartado antes da validação. Use `formato: FormatoBoleto.bancario`
  ou `FormatoBoleto.arrecadacao` para restringir. DVs verificados:
  mod-10 nos campos 1, 2 e 3 da linha digitável bancária + mod-11 do
  DV geral; nos boletos de arrecadação, mod-10 ou mod-11 conforme o
  terceiro dígito do código de barras (`6`/`7` → mod-10, `8`/`9` →
  mod-11).
- **Códigos novos em `VStringCodeBr`**: `ufInvalida`,
  `codigoBancoInvalido`, `dddInvalido`, `boletoInvalido` —
  todos com tradução pt-BR no `VLocaleBr.ptBr`.
- **Enum `FormatoBoleto`** — `bancario` / `arrecadacao`. Re-exportado
  por `validart_br.dart`.
- **Enum `ModoValidacao`** — `qualquer` / `comMascara` / `semMascara`.
  Equivalente pt-BR do `ValidationMode` do core, usado pelos atalhos
  (`.cpf(modo: ModoValidacao.comMascara)`). Internamente cada atalho
  faz o depara para `ValidationMode` do core.

### Alterado (breaking — renomeação pt-BR)

**API pública dos atalhos 100% em pt-BR.** Todos os parâmetros que o
dev escreve passam a ser pt-BR (`modo`, `mensagem`, `alfanumerico`,
`tipos`, `formato`, `ddd`, `pais`, `apenasCelular`); internamente
cada atalho faz o depara para os parâmetros do core (`mode`,
`message`, `alphanumeric`, `allow`, `format`, `areaCode`,
`countryCode`, `mobileOnly`). As **classes** públicas (`CpfPattern`,
`CnpjPattern`, `TelefonePattern`, `BoletoValidator`,
`ChavePixValidator`, etc.) **mantêm os nomes em inglês** — seu uso
explícito é o ponto de extensão do core, então alinha com a
convenção do core.

**Atalhos de `VStringBr` renomeados:**

| Antes (v0.x)              | Agora (v1.0.0)             |
| ------------------------- | -------------------------- |
| `V.string().plate(...)`   | `V.string().placa(...)`    |
| `V.string().phoneBr(...)` | `V.string().telefone(...)` |
| `V.string().pixKey(...)`  | `V.string().chavePix(...)` |

Mantidos sem mudança: `cpf`, `cnpj`, `cep`, `pis`, `tituloEleitor`,
`cnh`, `renavam` (já estavam em pt-BR ou são siglas universais).

**Parâmetros dos atalhos renomeados (todos os 14 atalhos):**

| Antes           | Agora            | Aplica em                                        |
| --------------- | ---------------- | ------------------------------------------------ |
| `mode:`         | `modo:`          | `cpf`, `cnpj`, `cep`, `pis`, `placa`, `telefone` |
| `message:`      | `mensagem:`      | todos os 14 atalhos                              |
| `alphanumeric:` | `alfanumerico:`  | `cnpj`                                           |
| `format:`       | `formato:`       | `boleto`                                         |
| `allow:`        | `tipos:`         | `chavePix`                                       |
| `areaCode:`     | `ddd:`           | `telefone`                                       |
| `countryCode:`  | `pais:`          | `telefone`                                       |
| `mobileOnly:`   | `apenasCelular:` | `telefone`                                       |

**Valores de `ValidationMode` traduzidos via `ModoValidacao`:**

| `ValidationMode` (core) | `ModoValidacao` (atalhos) |
| ----------------------- | ------------------------- |
| `any`                   | `qualquer`                |
| `formatted`             | `comMascara`              |
| `unformatted`           | `semMascara`              |

A forma explícita via classe direta (`CpfPattern(mode: ValidationMode.formatted)`)
continua aceitando os nomes do core.

**Classes renomeadas:**

| Antes             | Agora               |
| ----------------- | ------------------- |
| `BrPlatePattern`  | `PlacaPattern`      |
| `BrPhonePattern`  | `TelefonePattern`   |
| `PixKeyValidator` | `ChavePixValidator` |

Patterns que são siglas (`CpfPattern`, `CnpjPattern`, `CepPattern`,
`PisPattern`, `CnhPattern`, `RenavamPattern`, `TituloEleitorPattern`)
mantêm o nome.

**Enums renomeados:**

| Antes            | Agora          |
| ---------------- | -------------- |
| `AreaCodeFormat` | `FormatoDdd`   |
| `PixKeyType`     | `TipoChavePix` |

Variantes de `TipoChavePix`: `phone` → `telefone`, `random` →
`aleatoria`. Demais (`cpf`, `cnpj`, `email`, `brCode`, `values`)
inalteradas.

**Códigos de erro em `VStringCodeBr`:**

| Antes           | Agora                                         |
| --------------- | --------------------------------------------- |
| `invalidPixKey` | `chavePixInvalida` (= `'chave_pix_invalida'`) |

As **strings** dos códigos também mudaram (não só os identificadores
Dart). Quem havia customizado o locale via `VLocaleBr.ptBrWith({...})`
ou montado um `VLocale` manual usando as constantes deste pacote
**continua funcionando** — basta usar as novas constantes. Quem
referenciava as strings hardcoded (`'invalid_pix_key'`) precisa trocar
pela nova (`'chave_pix_invalida'`).

**Arquivos renomeados** (lib + test + example):

- `lib/src/patterns/br_plate_pattern.dart` → `placa_pattern.dart`
- `lib/src/patterns/br_phone_pattern.dart` → `telefone_pattern.dart`
- `lib/src/validators/pix_key_validator.dart` → `chave_pix_validator.dart`

Quem usa `import 'package:validart_br/validart_br.dart'` (entrada
pública) **não é afetado** — o barrel re-exporta tudo. Imports
internos diretos (uso não recomendado) precisam ser ajustados.

### Alterado (dependências)

- Bump da dependência `validart` de `^1.3.0` para `^2.0.0`. Sem
  breaking changes na API do `validart_br` por causa do core: os
  patterns já usavam o contrato `patterns: [...]` (lista) introduzido
  em 1.3.0 e os códigos de erro continuam sendo as constantes
  (`VStringCode.taxId`, etc.); apenas a string emitida ganhou prefixo
  de domínio (`string.tax_id`), absorvido transparentemente pelo
  `pt_br.dart`.

### Corrigido

- **Tradução pt-BR de `VObjectCode.fieldsNotEqual` que ficava em
  inglês.** O validart 2.0.0 introduziu o código
  `'object.fields_not_equal'` para o novo
  `V.object<T>().equalFields()` (separado do `'map.fields_not_equal'`
  já existente), mas o `pt_br.dart` só mapeava a versão `Map`,
  fazendo a mensagem cair no default em inglês `'{field} must be
equal to {other}'`. Agora o `VObjectCode.fieldsNotEqual` traduz
  para `'{field} deve ser igual a {other}'`. Pinning em
  `test/src/locales/pt_br_test.dart`.

### Interno

- **Estilo de código padronizado em todo o pacote**: tipo explícito
  em variáveis locais quando o tipo é simples e estável (`final bool
matched = ...`, `final String digits = ...`, `final Random rng = ...`)
  e respiro (linhas em branco) entre blocos lógicos de funções.
  Aplicado em `lib/`, `test/` e `example/` — não afeta API pública.
- Cobertura de teste em **100%** (412/412 linhas), 300/300 testes
  passando, suite do core não regrediu.

### Guia de migração

Find-and-replace em sequência (ordem importa pra evitar duplos
matches):

```bash
# Variantes de PixKeyType primeiro (antes do catch-all):
sed -i '' \
  -e 's/PixKeyType\.phone/TipoChavePix.telefone/g' \
  -e 's/PixKeyType\.random/TipoChavePix.aleatoria/g' \
  -e 's/PixKeyType/TipoChavePix/g' \
  -e 's/AreaCodeFormat/FormatoDdd/g' \
  -e 's/BoletoFormat/FormatoBoleto/g' \
  -e 's/BrPhonePattern/TelefonePattern/g' \
  -e 's/BrPlatePattern/PlacaPattern/g' \
  -e 's/PixKeyValidator/ChavePixValidator/g' \
  -e 's/invalidPixKey/chavePixInvalida/g' \
  -e 's/\.pixKey(/.chavePix(/g' \
  -e 's/\.plate(/.placa(/g' \
  -e 's/\.phoneBr(/.telefone(/g' \
  $(find . -name '*.dart')

# Parâmetros dos atalhos para pt-BR (cuidado: aplicar SÓ nos atalhos
# da extension VString — chamadas diretas das classes patterns/
# validators continuam em inglês):
sed -i '' \
  -e 's/\(\.\(cpf\|cnpj\|cep\|pis\|placa\|telefone\|tituloEleitor\|cnh\|renavam\|chavePix\|uf\|codigoBanco\|ddd\|boleto\)(message:\)/\1\1/' \
  -e 's/\.\(cpf\|cnpj\|cep\|pis\|placa\|telefone\)(mode:/\.\1(modo:/g' \
  -e 's/\.cnpj(alphanumeric:/\.cnpj(alfanumerico:/g' \
  -e 's/\.boleto(format:/.boleto(formato:/g' \
  -e 's/\.chavePix(allow:/.chavePix(tipos:/g' \
  -e 's/\.telefone(areaCode:/.telefone(ddd:/g' \
  -e 's/\.telefone(countryCode:/.telefone(pais:/g' \
  -e 's/\.telefone(mobileOnly:/.telefone(apenasCelular:/g' \
  $(find . -name '*.dart')

# Valores de enum do core para pt-BR (apenas no contexto dos atalhos
# — chamadas diretas às classes mantêm ValidationMode/CountryCodeFormat):
sed -i '' \
  -e 's/modo: ValidationMode\.any/modo: ModoValidacao.qualquer/g' \
  -e 's/modo: ValidationMode\.formatted/modo: ModoValidacao.comMascara/g' \
  -e 's/modo: ValidationMode\.unformatted/modo: ModoValidacao.semMascara/g' \
  -e 's/pais: CountryCodeFormat\.required/pais: FormatoPais.obrigatorio/g' \
  -e 's/pais: CountryCodeFormat\.optional/pais: FormatoPais.opcional/g' \
  -e 's/pais: CountryCodeFormat\.none/pais: FormatoPais.nenhum/g' \
  -e 's/ddd: FormatoDdd\.required/ddd: FormatoDdd.obrigatorio/g' \
  -e 's/ddd: FormatoDdd\.optional/ddd: FormatoDdd.opcional/g' \
  -e 's/ddd: FormatoDdd\.none/ddd: FormatoDdd.nenhum/g' \
  $(find . -name '*.dart')
```

> **Nota:** o atalho `(message:` → `(mensagem:` é o sed que mais
> precisa de cuidado — `message:` aparece em qualquer chamada do core
> também (ex.: `V.string().email(message: ...)`). Faça caso-a-caso ou
> use o analyzer pra apontar o que falta após o sed agressivo.

## [0.1.0] - 2026-04-24

- Primeira versão. Requer `validart: ^1.3.0`.
- Patterns BR que plugam nos pontos de extensão do core:
  - `CpfPattern`, `CnpjPattern`, `PisPattern`, `TituloEleitorPattern`, `CnhPattern`, `RenavamPattern` → `TaxIdPattern`
  - `CepPattern` → `PostalCodePattern`
  - `BrPlatePattern` → `LicensePlatePattern`
  - `BrPhonePattern` → `PhonePattern`
- Métodos de atalho em `VString` (`cpf`, `cnpj`, `cep`, `pis`,
  `tituloEleitor`, `cnh`, `renavam`, `plate`, `phoneBr`) que delegam
  ao método equivalente do core com o pattern BR. A forma explícita
  usa `patterns: [...]` (lista) — ex.:
  `V.string().taxId(patterns: [const CpfPattern()])` — e permite
  compor múltiplos países na mesma validação.
- `CnpjPattern` aceita o novo formato alfanumérico da Receita
  (default); `alphanumeric: false` força o formato antigo.
- `PixKeyValidator` — validator composto que aceita qualquer
  identificador PIX. Um parâmetro `allow: List<PixKeyType>` controla
  os tipos aceitos. Por padrão aceita as cinco chaves do DICT (CPF,
  CNPJ, e-mail, telefone `+55…`, UUID v4). Inclua `PixKeyType.brCode`
  em `tipos` para também aceitar o BR Code (payload EMVCo do QR
  Code), validado estritamente — estrutura TLV, CRC16-CCITT-FALSE
  e campos obrigatórios do Bacen.
- `VLocaleBr.ptBr` traduz todas as mensagens do core do validart
  (incluindo `tax_id`, `postal_code`, `license_plate` com `{name}`
  e `invalid_phone` do `BrPhonePattern`) + `VStringCodeBr.invalidPixKey`.
- `ValidationMode` e `CountryCodeFormat` são re-exportados do core
  — `import 'package:validart_br/validart_br.dart'` basta.
