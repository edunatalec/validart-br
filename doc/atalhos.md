A forma curta de escrever uma validação brasileira.

`VStringBr` é a extension que acrescenta `cpf()`, `cnpj()`, `cep()`, `pis()`,
`tituloEleitor()`, `cnh()`, `renavam()`, `telefone()`, `placa()`, `chavePix()`,
`uf()`, `codigoBanco()`, `ddd()` e `boleto()` ao `V.string()` do validart.

Cada atalho tem uma forma explícita equivalente — `V.string().cpf()` produz o
mesmo resultado que `V.string().taxId(patterns: [const CpfPattern()])`. A
escolha entre as duas é de estilo: o atalho encurta o código BR-only, o pattern
deixa explícito o ponto de extensão do core e permite combinar países.
