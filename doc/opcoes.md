Os enums que ajustam o que cada validador aceita.

`ModoValidacao` decide se a máscara é exigida, proibida ou indiferente — o
default aceita as duas formas, então `123.456.789-09` e `12345678909` passam
igual.

Os outros três estreitam um validador específico: `FormatoDdd` e `FormatoPais`
dizem se o DDD e o `+55` são obrigatórios no telefone, `TipoChavePix` restringe
quais tipos de chave são aceitos, e `FormatoBoleto` separa linha digitável de
código de barras.
