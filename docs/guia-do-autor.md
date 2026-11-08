# Guia do autor — Lacrimae of the Penitent

## Abrir e jogar

Extraia o ZIP completo numa pasta nova. Não abra o projeto dentro do ZIP. Abra **Godot Standard4.6.3**, clique em **Importar**, escolha `project.godot` e aguarde a importação. Clique em **Editar** e pressione **F5** para executar. O primeiro carregamento pode levar mais tempo porque o editor prepara as imagens e os sons. A pasta `.godot` é recriada automaticamente e não precisa vir no pacote.

No título, escolha iniciar ou continuar. **A/D** movem, **Espaço** pula, **S+Espaço** desce de galeria, **J/X** ataca, **K/Shift** esquiva, **E** interage, **F** cura, **Q** usa penitência, **TAB** abre mapa e **Esc** pausa. **M** silencia o som. **P**, no título ou na pausa, reduz pulsos e tremores nas cenas. No altar, **V** abre penitências e **R** oferece lágrimas. Esta base ainda não tem o novo aparo, ataque forte ou as três fases que o Claude propôs.

Se o gerenciador disser “falha ao iniciar o editor”, confirme a versão, a pasta extraída e a localização de `project.godot`. Para ajuda, envie a versão do Godot e o erro completo, além de informar se falhou em Importar, Editar ou F5. Não apague o salvamento para tentar corrigir arte faltante. Faça uma cópia da pasta antes de migrar o projeto para outra versão do Godot.

## O que há nas pastas

| Pasta / arquivo | Para que serve |
|---|---|
|`project.godot`|Ponto de entrada do projeto no editor|
|`scenes/`|Organização das cenas, incluindo a principal|
|`scripts/`|Regras do jogo: personagem, inimigos, exploração, narrativa, som e interface|
|`assets/`|Imagens e recursos; os fundos de salas ficam na raiz dessa pasta|
|`assets/animation/`|Folhas com quadros de animação e o catálogo `clips.json`|
|`assets/audio/`|Músicas e efeitos em WAV|
|`assets/memory/`, `assets/boss/`, `assets/ending/`|Ilustrações das cenas|
|`assets/ui/`|Ícones novos de interface|
|`docs/`|Roteiros, decisões, instruções, medições e limites; não é tudo texto exibido no jogo|
|`docs/imagens/`|Capturas de revisão; não substituem teste em movimento|
|`tests/`|Verificações e sondas que ajudam a encontrar problemas|
|`tools/`|Geradores, verificadores e prévias de trabalho|
|`.godot/`|Cache local recriado pelo editor; não editar manualmente|

Salvamentos e preferências ficam na pasta de dados do usuário do Godot, fora da pasta do projeto. No editor, a opção de abrir a pasta de dados do usuário ajuda a localizá-la. O arquivo da partida é `lacrimae_save.json`; as preferências ficam separadas. Copie o arquivo para fazer backup antes de experimentar versões. Os testes de corrupção usam apenas dados descartáveis e não devem receber o caminho do seu salvamento real.

## Por onde começar a ler

Comece pelo roteiro dos cinco atos e pelo roteiro de playtest. Consulte a entrega mais recente para saber o que foi integrado e o que ainda é proposta. Documentos antigos preservam o histórico: números de salas, falhas e status podem ter mudado. Um arquivo chamado “especificação” não prova que a opção está implementada; consulte o teste e a entrega da versão correspondente.

O índice abaixo agrupa todos os documentos Markdown presentes nesta entrega. JSONs guardam os números completos das tabelas; arquivos de imagem/vídeo guardam a evidência visual. Não precisam ser lidos para jogar.

## História e roteiro

- [ato2-esboco.md](ato2-esboco.md): Mapa proposto para o Ato II, sem autorizar sua produção.
- [campanha.md](campanha.md): Campanha — cânone fornecido pelo autor. Consulte o estado e os limites indicados no documento.
- [cenas-culpa.md](cenas-culpa.md): Cenas de culpa (v17). Consulte o estado e os limites indicados no documento.
- [fontes-literarias.md](fontes-literarias.md): Vozes, inscrições e fontes. Consulte o estado e os limites indicados no documento.
- [historia.md](historia.md): Lacrimae of the Penitent — referência narrativa. Consulte o estado e os limites indicados no documento.
- [revisao-dramatica.md](revisao-dramatica.md): Revisão dramática e verificação narrativa. Consulte o estado e os limites indicados no documento.
- [revisao-textos-ato1.md](revisao-textos-ato1.md): 17 propostas editoriais com trechos e justificativas.
- [revisao-textos-respostas.md](revisao-textos-respostas.md): Quais propostas foram aplicadas, mantidas ou deixadas ao autor.
- [roteiro-cinco-atos.md](roteiro-cinco-atos.md): Roteiro completo, ordem das revelações e decisões ainda propostas.

## Arte e animação

- [abismo-ponte.md](abismo-ponte.md): Dimensões, ponto de encaixe e prévia da pintura do abismo.
- [animacoes-v04.md](animacoes-v04.md): Animações v0.4 — implementação e validação. Consulte o estado e os limites indicados no documento.
- [arte-bestiario.md](arte-bestiario.md): Arte das novas criaturas. Consulte o estado e os limites indicados no documento.
- [ato1-encerramento-v2.md](ato1-encerramento-v2.md): Arquivo de encerramento, medidas, prévia e estado da integração.
- [ato1-encerramento.md](ato1-encerramento.md): Arquivo de encerramento, medidas, prévia e estado da integração.
- [auditoria-luminancia.md](auditoria-luminancia.md): Brilho dos arquivos, alertas e limites da medição.
- [bestiario-goya.md](bestiario-goya.md): Bestiário inspirado em Goya (v16). Consulte o estado e os limites indicados no documento.
- [direcao-visual.md](direcao-visual.md): Direção visual recebida do autor. Consulte o estado e os limites indicados no documento.
- [efeitos-combate.md](efeitos-combate.md): Quadros de faísca, sangue, aparo e poeira; ainda sem conexão ao combate.
- [execucoes-revisao.md](execucoes-revisao.md): Revisão das execuções. Consulte o estado e os limites indicados no documento.
- [fundos-secretos.md](fundos-secretos.md): Fundos das salas secretas. Consulte o estado e os limites indicados no documento.
- [guardiao-grande.md](guardiao-grande.md): Ordem das24poses, pivôs e cuidados para integrar o atlas maior.
- [guardiao-ilustracoes.md](guardiao-ilustracoes.md): Guardião dos Sinos — ilustrações. Consulte o estado e os limites indicados no documento.
- [guardiao-imovel-v2.md](guardiao-imovel-v2.md): Comparação de brilho e prévia da nova arte do bronze imóvel.
- [hero-memorial.md](hero-memorial.md): Penitente e boneca — atlas do memorial. Consulte o estado e os limites indicados no documento.
- [memorias-entrega.md](memorias-entrega.md): Registro das mudanças e dos limites dessa versão.
- [perigos-percurso.md](perigos-percurso.md): Espinhos, plataformas e pilar; quadros e cuidados de colisão.
- [reliquias-icones.md](reliquias-icones.md): Nomes e posições dos12ícones e suas versões bloqueadas.

## Áudio

- [audio-culpa.md](audio-culpa.md): Áudio das cenas de culpa. Consulte o estado e os limites indicados no documento.
- [auditoria-volume.md](auditoria-volume.md): Picos e médias dos WAVs; propostas de ganho, sem audição contextual.
- [mixagem.md](mixagem.md): Como o Claude separou os grupos de volume e por que não aplicou ganhos sem ouvir.
- [sfx-criaturas.md](sfx-criaturas.md): Sons das criaturas. Consulte o estado e os limites indicados no documento.
- [trilhas-secretas.md](trilhas-secretas.md): Trilhas das salas secretas. Consulte o estado e os limites indicados no documento.

## Acessibilidade

- [acessibilidade-cenas.md](acessibilidade-cenas.md): Acessibilidade das cenas de culpa. Consulte o estado e os limites indicados no documento.
- [acessibilidade-pulsos.md](acessibilidade-pulsos.md): Acessibilidade das cenas de culpa. Consulte o estado e os limites indicados no documento.
- [especificacao-reducao-de-pulsos.md](especificacao-reducao-de-pulsos.md): Reduzir pulsos e tremores — especificação proposta. Consulte o estado e os limites indicados no documento.
- [v16-acessibilidade-cenas-resultado.md](v16-acessibilidade-cenas-resultado.md): Acessibilidade das cenas de culpa. Consulte o estado e os limites indicados no documento.

## Testes, exploração e mecânicas

- [ato-i-exploracao.md](ato-i-exploracao.md): Ato I — exploração e interface. Consulte o estado e os limites indicados no documento.
- [expansao-v09.md](expansao-v09.md): Expansão de exploração do Ato I (v09). Consulte o estado e os limites indicados no documento.
- [imersao.md](imersao.md): Cenários, música e narrativa. Consulte o estado e os limites indicados no documento.
- [penitencias.md](penitencias.md): Penitências e fragmentos. Consulte o estado e os limites indicados no documento.
- [referencias-combate.md](referencias-combate.md): Referências de combate — Ato I. Consulte o estado e os limites indicados no documento.
- [robustez-salvamento.md](robustez-salvamento.md): Casos válidos e corrompidos; mostra falhas encontradas, não correções.
- [roteiro-de-playtest-v14-resumido.md](roteiro-de-playtest-v14-resumido.md): Versão anterior e mais curta do roteiro de teste humano.
- [roteiro-de-playtest.md](roteiro-de-playtest.md): Sessão guiada para o autor registrar o que sentiu, entendeu e não viu.

## Equilíbrio

- [equilibrio-chefe.md](equilibrio-chefe.md): Resultados da sonda do Guardião com reação atrasada; não é playtest humano.
- [equilibrio-humano.md](equilibrio-humano.md): Simulação de encontros comuns com atraso e chance de erro.
- [equilibrio.md](equilibrio.md): Medições anteriores e limites da análise de combate.

## Entregas e tarefas

- [entrega-v09.md](entrega-v09.md): Registro das mudanças e dos limites dessa versão.
- [prompts-codex-v17.md](prompts-codex-v17.md): Lista de tarefas recebida para essa base; não comprova integração.
- [prompts-codex-v18.md](prompts-codex-v18.md): Lista de tarefas recebida para essa base; não comprova integração.
- [v12-entrega.md](v12-entrega.md): Registro das mudanças e dos limites dessa versão.
- [v13-entrega-codex.md](v13-entrega-codex.md): Registro das mudanças e dos limites dessa versão.
- [v13-entrega.md](v13-entrega.md): Registro das mudanças e dos limites dessa versão.
- [v14-entrega.md](v14-entrega.md): Registro das mudanças e dos limites dessa versão.
- [v15-entrega-codex.md](v15-entrega-codex.md): Registro das mudanças e dos limites dessa versão.
- [v15-entrega.md](v15-entrega.md): Registro das mudanças e dos limites dessa versão.
- [v16-entrega-codex.md](v16-entrega-codex.md): Registro das mudanças e dos limites dessa versão.
- [v16-entrega.md](v16-entrega.md): Registro das mudanças e dos limites dessa versão.
- [v17-entrega.md](v17-entrega.md): Registro das mudanças e dos limites dessa versão.
- [v18-entrega-codex.md](v18-entrega-codex.md): Registro das mudanças e dos limites dessa versão.

## Rodar um teste sem programar

Os testes são ferramentas técnicas. Você não precisa rodá-los para jogar; pode enviar os relatórios ao Claude/Codex. Se quiser executar uma verificação simples, abra um terminal na pasta que contém `project.godot`, com o comando `godot` disponível, e use:

```sh
godot --headless --path . --script res://tests/chapter_smoke.gd
python3 tests/v18_art_check.py
```

O primeiro verifica o capítulo sem abrir a janela de jogo. O segundo precisa de Python, Pillow e numpy e confere os novos arquivos de arte sem editar o catálogo de animações. No Windows, o executável pode exigir o caminho completo; nesse caso peça ao integrador um comando com o caminho da sua instalação. `--headless` significa executar sem janela, não jogar melhor ou mais rápido.

Os testes de salvamento e a sonda do chefe exigem ambiente Linux com dados isolados; os comandos completos estão nos respectivos documentos. Não adapte o comando apontando para a pasta do seu usuário real. Código0 significa que o teste cumpriu seus critérios; código1 geralmente indica falha medida. Outros códigos são explicados pelo próprio teste. Procure também `SCRIPT ERROR`, `FAIL` e o resumo final: o motor pode terminar com código0 apesar de um erro de script. Não esconda linhas vermelhas antes de enviar o resultado.

Na robustez do salvamento há falhas esperadas da base sob entradas corrompidas. Isso é um problema encontrado para corrigir, não um teste aprovado. Uma sonda pode terminar sem erros e mesmo assim mostrar uma luta curta, fácil ou sem graça. Captura parada não comprova animação fluida; números não comprovam que a história emociona.

## Como relatar um problema

Informe versão/commit, Godot e sistema. Diga o local, o que fez, o que esperava e o que aconteceu. Acrescente se é partida nova ou continuação, frequência e mensagem de erro. Em vídeo, indique os segundos relevantes. Para som, diga se usava fones ou caixas, se M estava ativo e o que estava alto, baixo ou ausente. Para narrativa, descreva o que entendeu e sentiu antes de tentar propor uma correção. Se não viu uma cena, escreva “não vi”; não precisa dar uma nota inventada.

Exemplo de relato útil: na versão18, ao continuar uma partida, no Arquivo, usei uma passagem e apareci fora da plataforma; esperava chegar dentro da galeria. Aconteceu duas vezes. É mais útil que apenas dizer que a porta está ruim. Ao enviar salvamento ou log, use uma cópia e remova informações pessoais que não sejam necessárias ao problema.

## Autor, Claude e Codex

1. **Autor:** decide o que o jogo quer comunicar, joga, relata e aprova mudanças de roteiro e escopo.
2. **Claude:** integra regras, recursos e cenas na base atual e entrega patch/ZIP com identificação da versão.
3. **Codex:** recebe a base e as tarefas, cria novos recursos, testes e documentos, verifica os critérios e registra limites. Neste fluxo cria somente arquivos novos; alterações existentes vêm do patch recebido. Não muda scripts protegidos nem `clips.json` para conectar a própria arte.
4. **Claude:** recebe o pacote pequeno de acréscimos, conecta os arquivos, corrige problemas apontados e repete os testes. O pacote pequeno não substitui o projeto completo.
5. **Autor:** compara a versão integrada jogando. O Ato II continua condicionado a esse relato, mesmo já existindo esboço e roteiro.

Não misturar bases: antes de integrar, conferir versão e commit. Não substituir a pasta inteira por um ZIP antigo. `.patch` descreve alterações; o integrador aplica sobre a base correta e resolve conflitos. Um commit com nome simples identifica uma etapa, mas o documento de entrega explica o conteúdo.

## O que significa “não validado”

| Expressão | O que ainda falta |
|---|---|
|Não integrado|O arquivo existe, mas a execução do jogo ainda não o usa|
|Medido no arquivo|Há números de brilho/volume, sem prova de percepção no jogo|
|Não ouvido em contexto|Falta ouvir música e efeitos juntos durante uma partida|
|Prévia de atlas|Os quadros foram exibidos num teste separado; não é combate final|
|Simulação|Um controlador programado jogou sob regras limitadas; não representa uma pessoa|
|Sem playtest humano|O funcionamento técnico não responde se o jogo prende ou emociona|
|Decisão do autor|Há alternativas de roteiro/escopo; nenhuma é fato aprovado só por estar escrita|
|Falha encontrada|O teste demonstrou um problema; a correção ainda precisa ser implementada e verificada|
|Não certificado|Não há garantia universal de conforto, segurança fotossensível ou acessibilidade|

Se duas entregas discordarem, preserve os relatórios e peça comparação na mesma base. O objetivo é descobrir o que precisa melhorar, não transformar todo resultado em aprovação.
