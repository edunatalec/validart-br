As regras que não têm ponto de extensão no core.

UF, código de banco (COMPE), DDD, chave PIX e boleto não são "um tipo de
documento" que o validart já conheça, então entram como `Validator` direto no
`V.string().add(...)` — que é o que os atalhos correspondentes fazem por baixo.

`ChavePixValidator` e `BoletoValidator` são os dois com mais superfície:
o primeiro aceita as chaves do DICT e o BR Code, com `tipos` restringindo o que
passa; o segundo cobre boleto bancário e de arrecadação, em linha digitável
(47 ou 48 dígitos) ou código de barras (44).
