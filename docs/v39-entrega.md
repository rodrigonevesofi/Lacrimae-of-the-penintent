# Entrega v39 — cenários vivos e o rosto com barba

Feita sobre a versão 38 publicada pelo Codex (commit `db1536d`), que foi conferida e mantida inteira.

- **A pintura de cada sala agora se mexe.** Panos e hera ao vento, água correndo, nuvens passando, chamas tremendo com halo, vitrais respirando. Shader `pintura_viva` sobre as pinturas que já existiam.
- **Bichos que reagem:** corvos que levantam voo, morcegos em revoada, ratos que fogem, mariposas e folhas secas.
- **Primeiro plano em contraluz** com `Parallax2D`, para dar profundidade.
- **Chuva e relâmpagos** no Terraço dos Sinos, com `AnimationPlayer` e sons novos (`amb_chuva`, `trovao_01` a `03`).
- **Rosto do Penitente redesenhado no papel:** barba cheia e malcuidada, cabelo empastado, marcas do capacete. Os três closes foram repintados e integrados pelo Codex; veja [v39-integracao.md](v39-integracao.md).

Capturas: [Terraço com relâmpago](imagens/v39-terraco-relampago.png), [Cisterna](imagens/v39-cisterna.png).

## Polimento (segunda rodada)
- **Personagens no chão:** o chão de colisão foi alinhado ao piso pintado em nove salas (no Claustro e no Campanário eles flutuavam).
- **Galerias, alvenaria, portas e monumentos** na cor da pedra de cada sala, com mísulas e sombras; soleira sob as portas altas.
- **Espada** atrás da mão e junto à guarda; folhas do Penitente e de Beatriz limpas e com a mesma cor.
- **Beatriz** joga junto desde o início; ganhou teclas para notebook sem teclado numérico.

Capturas: [Claustro, pés no chão](imagens/v39-claustro-pes-no-chao.png), [Campanário com a dupla](imagens/v39-campanario-dupla.png). Detalhes: [v39-polimento.md](v39-polimento.md).

Detalhes dos cenários: [cenarios-vivos.md](cenarios-vivos.md) e [design-chefe-e-rosto.md](design-chefe-e-rosto.md). Testes: `v39_cenario_smoke` (149 verificações), `v39_polimento_smoke` (56) e `folhas_limpas_check.py` (29).

As nove fichas receberam aprovação do autor e foram transformadas em criaturas com animação e combate nesta integração. [Entrega completa e validação](v39-integracao.md).
