# Entrega v38 — o chefe não entrega mais o final

- **O chefe final passa a se chamar O FLAGELADO.** "O Penitente" na barra de vida revelava o final. O nome vem de `NOME` em `penitent_boss.gd`; o teste `vale_boss_smoke` confere que ele não contém "Penitente".
- **Ele espera entre as forcas com a própria aparência** e só copia o jogador depois de vê-lo ("Ele ergue a cabeça, olha para você — e veste a sua forma."). Durante essa troca nada o fere. A fala de abertura deixou de sugerir que ele é o protagonista.
- **Nove pontos de som e duas músicas opcionais** para a luta final e a revelação (ver `prompts-sons-vale-argon.md`): mudos até os arquivos chegarem; sem as músicas, tocam a do chefe e a de história.
- **Design** do chefe e do rosto do Penitente: [design-chefe-e-rosto.md](design-chefe-e-rosto.md).

**Integração posterior concluída:** a forma verdadeira agora usa as folhas originais de elmo-gaiola, incluindo quatro estados de armadura. O retrato foi substituído e os três closes foram ligados à revelação. O vale, as salas e os efeitos também receberam a arte e o código pedidos. As nove fichas novas estão prontas para aprovação antes de animar. Ver [v38-integracao.md](v38-integracao.md) para contatos, capturas, testes e limites atuais.

Captura: [v38-o-flagelado.png](imagens/v38-o-flagelado.png). Teste: `vale_boss_smoke`, 33 verificações.
