# Reduzir pulsos e tremores — especificação proposta

**Estado (v16): implementada.** Tecla **P** no título e no menu de pausa; o estado aparece escrito (LIGADO / DESLIGADO); a preferência fica em `user://settings.cfg`, separada do salvamento, e sobrevive a novos jogos. API: `set_reduced_pulses(enabled)` e `is_reduced_pulses_enabled()` em `main.gd`. O teste de contrato `tests/reduced_pulses_spec.gd` passa (59 verificações, código 0) e `tests/reduced_pulses_ui_smoke.gd` cobre a interface. Escopo, como previsto: cenas de culpa e do Guardião; tremores de combate não mudam.

## Interface

Nome: **Reduzir pulsos e tremores**. Disponível em Acessibilidade no título, antes da abertura, e no menu de pausa. Controle por teclado e controle, estado ligado/desligado escrito, sem depender apenas de cor. Descrição: “Remove clarões, oscilações de luz e tremores nas cenas. Sons e legendas são mantidos.”

Padrão proposto: **desligada**, preservando a apresentação atual. A escolha precisa estar disponível antes de iniciar a peregrinação. Persistir como preferência global em `user://settings.cfg`, separada da partida; iniciar novo jogo não deve apagá-la. Carregar a preferência antes de qualquer cena. Não ligar automaticamente por detectar um erro ou morte do jogador.

## Comportamento ligado

| Cena | Luz | Câmera | Som e informação |
|---|---|---|---|
| Eco das batidas | Sem clarão branco ou contração do foco de luz; `flash=0`, `pulse=0` | Nenhuma chamada de tremor | Preservar três batidas, seus tempos e legendas |
| Ecos de vozes | Luz sem oscilação periódica | Sem tremor | Preservar murmúrios e falas escritas |
| Memorial | Sem pulsação de luz | Sem tremor | Manter sino abafado, sua legenda, gesto e registro posterior |
| Memória | Sem clarões por batida e sem foco luminoso pulsante | Sem tremor | Manter montagem, imagens, legendas e três batidas finais |
| Entrada e queda do Guardião | Sem flashes ou pulsos adicionados | Sem tremor | Preservar falas, som, legenda e duração |

A configuração não muda dano, inimigos, recompensas, duração, mínimos para pular, progressão ou número/volume das batidas. Não substitui legendas por silêncio. Foco de câmera e transições entre planos continuam: esta opção não é um modo que elimina todo movimento. A animação corporal do Penitente permanece.

Aplicar imediatamente: ao ligar durante um impulso, zerar `narrative.flash`, `narrative.pulse` e `player.shake` até o próximo quadro; interromper qualquer tremor já em andamento. Ao desligar, retomar apenas os efeitos futuros, sem reproduzir batidas/clarões atrasados. A respiração luminosa contínua do foco também deve ficar estável; zerar apenas a variável de impulso não basta se a fórmula de raio ainda usar uma oscilação temporal.

Escopo desta proposta: cenas de culpa e do Guardião. Tremores de combate/jogabilidade exigem uma preferência própria ou uma ampliação explícita do rótulo/escopo. Não anunciar “todos os tremores do jogo” com esta implementação parcial.

## Contrato de teste proposto

API no controlador principal:

- `set_reduced_pulses(enabled: bool) -> void`: aplica e persiste a preferência.
- `is_reduced_pulses_enabled() -> bool`: devolve a preferência carregada.

O Claude pode escolher outra API, desde que atualize especificação e teste juntos. A opção deve impedir as chamadas de tremor na origem da cena, não apenas receber a chamada em `shake_cam` e ignorá-la.

`tests/reduced_pulses_spec.gd` usa uma subclasse de teste para observar chamadas reais de `shake_cam`; ela não oferece os métodos da opção. Executa um eco normal para verificar a instrumentação. Se a API ainda não existe, grava `NOT_IMPLEMENTED` e termina com código2, sem declarar a opção aprovada. Na base v15 recebida, esse é o resultado esperado.

Quando a API existir, compara ligado/desligado nas variantes de eco e memorial, memória e Guardião: `flash`/`pulse` iguais a zero em todos os passos simulados, zero chamadas de tremor, mesmo número de chamadas sonoras, mesmas legendas e duração. Também testa ligar durante um impulso ativo. Resultados em `reduced-pulses-spec-result.json`.

```sh
XDG_DATA_HOME=/tmp/lacrimae-reduced-v15/data XDG_CONFIG_HOME=/tmp/lacrimae-reduced-v15/config XDG_CACHE_HOME=/tmp/lacrimae-reduced-v15/cache godot --headless --path . --script res://tests/reduced_pulses_spec.gd
```

## Validação posterior ainda necessária

Verificar a interface por teclado/controle, carregar uma nova sessão e confirmar persistência, testar a opção antes da abertura e no menu de pausa. Inspecionar visualmente o foco de luz: o teste por propriedades não detecta uma oscilação desenhada sem usar `pulse`. Conferir legendas e áudio com pessoas, inclusive pessoas sensíveis a movimento. Nenhum teste desta especificação certifica WCAG, conforto universal ou segurança fotossensível.
