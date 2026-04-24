# Changelog

## [0.1.0] - 2026-04-24

- Primeira versão. Requer `validart: ^1.3.0`.
- Patterns BR que plugam nos pontos de extensão do core:
  - `CpfPattern`, `CnpjPattern`, `PisPattern`, `TituloEleitorPattern`, `CnhPattern`, `RenavamPattern` → `TaxIdPattern`
  - `CepPattern` → `PostalCodePattern`
  - `BrPlatePattern` → `LicensePlatePattern`
  - `BrPhonePattern` → `PhonePattern`
- Métodos de atalho em `VString` (`cpf`, `cnpj`, `cep`, `pis`, `tituloEleitor`, `cnh`, `renavam`, `plate`, `phoneBr`) que delegam ao método equivalente do core com o pattern BR. A forma explícita usa `patterns: [...]` (lista) — ex.: `V.string().taxId(patterns: [const CpfPattern()])` — e permite compor múltiplos países na mesma validação.
- `CnpjPattern` aceita o novo formato alfanumérico da Receita (default); `alphanumeric: false` força o formato antigo.
- `PixKeyValidator` — validator composto que aceita qualquer identificador PIX. Um parâmetro `allow: List<PixKeyType>` controla os tipos aceitos. Por padrão aceita as cinco chaves do DICT (CPF, CNPJ, e-mail, telefone `+55…`, UUID v4). Inclua `PixKeyType.brCode` em `allow` para também aceitar o BR Code (payload EMVCo do QR Code), validado estritamente — estrutura TLV, CRC16-CCITT-FALSE e campos obrigatórios do Bacen.
- `VLocaleBr.ptBr` traduz todas as mensagens do core do validart (incluindo `tax_id`, `postal_code`, `license_plate` com `{name}` e `invalid_phone` do `BrPhonePattern`) + `VStringCodeBr.invalidPixKey`.
- `ValidationMode` e `CountryCodeFormat` são re-exportados do core — `import 'package:validart_br/validart_br.dart'` basta.
