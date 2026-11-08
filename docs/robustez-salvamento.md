# Robustez do salvamento — base v17

Cada fixture foi escrita e carregada pela rotina real `_start_game(true,false)`, em processo separado e dados descartáveis. Nenhum script de produção foi alterado. Um caso só passa se completa a carga, não emite erro de script nem erro de carga do engine e conserva um estado seguro; uma carga que recupera valores mas imprime erro ainda falha.

Critérios de sanidade da sonda: altar existente, sala conhecida, HP finito e positivo até o máximo, culpa0–100, eco0–99. Para detectar números absurdos, limites de triagem propostos: melhorias0–1000 e moeda0–1bilhão; esses limites não são uma decisão de balanceamento. O Claude precisa definir os tetos oficiais. A fixture válida verifica também moeda, altar, melhorias, eco e flag restaurados exatamente.

| Caso | Resultado | Saída | Observação |
|---|---|---:|---|
| valid | PASSOU | 0 | Estado seguro |
| legacy | PASSOU | 0 | Estado seguro |
| truncated | FALHOU | 0 | ERROR: Parse JSON failed. Error at line 0: Expected '}' |
| empty | FALHOU | 0 | ERROR: Parse JSON failed. Error at line 0: Unknown error getting token |
| extra_fields | PASSOU | 0 | Estado seguro |
| number_text | PASSOU | 0 | Estado seguro |
| number_list | FALHOU | 0 | SCRIPT ERROR: Invalid call. Nonexistent 'int' constructor. |
| negative_numbers | FALHOU | 1 | Estado fora dos limites de sanidade ou carga incompleta |
| absurd_numbers | FALHOU | 1 | Estado fora dos limites de sanidade ou carga incompleta |
| empty_lists | PASSOU | 0 | Estado seguro |
| wrong_exploration | FALHOU | 0 | SCRIPT ERROR: Invalid type in function 'restore' in base 'Node (exploration.gd)'. Cannot convert argument 1 from String to Dictionary. |
| wrong_stain | FALHOU | 0 | SCRIPT ERROR: Trying to assign value of type 'String' to a variable of type 'Array'. |
| array_root | PASSOU | 0 | Estado seguro |

Resultados completos em robustez-salvamento.json. Avisos de recursos ainda em uso apenas no encerramento não são classificados como falha de migração; erros de script e de parsing continuam sendo falhas.  São falhas observadas, não corrigidas: manter a proteção de scripts pedida. Recomendações ao integrador: validar tipos antes de conversões e chamadas tipadas; tratar JSON vazio/truncado sem erro não controlado; normalizar limites antes de calcular HP; aceitar campos desconhecidos e migrar campos ausentes. Não testar arquivos reais corrompendo o salvamento do autor.

Repetir: `XDG_DATA_HOME=/tmp/lacrimae-save-v17/data XDG_CONFIG_HOME=/tmp/lacrimae-save-v17/config XDG_CACHE_HOME=/tmp/lacrimae-save-v17/cache godot --headless --script res://tests/save_robustness_smoke.gd --path .`. Código0 significa todos os casos aprovados;1 indica falha medida;3 indica ambiente não isolado. JSON truncado e tipos inválidos podem imprimir erros intencionais nos filhos: o relatório os conserva, sem esconder. A simulação não testa queda de energia durante escrita, disco cheio, permissões ou todas as versões históricas de save.
