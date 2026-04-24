# Validart BR

[![pub package](https://img.shields.io/pub/v/validart_br.svg)](https://pub.dev/packages/validart_br)
[![package publisher](https://img.shields.io/pub/publisher/validart_br.svg)](https://pub.dev/packages/validart_br/publisher)

Extensão do [validart](https://pub.dev/packages/validart) com validadores brasileiros
e locale `pt-BR`.

Validadores implementados como **patterns** dos pontos de extensão do core — mesma
API que qualquer outro país. Traz também um `VLocale` pt-BR completo (cobre todas
as mensagens do core + as deste pacote) e métodos de atalho para reduzir o verbosismo
em código BR-only.

## Sumário

- [Instalação](#instalação)
- [Uso básico](#uso-básico)
- [Validadores](#validadores)
  - [CPF](#cpf)
  - [CNPJ](#cnpj)
  - [CEP](#cep)
  - [PIS/PASEP](#pispasep)
  - [Título de eleitor](#título-de-eleitor)
  - [CNH](#cnh)
  - [Renavam](#renavam)
  - [Telefone brasileiro](#telefone-brasileiro)
  - [Placa](#placa)
  - [Chave PIX](#chave-pix)
- [Duas formas equivalentes](#duas-formas-equivalentes)
- [`ValidationMode`](#validationmode)
- [Locale pt-BR](#locale-pt-br)
  - [Override de mensagens](#override-de-mensagens)
  - [Códigos de erro](#códigos-de-erro)
- [Extensibilidade](#extensibilidade)
  - [Escrevendo um pattern novo](#escrevendo-um-pattern-novo)
- [Exemplo completo](#exemplo-completo)
- [Licença](#licença)

## Instalação

```sh
dart pub add validart validart_br
```

```dart
import 'package:validart/validart.dart';
import 'package:validart_br/validart_br.dart';
```

## Uso básico

```dart
// Aplica as traduções pt-BR do core + validart_br
V.setLocale(VLocaleBr.ptBr);

final schema = V.string().trim().cpf();

schema.validate('123.456.789-09'); // true
schema.validate('111.111.111-11'); // false

schema.errors('000.000.000-00')?.first.message; // 'CPF inválido'

// parse — lança ao falhar
schema.parse('123.456.789-09'); // '123.456.789-09'

// safeParse — nunca lança
final result = schema.safeParse('000.000.000-00');
if (result case VFailure(:final errors)) {
  print(errors.first.message); // 'CPF inválido'
}
```

## Validadores

| Método                                | Descrição                                                                             |
| ------------------------------------- | ------------------------------------------------------------------------------------- |
| `cpf({mode, message})`                | CPF (11 dígitos). `mode` controla se aceita máscara.                                  |
| `cnpj({mode, alphanumeric, message})` | CNPJ. Default aceita o novo formato alfanumérico da Receita.                          |
| `cep({mode, message})`                | CEP (8 dígitos).                                                                      |
| `pis({mode, message})`                | PIS/PASEP/NIS (11 dígitos).                                                           |
| `tituloEleitor({message})`            | Título de eleitor (12 dígitos, UF `01–28`).                                           |
| `cnh({message})`                      | CNH (11 dígitos).                                                                     |
| `renavam({message})`                  | Renavam (11 dígitos).                                                                 |
| `phoneBr({…})`                        | Telefone BR com flags de DDD, DDI, `mobileOnly` e `mode`.                             |
| `plate({mode, message})`              | Placa — formato antigo (`AAA-9999`) ou Mercosul (`AAA9A99`).                          |
| `pixKey({allow, message})`            | Identificador PIX — chaves do DICT e/ou BR Code. `allow` restringe os tipos aceitos.  |

### CPF

```dart
V.string().cpf().validate('123.456.789-09'); // true
V.string().cpf().validate('11111111111');    // false (repetido)

V.string().cpf(mode: ValidationMode.unformatted)
  .validate('12345678909'); // true
```

### CNPJ

A partir de julho/2026 a Receita Federal emite CNPJs alfanuméricos: os
12 primeiros caracteres podem ser `[0-9A-Z]` e os 2 últimos (DVs)
continuam numéricos. `validart_br` **aceita esse formato por padrão** e
continua validando os CNPJs puramente numéricos existentes — dígitos são
subconjunto do alfanumérico.

```dart
V.string().cnpj().validate('12.345.678/0001-95'); // true (numérico)
V.string().cnpj().validate('12.ABC.345/01DE-35'); // true (alfanumérico)

V.string().cnpj(alphanumeric: false)
  .validate('12.ABC.345/01DE-35'); // false — só dígitos
```

Letras devem vir em caixa alta. Se o input pode vir com minúsculas,
encadeie `.toUpperCase()` antes (mesma regra para `plate()`):

```dart
V.string().toUpperCase().cnpj();
V.string().toUpperCase().plate();
```

### CEP

```dart
V.string().cep().validate('01001-000'); // true
V.string().cep().validate('01001000');  // true
V.string().cep().validate('0100100');   // false
```

### PIS/PASEP

```dart
V.string().pis().validate('120.54789.01-3'); // true
V.string().pis().validate('12054789013');    // true
```

### Título de eleitor

```dart
V.string().tituloEleitor().validate('876543210329'); // true
V.string().tituloEleitor().validate('123456780099'); // false (UF 00)
```

### CNH

```dart
V.string().cnh().validate('12345678900'); // true
V.string().cnh().validate('00000000000'); // false
```

### Renavam

```dart
V.string().renavam().validate('12345678900'); // true
```

### Telefone brasileiro

Aceita celular (9 dígitos iniciando com `9`) e fixo (8 dígitos), com ou
sem DDD e DDI. Use os parâmetros para restringir a forma.

```dart
V.string().phoneBr().validate('(11) 98765-4321'); // true
V.string().phoneBr().validate('11987654321');     // true
V.string().phoneBr().validate('+55 11 98765-4321'); // true

V.string().phoneBr(
  countryCode: CountryCodeFormat.required, // exige +55
  areaCode: AreaCodeFormat.required,       // exige DDD
  mobileOnly: true,                        // só celular
  mode: ValidationMode.formatted,          // exige separadores
).validate('+55 (11) 98765-4321'); // true
```

### Placa

Aceita formato antigo (`AAA-9999` / `AAA9999`) e Mercosul (`AAA9A99`).
Letras devem estar em caixa alta — encadeie `.toUpperCase()` quando o
input pode vir minúsculo.

```dart
V.string().plate().validate('ABC-1234'); // true (antiga)
V.string().plate().validate('ABC1D23');  // true (Mercosul)

V.string().toUpperCase().plate().validate('abc-1234'); // true
```

### Chave PIX

`pixKey()` aceita por padrão as cinco chaves do DICT:

- **CPF** (11 dígitos, sem máscara)
- **CNPJ** (14 dígitos, só numérico, sem máscara)
- **E-mail**
- **Telefone** em E.164 com `+55` e celular (`+55DDDNNNNNNNNN`)
- **UUID v4** (chave aleatória)

Cada formato é checado no modo estrito exigido pelo PIX.

```dart
V.string().pixKey().validate('12345678909');                        // true (CPF)
V.string().pixKey().validate('user@example.com');                   // true (e-mail)
V.string().pixKey().validate('+5511987654321');                     // true (telefone)
V.string().pixKey().validate('123e4567-e89b-12d3-a456-426614174000'); // true (UUID)
```

Restrinja os tipos aceitos com `allow`:

```dart
V.string().pixKey(allow: const [PixKeyType.email, PixKeyType.phone]);
// rejeita CPF, CNPJ e UUID
```

Inclua `PixKeyType.brCode` para também aceitar o **BR Code** — payload
EMVCo do QR Code PIX ("copia e cola"). A validação segue o padrão de
mercado (estrito): estrutura TLV, CRC16-CCITT-FALSE batendo e campos
obrigatórios do Bacen (moeda `986`, país `BR`, GUID `br.gov.bcb.pix`).

```dart
// Aceita os 5 tipos de chave + BR Code:
V.string().pixKey(allow: PixKeyType.values);

// Só BR Code:
V.string().pixKey(allow: const [PixKeyType.brCode]);
```

## Duas formas equivalentes

Cada validador BR tem duas formas de uso, ambas sempre equivalentes:

| Atalho                       | Forma explícita via pattern do core                              |
| ---------------------------- | ---------------------------------------------------------------- |
| `V.string().cpf()`           | `V.string().taxId(patterns: [const CpfPattern()])`               |
| `V.string().cnpj()`          | `V.string().taxId(patterns: [const CnpjPattern()])`              |
| `V.string().pis()`           | `V.string().taxId(patterns: [const PisPattern()])`               |
| `V.string().tituloEleitor()` | `V.string().taxId(patterns: [const TituloEleitorPattern()])`     |
| `V.string().cnh()`           | `V.string().taxId(patterns: [const CnhPattern()])`               |
| `V.string().renavam()`       | `V.string().taxId(patterns: [const RenavamPattern()])`           |
| `V.string().cep()`           | `V.string().postalCode(patterns: [const CepPattern()])`          |
| `V.string().plate()`         | `V.string().licensePlate(patterns: [const BrPlatePattern()])`    |
| `V.string().phoneBr()`       | `V.string().phone(patterns: [const BrPhonePattern()])`           |

Use os atalhos em código BR-only (mais legível). Use os patterns
explícitos quando precisar compor múltiplos países na mesma validação:

```dart
V.string().taxId(patterns: [const CpfPattern(), const UsSsnPattern()]);
// aceita CPF brasileiro OU Social Security Number americano
```

## `ValidationMode`

Validadores com máscara aceitam `ValidationMode` para controlar a forma:

```dart
V.string().cpf(mode: ValidationMode.any);         // default: com ou sem máscara
V.string().cpf(mode: ValidationMode.formatted);   // só com máscara
V.string().cpf(mode: ValidationMode.unformatted); // só dígitos
```

Aplica-se a `cpf`, `cnpj`, `cep`, `pis`, `plate` e `phoneBr`.

## Locale pt-BR

`VLocaleBr.ptBr` traduz **todas** as mensagens do core do validart mais
os códigos específicos do `validart_br`:

```dart
V.setLocale(VLocaleBr.ptBr);

V.string().email().errors('x')?.first.message;
// 'E-mail inválido'

V.string().cpf().errors('000.000.000-00')?.first.message;
// 'CPF inválido'

V.string().min(3).errors('a')?.first.message;
// 'Deve ter no mínimo 3 caracteres'
```

Duas formas de aplicar:

```dart
// 1. Pronto para uso (core + BR):
V.setLocale(VLocaleBr.ptBr);

// 2. Override pontual:
V.setLocale(VLocaleBr.ptBrWith({
  VCode.required: 'Obrigatório',
  VStringCode.taxId: '{name} fora do padrão',
}));
```

Se precisar de acesso aos mapas brutos (ex.: compor com mensagens de
outro pacote), use `VLocaleBr.coreMessages`, `VLocaleBr.brMessages` e
`VLocaleBr.messages` (união das duas).

### Override de mensagens

Override global (via locale) afeta todos os validadores que emitem o código:

```dart
V.setLocale(VLocaleBr.ptBrWith({
  VStringCode.taxId: '{name} fora do padrão', // CPF/CNPJ/PIS/CNH/…
}));
```

Override por chamada (via parâmetro `message`) sobrescreve só aquela
instância — útil quando o gênero gramatical da mensagem importa:

```dart
V.string().cnh(message: 'CNH inválida');   // força feminino só aqui
V.string().plate(message: 'Placa não reconhecida');
```

### Códigos de erro

Os patterns plugáveis do core usam códigos genéricos com interpolação
de `{name}`:

| Código do core             | Template pt-BR    | Exemplos renderizados                           |
| -------------------------- | ----------------- | ----------------------------------------------- |
| `VStringCode.taxId`        | `{name} inválido` | "CPF inválido", "CNPJ inválido", "CNH inválido" |
| `VStringCode.postalCode`   | `{name} inválido` | "CEP inválido"                                  |
| `VStringCode.licensePlate` | `{name} inválida` | "Placa inválida"                                |
| `VStringCode.phone`        | `Telefone inválido` (sem interpolação) | "Telefone inválido"                             |

O `{name}` vem da propriedade `name` de cada pattern — `CpfPattern`
declara `'CPF'`, `CnpjPattern` declara `'CNPJ'`, e assim por diante.

Único código específico do `validart_br`:

| Constante                     | Código            | Mensagem pt-BR     |
| ----------------------------- | ----------------- | ------------------ |
| `VStringCodeBr.invalidPixKey` | `invalid_pix_key` | Chave PIX inválida |

## Extensibilidade

Este pacote é construído inteiramente sobre os pontos de extensão
públicos do core. Cada validador BR é uma classe que estende um abstract
do validart:

| Pattern BR             | Abstract do core      |
| ---------------------- | --------------------- |
| `CpfPattern`           | `TaxIdPattern`        |
| `CnpjPattern`          | `TaxIdPattern`        |
| `PisPattern`           | `TaxIdPattern`        |
| `TituloEleitorPattern` | `TaxIdPattern`        |
| `CnhPattern`           | `TaxIdPattern`        |
| `RenavamPattern`       | `TaxIdPattern`        |
| `CepPattern`           | `PostalCodePattern`   |
| `BrPlatePattern`       | `LicensePlatePattern` |
| `BrPhonePattern`       | `PhonePattern`        |

O único validador standalone é `PixKeyValidator` — é uma união de
formatos heterogêneos (chaves do DICT + BR Code), então não cabe num
único pattern.

### Escrevendo um pattern novo

Se precisar de um validador que não está aqui, escreva um pattern
próprio — mesma API que os patterns deste pacote:

```dart
class MeuDocumentoPattern extends TaxIdPattern {
  const MeuDocumentoPattern();

  @override
  String get name => 'Meu Documento';

  @override
  bool matches(String value) {
    // sua regra de validação aqui
    return value.length == 10;
  }
}

V.string().taxId(patterns: [const MeuDocumentoPattern()]);
// Mensagem com VLocaleBr.ptBr: "Meu Documento inválido"
```

Se quiser combinar vários países/documentos na mesma validação, passe
todos em `patterns:`:

```dart
V.string().taxId(patterns: [
  const CpfPattern(),
  const CnpjPattern(),
  const MeuDocumentoPattern(),
]);
```

## Exemplo completo

Veja `example/example.dart`. Para rodar:

```sh
dart run example/example.dart
```

## Licença

Veja [LICENSE](LICENSE) para detalhes.
