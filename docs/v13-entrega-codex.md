# Entregas adicionais sobre a base v13

O patch fornecido foi aplicado sobre `d568e29`, sem rejeições. Ele integra os fundos e sons anteriores, ajusta as execuções aéreas e atualiza testes. As entregas abaixo só acrescentam arquivos. Nenhum script protegido ou campo de clips.json foi alterado após aplicar a base.

- [Guardião: três ilustrações](guardiao-ilustracoes.md), com revisão em 1280×720 e faixa inferior para legendas. Integração pelo Claude ainda pendente.
- [Memorial: atlas com 24 quadros](hero-memorial.md), folha de contato e reprodução de revisão. Ainda não ligado ao jogo.
- [Trilhas secretas](trilhas-secretas.md): três WAVs estéreo 44100 Hz/16 bits/16 s; picos e emendas conferidos. Ainda não ligadas ao jogo; audição crítica contextual pendente.
- [Playtest de 38 minutos](roteiro-de-playtest.md), perguntas, mortes e folha-resumo para o autor colar na conversa. É um roteiro de coleta, não um playtest já realizado.
- [Acessibilidade](acessibilidade-cenas.md): 22 checagens, 20 passaram e 2 pendências. Não foram encontrados equivalentes explícitos para os sinos iniciais do memorial e da memória. Não corrigi os scripts protegidos. Pulos após os mínimos funcionaram; máximo observado foi 2 picos brancos em janela de 1 s. Essa checagem não certifica WCAG nem segurança para pessoas fotossensíveis.

## Validação registrada

- `python3 tests/v13_assets_check.py`: formatos das três ilustrações, 24 quadros do atlas, cantos transparentes e quatro grupos de clipes; WAVs exportados com formatos, duração, pico e emenda corretos.
- `python3 tools/check_animation_atlases.py`: sem erros no manifesto da base.
- Godot 4.6.3/GL Compatibility: ilustrações e atlas renderizados; aviso de V-Sync da tela virtual. Revisão não é medição de desempenho em computador do autor.
- Base: bestiário 40/40, culpa 32/32, capítulo 42/42, exploração 51/51, expansão 45/45; saídas sem erros nas rodadas registradas.
- Acessibilidade: o código de saída 1 é esperado por causa das duas pendências documentadas, não um resultado integralmente aprovado.

O motivo das trilhas foi aproximado a partir de análise espectral de trecho da referência; a identidade musical percebida precisa de audição. Os testes não comprovam equilíbrio, beleza ou impacto emocional. Não foi feita uma partida humana de 30–40 minutos nesta entrega.
