As mensagens em português e os códigos que as identificam.

`VLocaleBr.ptBr` cobre as mensagens do core **mais** as deste pacote — uma
chamada em `V.setLocale(VLocaleBr.ptBr)` traduz a validação inteira, não só a
parte brasileira. Para trocar uma mensagem específica, passe `message:` no
próprio validador ou monte um `VLocale` a partir dos mapas expostos aqui.

`VCodeBr` reúne os códigos que este pacote emite (`cpf`, `cnpj`, `boleto`…).
São eles que aparecem em `VError.code`, e é por eles que se traduz para um
terceiro idioma sem tocar nos schemas.
