# Confessionário: chat com IA nos altares

Em qualquer altar, **C** abre o Confessionário. O peregrino escreve uma pergunta ou confissão e o **Confessor**, uma voz sem rosto atrás da grade, responde no tom do jogo. O mundo fica pausado durante a conversa. **ENTER** envia e **ESC** fecha.

O Confessor serve para:

- tirar dúvidas de controles e mecânicas (aparo, culpa, penitências, Beatriz);
- dar pistas de caminho sem entregar o mapa ("onde está a relíquia?", "como passo do abismo?");
- dar dicas de combate de acordo com o histórico do jogador ("morri muito para o Guardião");
- recontar a lore já descoberta, **sem revelar o segredo do Penitente** antes da hora.

## Como ligar a IA (Gemini, plano gratuito)

1. Crie uma chave em <https://aistudio.google.com/apikey> com uma conta Google.
2. Na pasta do projeto, copie `ia_local.cfg.exemplo` como `ia_local.cfg` e cole a chave em `api_key`.
3. Confira a conexão (opcional). No Windows, dê dois cliques em `Testar-IA-Windows.cmd` e escolha o executável do Godot, ou rode:
   ```
   godot --headless --path . --script res://tests/confessor_live_check.gd
   ```
4. Jogue normalmente (F5) e aperte **C** num altar.

`ia_local.cfg` está no `.gitignore`, então **a chave não vai para o GitHub**. Também dá para usar a variável de ambiente `GEMINI_API_KEY` ou, num jogo exportado, o arquivo `user://ia.cfg` com o mesmo formato. No Windows, esse arquivo fica em `%APPDATA%\Godot\app_userdata\Lacrimae of the Penitent\`.

**Sem chave, sem internet ou com o limite gratuito esgotado**, o Confessor continua respondendo com falas prontas por assunto, usando o objetivo atual do jogador. O rodapé do painel mostra quem respondeu: `voz: Gemini` ou `voz: memória do altar`, junto com o motivo.

## Como funciona

```
 Jogador digita ─► confession_panel.gd ─► confessor.gd ──HTTP POST──► Gemini (generateContent)
                                            │  ▲                         │
                         estado do jogo ────┘  └──── resposta curta ◄─────┘
                         (main, player, exploration, telemetry)
                                            │
                                            └─ falha? ─► resposta offline por palavra-chave
```

- **`scripts/confessor.gd`**: monta a requisição e lê a resposta. Cada pergunta envia:
  - **instrução de sistema**: a persona, a lore, os controles, o progresso do Ato I, os inimigos e as regras de spoiler;
  - **estado do peregrino**: lugar, objetivo, correntes que faltam, vida, culpa, lágrimas, frascos, mortes, lugares onde mais morre e memórias vistas;
  - **histórico**: as últimas 4 trocas e a pergunta.

  O pedido é assíncrono (`HTTPRequest`), com tempo limite de 15 s e resposta de até 400 tokens. Se o modelo recusar `thinkingConfig`, o Confessor tenta de novo uma vez sem ele.
- **`scripts/confession_panel.gd`**: o painel do Confessionário, no estilo do HUD.
- **`scripts/telemetry.gd`**: registra localmente as mortes e o tempo por lugar e as dúvidas por assunto.
- **`scripts/main.gd`**: liga tudo. Cuida da tecla C no altar, de `open_confession` e `close_confession` (pausa e retomada), e registra mortes e tempo.

**Peso no jogo:** não há plugin nem modelo local. A IA só faz uma requisição curta por pergunta, nunca durante o combate.

## Telemetria (parte de Big Data)

O arquivo `user://telemetria.json` acumula o número de sessões, as mortes e o tempo por lugar, as perguntas por assunto e quem respondeu (Gemini ou offline). Esses dados:

1. entram no contexto do Confessor, que passa a saber onde o jogador costuma morrer;
2. viram relatório para ajustar o jogo:
   ```
   python tools/relatorio_telemetria.py
   python tools/relatorio_telemetria.py jogador1.json jogador2.json   # soma vários playtesters
   ```

A telemetria **nunca sai do computador**. Para o Gemini vai só o resumo do estado da partida, sem nome, conta ou qualquer dado pessoal.

## Para a apresentação (Disruptive Architectures: IoT, Big Data e IA)

- **IA:** um LLM (Gemini) integrado ao jogo como personagem, com *prompt engineering* (persona, base de conhecimento, regras de spoiler) e *grounding* no estado real da partida.
- **Big Data:** telemetria de jogabilidade coletada a cada sessão e agregada entre jogadores. Mostra onde morrem e o que perguntam, e retroalimenta tanto a IA quanto o design.
- **Arquitetura:** cliente leve, serviço de IA na nuvem e *fallback* offline (degradação graciosa) para o jogo nunca depender da rede.

## Testes

- `tests/confessor_smoke.gd` não usa rede. Cobre o contexto, o formato da requisição, a leitura da resposta, a classificação de dúvidas, o modo offline, a pausa ao abrir e fechar e a telemetria.
- `tests/confessor_live_check.gd` faz uma pergunta real ao Gemini. Exige a chave.

No Windows, para não mexer no seu save real durante os testes, rode com outra pasta de dados, por exemplo `set APPDATA=%TEMP%\lacrimae-teste` antes do comando.
