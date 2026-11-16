# Entrega v39 — cenários vivos e o rosto com barba

Feita sobre a versão 38 publicada pelo Codex (commit `db1536d`), que foi conferida e mantida inteira.

- **A pintura de cada sala agora se mexe.** Panos e hera ao vento, água correndo, nuvens passando, chamas tremendo com halo, vitrais respirando. Shader `pintura_viva` sobre as pinturas que já existiam.
- **Bichos que reagem:** corvos que levantam voo, morcegos em revoada, ratos que fogem, mariposas e folhas secas.
- **Primeiro plano em contraluz** com `Parallax2D`, para dar profundidade.
- **Chuva e relâmpagos** no Terraço dos Sinos, com `AnimationPlayer` e sons novos (`amb_chuva`, `trovao_01` a `03`).
- **Rosto do Penitente redesenhado no papel:** barba cheia e malcuidada, cabelo empastado, marcas do capacete. Os três closes foram repintados e integrados pelo Codex; veja [v39-integracao.md](v39-integracao.md).

Capturas: [Terraço com relâmpago](imagens/v39-terraco-relampago.png), [Cisterna](imagens/v39-cisterna.png).

Detalhes: [cenarios-vivos.md](cenarios-vivos.md) e [design-chefe-e-rosto.md](design-chefe-e-rosto.md). Teste novo: `v39_cenario_smoke`, 149 verificações.

As nove fichas receberam aprovação do autor e foram transformadas em criaturas com animação e combate nesta integração. [Entrega completa e validação](v39-integracao.md).
