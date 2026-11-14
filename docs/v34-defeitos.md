# Defeitos encontrados na revisão v34, corrigidos na v35

1. **Setas do F3 assumiam Beatriz sem querer.** A entrada de J2 agora só assume a personagem durante a partida, fora dos painéis, mensagens e transições. Reproduzido antes da correção; teste com IA e J2 manual.
2. **J2 pulava ao selecionar salas no modo dev.** Beatriz espera enquanto o painel dev, mapa ou menu de penitências está aberto. O controle volta ao fechar o painel e soltar a entrada anterior.
3. **Uma tecla no mapa assumia Beatriz.** Usa a mesma condição de entrada jogável; verificação própria.
4. **Desligar o voo dentro de alvenaria prendia o Penitente.** Ao usar N ou fechar F3, uma consulta ao corpo verifica a interseção e retorna ao último piso seguro. As duas saídas foram reproduzidas e testadas.
5. **Pausa com controles sobrepostos.** A lista de 17 linhas cruzava as instruções inferiores. Agora há duas colunas, teclas de P1/J2 separadas, S+J correto e atalhos comuns. [Captura atual](contatos-v35/pausa-controles.png).
6. **Mancha de execução durava além do anunciado.** O contador ficava depois do retorno antecipado do estado de execução. Agora dura 0,5 s real, inclusive durante pausa de impacto e câmera lenta. O HUD considera a execução dos dois personagens.
7. **Respingos de alvos no ar flutuavam.** A mancha procura o piso abaixo antes de ser colocada; o limite de 90 vale inclusive para várias criações no mesmo quadro.

`v34_controls_smoke` passou de 5 falhas em 7 verificações antes da correção para zero. `v35_integration_smoke` cobre os sons opcionais, o tempo da mancha, apoio das manchas e limites. As capturas foram renderizadas no Godot 4.6.3.

A rota física de exploração também foi repetida com Beatriz por IA e com J2 presente em espera: 52 verificações em cada modo, sem falhas. Esse ensaio usa entradas de movimento de P1, inimigos parados e conclusões dirigidas de cenas; não representa uma partida humana cooperativa completa nem confirma equilíbrio ou sensação de combate. Combate, arenas, Guardião e encerramento têm verificações automatizadas específicas na suíte completa.

Os comentários de produção em `scripts/*.gd` foram revisados. Os nomes de variáveis, funções e APIs continuam como estavam. Não houve renomeação geral.
