# Entrega sobre a base v12

O patch fornecido foi aplicado sobre `6a170ed` sem rejeições. Como ele exclui binários, `knock.wav` foi gerado pelo `tools/make_knock.py` que veio no próprio patch. As artes de memória, o fragmento e os dez atlas já presentes foram preservados. A base passa a ter as salas, criaturas e cenas do Claude.

## Novos arquivos

- [Fundos secretos](fundos-secretos.md): três pinturas e capturas com guia de piso/Penitente. Ainda não ligados à campanha.
- [Equilíbrio simulado](equilibrio-humano.md):50 encontros pedidos e 10 controles da Asmodeia, com posições reais do layout. Controlador com atraso 180–260ms, erro probabilístico 10%, recuo e cura. Dados completos no JSON. Limitações de navegação e encontros sequenciais estão declaradas.
- [Execuções](execucoes-revisao.md): cinco folhas,12 quadros pareados antes/depois; três âncoras corrigidas. A diferença dinâmica de altura das vítimas aéreas continua pendente.
- [Áudio de culpa](audio-culpa.md): cinco WAVs sintetizados e análise de pico, início e espectro. Não ligados ao jogo; audição crítica contextual ainda pendente.
- `tests/guilt_text_review.gd`:33 trechos literais/constantes e 7 frases sintéticas proibidas. Resultado e cada frase em [guilt-text-revisao.txt](guilt-text-revisao.txt). A interface de oração, que informa cura, é identificada separadamente das cenas de culpa. O teste não reconhece todas as paráfrases nem um nome próprio ainda não definido; revisão editorial continua necessária.

## Validação

- Verificador de atlas: sem erros após as alterações de âncora.
- Arquivos novos: dimensões/opacidade dos fundos e formato/pico/início dos WAVs conferidos.
- Base do patch: expansão 45/45, culpa 30/30, história 29/29 e exploração 51/51 passaram sem erros de execução nas rodadas registradas.
- Bestiário:38/38 verificações passaram, mas o teste fornecido deixa um objeto sem liberar ao sair. Há avisos de ObjectDB/resource/RID; não é uma execução limpa. Uma criação temporária em `tests/bestiary_smoke.gd` não é liberada. Não alterei o teste original.
- Folhas de execução e fundos renderizados no Godot 4.6.3/GL Compatibility; aviso de V-Sync da tela virtual. Memória da campanha também capturada a partir da cena real em `docs/imagens/v12-memoria-*.png`.
- Sonda: 60 resultados, não 60 vitórias. Limite de tempo não demonstra que um inimigo seja difícil; pode indicar falha do controlador. Os resultados não comprovam equilíbrio, beleza ou impacto emocional.

Após aplicar a base, os dez scripts protegidos (incluindo player.gd, preservado por precaução) foram comparados byte a byte com o conteúdo esperado do patch. Conferência em `v12-escopo.json`. Em clips.json, somente `executed.anchor` mudou: Devorador[128,242], Flagelante[128,240], Asmodeia[128,237]; Bruxa e Duelista permaneceram[128,250]. Os demais campos são os do patch.
