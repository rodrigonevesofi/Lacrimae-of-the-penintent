# Comparação visual e recursos de combate v19

Base preservada: `a21c9c2`. Foram criados somente arquivos novos; não houve patch de código novo do Claude neste envio. Esta entrega atende à análise dos vídeos e às **duas tarefas explícitas da mensagem**: `hero_combate.png` e portões. As cinco propostas do anexo v19 ficam como referência futura; não foram tratadas como autorização para substituir o escopo escolhido.

## Comparação dos vídeos

[Análise completa](comparativo-blasphemous-v19.md), com exemplos por arquivo, tempos aproximados, sequências de combate e prioridades para integrar. Dez vídeos recebidos,254quadros de visão geral e144amostras de sequência, total398amostras visuais. O10 não veio. Não houve audição, controle de Blasphemous ou prova de latência/fluidez equivalente.

Achados centrais:

- A referência anuncia intenção e consequência pelo corpo, pela arma e por mudança de estado. A nossa base já possui hitstop de45ms, tremor, golpes e execução; a lacuna está na leitura e na composição desses sinais.
- O herói atual mede109,12px em repouso,15,16% de720px; o Guardião mede222,64px,2,04vezes. Zoom comum não muda essa proporção. Corpo, arena, colisão e câmera devem ser revistos juntos.
- O vídeo1 mistura jogos; o vídeo9 duplica gameplay com recorte ampliado; o11 é comentado/editado e não mostra início de luta. A abertura do vídeo2 usa ilustrações com encadeamento forte. Não confundir edição do vídeo com recurso comprovado do motor.
- Um inimigo com transformação legível e uma travessia com regra clara trazem mais informação que só aumentar quantidade de inimigos ou extensão de corredores.

[Inventário técnico](v19-referencias-inventario.json), [amostra controlada de Lacrimae](videos/v19-baseline.mp4) e imagens de referência em `docs/referencias-v19/`. Os vídeos de terceiros não foram copiados para dentro dos assets do jogo; as imagens são evidência da análise, não material de produção.

## Novos recursos

| Arquivo | Conteúdo |
|---|---|
|`assets/animation/hero_combate.png`|RGBA1536×1024,24quadros: aparo, recuo, contra-golpe e golpe carregado; quadro2 legível em pose defensiva|
|`assets/arena_portao.png`|RGBA96×540, grade fechada com correntes, pedra e brasão apagado|
|`assets/arena_portao_aberto.png`|Mesma tela96×540, recolhido no teto; travessa inferior visível no topo e passagem transparente|

[Documento do Penitente](hero-combate.md) · [Portões](arena-portao.md) · [Folha de contato](imagens/v19-hero-contato.png) · [Vídeo dos novos recursos](videos/v19-assets.mp4).

O atlas antigo `hero_combat.png` foi preservado. A nova primeira pose tem altura visível97,18% da pose antiga de referência, mantendo a escala0,44 para o teste. A comparação em tamanho de jogo aparece na prévia. O registro nominal é(128,250); conferir contato de pé/espada ao integrar.

Portões: brilho do material visível, ponderado pelo alfa,76,10/255 no fechado e64,11/255 no aberto. Ambos atendem à faixa40–90 nessa medida; as médias sobre a tela inteira também estão no relatório,21,00 e1,11. O aberto é quase todo transparente, portanto média do retângulo inteiro não mede a cor do material. Essa interpretação e seus limites estão documentados.

## Validação realizada

- `python3 tools/check_animation_atlases.py`:83clipes do catálogo preservado, zero erros.
- `python3 tests/v19_assets_check.py`:mesmo verificador original numa fixture temporária para os quatro clipes novos,24quadros distintos/não vazios, dimensões/alfa e portões aprovados. Não modifica `clips.json`.
- Importação no Godot Standard4.6.3 concluída sem erro de script. Prévia do atlas, quadro2 parado, estados do portão e escala real inspecionados em1280×720; vídeo e folha de movimento gerados.
- Captura controlada da base sem erro de script, com aviso de ObjectDB no encerramento da ferramenta. Há também aviso de V-Sync indisponível no renderizador virtual. Esses avisos permanecem no [relatório das prévias](v19-previas-resultados.json); não são omitidos como uma aprovação irrestrita de execução.
- [Escopo e hashes](v19-escopo.json):467arquivos rastreados da base preservados. Não foi feita alteração de combate, câmera, sala, arma separada ou salvamento.

As prévias são ferramentas isoladas: o aparo ainda não é funcional por causa deste atlas, os portões não têm colisão nem descida programada e a espada separada atual deve ser ocultada/adaptada para evitar arma duplicada. Os estados dos dois portões compartilham estilo e origem, sem ser translação pixel a pixel. Falta encaixe arquitetônico e teste de bloqueio seguro.

## Próxima integração e limites

O Claude conecta os clipes a seus estados e regras, sincroniza contato/abertura/recuperação, resolve o comportamento da espada e liga os portões às colisões. A comparação propõe critérios para um encontro completo, não aprova o resultado integrado por antecipação. O autor precisa jogar e relatar se a resposta e a cena funcionam. Música, som, diversão e impacto emocional não foram validados por estes testes.

`Lacrimae-v19-Entregas-Codex.zip` reúne os novos arquivos para integrar sobre a base indicada. `Lacrimae-v19-Projeto-Godot.zip` contém a base e os acréscimos, ainda sem conectar automaticamente o novo combate ou os portões. Extrair e importar `project.godot` no Godot; a pasta de cache é recriada na primeira abertura.
