# Carregador exposto

`assets/animation/carregador_exposto.png`: RGBA 1536 × 1024, 6 × 4 células de 256. Mesmo adulto de faixas, correntes e tecido ocre de `carregador.png`, sem caixão, perfil à direita. Origem proposta (128,250), mesma escala de célula. Conferir apoio dos pés na transição entre atlas; a verificação não rastreia o esqueleto.

| Quadros | Ação | Tempo inicial proposto |
|---|---|---|
| 0–2 | Mãos recuam, torso e perna se preparam | 120/150/180 ms |
| 3–5 | Golpe com punhos presos e recuperação | 90/110/160 ms |
| 6–11 | Recuo, desequilíbrio e recuperação | 10 fps |
| 12–23 | Reação à execução, joelhos cedem e corpo se deita | 10 fps, manter 23 |

Somente a criatura aparece. A execução não inclui atacante, deslocamento do Penitente, recompensa nem lógica de invulnerabilidade. Sincronizar a ação do protagonista e os sons na integração. A sequência é uma queda sem desmembramento. O corpo final permanece no chão; evitar voltar à caminhada ao terminar o clipe.

Para o ataque, dar dano apenas no avanço legível, depois da preparação, nunca durante toda a animação. O integrador deve substituir o dano por contato por uma regra explícita, conforme o combate pretendido. Os tempos acima são propostas, não balanceamento testado.

Folha: `imagens/v22-carregador_exposto-contato.png`. Verificador: `python3 tests/art_v22_check.py`; prévia `videos/v22-atlas.mp4`. Conferidos formato, alpha, células não vazias e 24 quadros distintos. Não validados: animação em motor, continuidade das articulações, hitboxes, sincronização da execução, legibilidade em luta e fluidez percebida. Atlas novo ainda não ligado ao jogo.
