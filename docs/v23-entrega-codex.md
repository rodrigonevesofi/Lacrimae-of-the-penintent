# Entrega Codex — versão 23

Base: commit `6446088` (versão 22), atualizado pelo patch `mudancas-v23-sobre-versao-do-codex.patch` fornecido pelo autor. O patch passou em `git apply --check` e foi aplicado integralmente. As mudanças em código e clips.json vêm exclusivamente desse patch; a produção de arte acrescenta arquivos novos.

## Recursos

| Arquivo | Formato | Folha de contato |
| --- | --- | --- |
| `assets/close/close_01_mascarado.png` | 512 × 512, opaco | [Close](contatos-v23/close.png) |
| `assets/animation/onda_grito.png` | 1536 × 512, RGBA, 6 × 2 células de 256 × 256 | [Onda](contatos-v23/onda.png) |
| `assets/rachadura_chao.png` | 512 × 128, RGBA | [Rachadura](contatos-v23/rachadura.png) |

O close usa o close original como referência de paleta e textura, substituindo todo o rosto por metal fechado, coroa de espinhos, sangue e fenda escura. O original permanece no repositório. Não foram introduzidos personagens nem revelações narrativas.

A onda parte de um anel gerado, recortado e montado em seis escalas crescentes com centros fixos e margens transparentes. A segunda linha repete as escalas com alpha multiplicado por 0,45, para um eco mais fraco. Ordem: esquerda para direita; linha superior, depois inferior. A folha não define FPS nem ligação ao ataque; isso cabe à integração.

## Verificação

- `python tests/v23_assets_check.py`: verifica PNG, dimensões, RGB opaco no close, RGBA com transparência nos efeitos, 12 quadros não vazios, margens, expansão crescente e eco mais fraco. Medidas em [v23-assets-verificacao.json](v23-assets-verificacao.json).
- Godot 4.6.3: `tests/story_decisions_check.gd`, **3 verificações, zero falhas**.
- Godot 4.6.3: `tests/combat_smoke.gd`, **41 verificações, zero falhas**. Ao encerrar, o motor informou instâncias ObjectDB vazadas e um recurso ainda em uso; não foi corrigido nesta entrega de arte.
- Inspeção visual das imagens e folhas: close sem rosto visível, onda em seis escalas com eco, rachadura isolada.

No ambiente em nuvem, executar Godot com diretórios graváveis: `XDG_DATA_HOME=/tmp/v23-godot-data XDG_CACHE_HOME=/tmp/v23-godot-cache XDG_CONFIG_HOME=/tmp/v23-godot-config godot --headless --path . --script tests/combat_smoke.gd`. Criar esses diretórios antes. A primeira tentativa com os diretórios padrão falhou por falta de permissão no diretório pessoal; os testes acima foram repetidos com os diretórios temporários.

## O que não foi validado

Os três assets não estão ligados ao jogo: a integração fica com Claude, conforme o pedido. Não validados em gameplay: encaixe da onda na boca do sino, FPS, duração, transição entre linhas, posicionamento da rachadura, escala, legibilidade durante combate, câmera do close e impacto emocional. A inspeção visual não substitui a aprovação artística do autor. Não foi executada a suíte completa; foram rodados os dois testes focados nas alterações do patch, além do verificador dos assets.
