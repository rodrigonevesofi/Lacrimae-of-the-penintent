# Entrega Codex — versão 24

Base: `ae8e96c` (versão 23), com aplicação integral do patch v24 fornecido pelo autor. As alterações em scripts e clips.json são exclusivamente as do patch. A produção de arte acrescenta arquivos novos.

## Imagens

- `assets/memoria_fogo/guardiao_fogo_01.png`: homem sem rosto suspenso pelas mãos na corda do sino, usando o peso do corpo.
- `assets/memoria_fogo/guardiao_fogo_02.png`: lâmina cortando a corda; mão ainda fechada. Não identifica quem segura a lâmina.
- `assets/memoria_fogo/guardiao_fogo_03.png`: homem de joelhos coberto pelo bronze fundido do sino.
- `assets/close/close_04b_grito.png`: variação de close_04, com boca aberta em grito, preservando sino, correntes, bronze oxidado e lágrima dourada.

Memórias: 1920 × 1080, PNG opaco, silhuetas gráficas negras em laranja e vermelho. Faixa inferior de 160 px mais escura para legendas. Close: 512 × 512 opaco, textura pontilhada baseada diretamente no original. Nenhuma imagem nomeia ou identifica Edran, a Inquisidora ou o Penitente.

Folhas de contato: [memórias](contatos-v24/memorias.png) e [close](contatos-v24/close.png).

## Verificação

`python tests/v24_assets_check.py` verifica formato, dimensões, opacidade e luminância da faixa inferior comparada à cena. Medidas em `docs/v24-assets-verificacao.json`. A inspeção visual verifica os assuntos e a ausência de rostos nas memórias; o teste automático não reconhece personagens.

Godot 4.6.3, após importação dos assets: `tests/story_decisions_check.gd` passou com 4 verificações; `tests/combat_smoke.gd` passou com 44 verificações. O teste de combate ainda emite aviso de instâncias ObjectDB vazadas ao encerrar. A primeira execução, anterior à importação, falhou ao carregar os PNGs da v23. Incluídos seus metadados `.import`; a pasta `.godot` não é versionada.

Para reproduzir no ambiente em nuvem, criar diretórios graváveis e executar:

```sh
mkdir -p /tmp/v24-data /tmp/v24-cache /tmp/v24-config
export XDG_DATA_HOME=/tmp/v24-data XDG_CACHE_HOME=/tmp/v24-cache XDG_CONFIG_HOME=/tmp/v24-config
godot --headless --path . --editor --import
godot --headless --path . --script tests/story_decisions_check.gd
godot --headless --path . --script tests/combat_smoke.gd
python tests/v24_assets_check.py
```

## Limites

As novas memórias e o close não estão ligados à cena: Claude fará o encontro de história. Não validados: montagem temporal, transições de câmera, tamanho e contraste de legendas reais, tempo de leitura, efeito emocional, desempenho durante a cena ou aprovação artística do autor. O verificador mede luminosidade média, não garante legibilidade de qualquer texto. As memórias são quadros estáticos; continuidade exata do desenho do homem entre planos depende de revisão artística. Não foi executada a suíte completa do projeto.
