# Artes v18 e verificações sobre a base v17

**Esta entrega não contém a reconstrução de combate que o Claude propôs.** O patch v17 recebido foi aplicado sobre `bafb146` (versão16); depois foram criados somente arquivos novos. As tarefas técnicas da v17 e as artes da lista v18 foram trabalhadas juntas. O chefe medido continua com450HP e duas fases. Nenhum novo aparo, golpe forte, encontro em ondas ou perigo funcional foi integrado.

## O que foi criado

| Recurso | Entrega / estado |
|---|---|
|[Abismo da ponte](abismo-ponte.md)|PNG RGBA270×400, sem piso ao fundo, média21,40/255; prévia de sobreposição mostra também remendos antigos que o integrador precisa retirar|
|[Efeitos de combate](efeitos-combate.md)|24quadros: faíscas, sangue, anel de aparo e poeira|
|[Ícones de relíquias](reliquias-icones.md)|12peças e12versões bloqueadas, margem24px; não cria itens equipáveis|
|[Perigos de percurso](perigos-percurso.md)|24quadros: espinhos, plataforma que cai, plataforma suspensa e pilar; não cria suas colisões ou regras|
|[Guardião maior](guardiao-grande.md)|24poses de repouso, caminhada, ataque, dano e queda; corpo preenche a célula; registro fino dos pés/perfil descrito no documento|
|[Bronze imóvel mais legível](guardiao-imovel-v2.md)|PNG opaco1920×1080, média16,28/255 antes7,11; mão aberta e contornos mais visíveis|
|[Robustez do salvamento](robustez-salvamento.md)|13fixtures isoladas, seis aprovadas e **sete com falhas**; correções não implementadas|
|[Sonda do chefe](equilibrio-chefe.md)|Dez sementes com reação180–260ms e erro10%; todas venceram em15,15–19,93s, média17,86s|
|[Guia do autor](guia-do-autor.md)|Como abrir, jogar, entender pastas/documentos/testes e relatar problemas; fluxo autor/Claude/Codex e limites de validação|

As artes continuam sem ligação aos scripts de produção, conforme a regra recebida. O patch v17 já conecta o encerramento v2 da entrega anterior e deixa os ganhos de mixagem em0; a nova proposta não aplica o ajuste de áudio sem audição. Os12 arquivos protegidos e todos os assets preexistentes estão preservados em relação à base recebida: [v18-escopo.json](v18-escopo.json).

## Evidência visual

- [Vídeo dos atlas no Godot](videos/v18-atlas-previa.mp4),8segundos, H.2641280×720, sem áudio. É uma ferramenta de revisão, com escala e registro de teste; não é gameplay da luta reconstruída.
- [Quadros do movimento](imagens/v18-atlas-movimento.png).
- [Abismo sobreposto na cena existente](imagens/v18-abismo.png).
- [Bronze imóvel com legenda de leitura](imagens/v18-bronze.png).

As capturas foram inspecionadas. A ponte ainda mostra triângulos lisos nas bordas e término do fundo da base: precisam de tratamento na integração. O atlas do Guardião está em três quartos, com pequena variação do contato dos pés; a prévia usa os deslocamentos registrados no JSON para um pivô nominal(128,250). Confirmar perfil estrito, registro, contato do ataque e margens antes de conectá-lo ao animador. Esses limites não são escondidos pelo verificador.

## Verificações

Godot Standard4.6.3/Linux, dados de usuário temporários.

| Verificação | Resultado |
|---|---|
|Regressão da base v17: imersão, capítulo, contrato de pulsos, interface/persistência, bestiário e checkpoints|Seis suítes,189verificações, zero falhas|
|Verificador original de atlas, sem editar catálogo|13clipes aprovados em fixture temporária:72quadros distintos/não vazios|
|`tests/v18_art_check.py`|Dimensões, RGBA,24ícones com margem, pares bloqueados mais escuros, faixas de brilho e opacidade aprovados|
|`tests/save_robustness_smoke.gd`|13casos, sete falhas reais de robustez; código final1, não aprovação|
|`tests/balance_probe_boss.gd`|10tentativas completas, nenhum erro de script; resultados não aprovam equilíbrio|
|Editor Godot|Importação dos novos recursos concluída sem erro de script|
|Prévias Godot|Geradas; avisos técnicos de renderização/encerramento registrados em `v18-previas-resultados.json`|

Detalhes em [v18-testes.json](v18-testes.json), [v18-arte-medidas.json](v18-arte-medidas.json), [robustez-salvamento.json](robustez-salvamento.json) e [equilibrio-chefe.json](equilibrio-chefe.json). `python3 tests/v18_art_check.py` usa Pillow/numpy e executa uma cópia byte a byte do verificador original numa pasta temporária, com um catálogo só para os novos atlas. Não altera `assets/animation/clips.json`.

## Problemas para a próxima integração

1. **Salvamento:** vazio/truncado imprime erro de parsing; listas em campo numérico e tipos inválidos em exploração/mancha produzem erro de script; números negativos/absurdos passam e podem produzir HP negativo ou moeda inválida. O carregador precisa validar tipos e limites antes de aplicar dados. A fixture antiga e os campos desconhecidos passaram. Os tetos de triagem da sonda são propostas, não limites oficiais de economia.
2. **Chefe:** a política simples venceu rapidamente mesmo com atraso e chance de erro. Isso sustenta revisar a luta; não transforma90–120s em meta automática de qualidade. Usar os acertos por tipo/fase e repetir a mesma sonda após a reconstrução, além de jogar.
3. **Ponte e registro:** retirar o remendo antigo, acertar a câmera e conectar o PNG; no chefe, revisar pivô, escala, colisão e HUD conjuntamente. Não basta trocar uma textura.
4. **Efeitos, ícones e perigos:** conectar aos estados corretos, criar regras e feedback acessível, conferir tamanho real da HUD e timing. Uma folha de arte não implementa aparo, relíquias ou plataforma móvel.

Não houve playtest humano, audição contextual, certificação fotossensível ou prova de qualidade equivalente a Blasphemous. A simulação e a revisão visual ajudam a encontrar defeitos, mas não demonstram que o jogo prende. O Ato II não foi iniciado.

## Pacotes

`Lacrimae-v18-Entregas-Codex.zip`: somente novos recursos, testes, relatórios e guia para o Claude integrar sobre a base v17. `Lacrimae-v18-Projeto-Godot.zip`: projeto completo com patch v17 e esses acréscimos, **ainda sem o novo combate e sem conexão automática das artes v18**. Extrair em pasta limpa e importar `project.godot`; não sobrepor uma pasta antiga sem comparar a versão.
