# Entrega v32

Integra a "versão 30" do Codex (que tem os mesmos scripts da v31): a folha `onda_golpe.png`. O refinamento de combate já publicado foi preservado; veja [v32-integracao.md](v32-integracao.md) para a entrega integrada e validada.

- **Onda de poeira e pedra** no golpe descendente e **anel vermelho** à frente do golpe carregado.
- **Correção no animador:** ele supunha sempre 4 fileiras por folha; as folhas de efeito de 2 fileiras (`onda_golpe`, `onda_grito`) eram cortadas pela metade. Agora cada clipe pode declarar `"rows"`. O anel do grito do Guardião, que saía cortado, agora sai inteiro.
- **Sons:** avaliação por medida em `prompts-sons-argon.md`; prompt completo para o Argon com todos os sons do jogo, nomes exatos e formato.
- Decisão do autor: o Penitente atual fica (o do Argon segue guardado em `assets/animation/argon/`, sem uso).
