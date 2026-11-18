# Prompt para o Codex — versão 43 (retorno do professor)

Cole o texto abaixo no Codex, anexando `v43-somente-o-que-mudou.zip` (ou os três pacotes `Lacrimae-of-the-penintent-v43-*.zip`).

---

Você está no repositório `rodrigonevesofi/Lacrimae-of-the-penintent`. A versão 43 responde ao retorno do professor:
- personagens que se destacam do cenário;
- mixagem refeita;
- golpes novos e aparo mais justo;
- seis execuções que desmembram;
- teclas mostradas no mundo;
- oferendas e relíquias para crescer;
- Beatriz com os mesmos golpes;
- lágrimas que voam até a bolsa.

Faça as tarefas abaixo nesta ordem. Não reduza o sangue, não troque a arte do Penitente e não altere textos de história.

## Tarefa 1 — Publicar a versão 43 no ramo `main` (obrigatória)

1. Aplique `v43-somente-o-que-mudou.zip` por cima da versão 42 que está no `main`, ou extraia os três pacotes completos na mesma pasta. Em caso de diferença, vale o arquivo do pacote.
2. Confirme que `ia_local.cfg` e `override.cfg` **não** existem no repositório. Se houver qualquer chave de API em algum arquivo, pare e avise.
3. Abra o projeto no Godot 4.6.3 e deixe importar. Depois rode, sem janela:
   - `tests/v43_smoke.gd`
   - `tests/v43_beatriz_smoke.gd`
   - `tests/combat_rich_smoke.gd`
   - `tests/penitence_smoke.gd`
   - `tests/chapter_smoke.gd`
   - `tests/story_decisions_check.gd`
   - `tests/confessor_smoke.gd`

   Todos devem passar. Rode com pastas de dados descartáveis: `XDG_DATA_HOME`, `XDG_CONFIG_HOME` e `XDG_CACHE_HOME` apontando para uma pasta temporária.
4. Faça o commit "versão 43: personagens destacados, mixagem, golpes novos, execuções, oferendas" e publique no `main`.
5. Informe o link do commit e o resultado dos sete testes.

## Tarefa 2 — Executável para Windows (se houver tempo)

1. Exporte para Windows com o modelo "Windows Desktop" do Godot 4.6.3, com o `.pck` embutido.
2. Publique como **Release** com o nome "Lacrimae of the Penitent — versão 43".
3. Na descrição, repita a instrução da IA que estava na versão 42: criar `ia.cfg` em `%APPDATA%\Godot\app_userdata\Lacrimae of the Penitent\`.
4. Se a exportação falhar, relate o erro e não insista.

## Tarefa 3 — Quadros desenhados para os golpes novos (opcional)

Hoje os golpes novos reaproveitam quadros antigos, com rastro e efeitos novos por cima. O código já procura quadros próprios: se um clipe com o nome abaixo existir em `assets/animation/clips.json`, para o ator `hero` (o Penitente) ou `beatriz`, ele é usado no lugar do antigo. Não é preciso mexer no código.

| Clipe | Golpe | Quadros | Pose-chave |
|---|---|---|---|
| `golpe_contracorte` | 2º da sequência | 6 | Corte de volta, da esquerda para a direita, na altura do peito |
| `golpe_estocada` | 3º da sequência | 6 | Estocada reta à frente, corpo inclinado, braço estendido |
| `golpe_descendente` | 4º, o arremate | 7 | A arma sobe acima da cabeça e desce com força até o chão |
| `golpe_ascendente` | Toque no pesado | 6 | Agachado, a arma sobe de baixo para cima e termina acima da cabeça |
| `golpe_investida` | Ataque saindo da esquiva | 6 | Avanço baixo, a arma à frente, capa esvoaçando para trás |
| `golpe_aereo2` | 2º golpe no ar | 5 | Giro no ar, corte horizontal |
| `golpe_prece` | Lâmina de Sangue | 6 | A arma traça uma meia-lua à frente; a mão livre sobre o peito |

**Regras da arte:**
- Mesmo desenho, proporção, paleta e iluminação das folhas atuais: `assets/animation/hero_combat.png` e `hero_combate.png` para o Penitente, e `beatriz_combate.png` para Beatriz.
- Mesma grade: células de 256 × 256 px, fundo transparente, âncora nos pés em (128, 250). Use a mesma entrada de `clips.json` dos clipes atuais (`sheet`, `start`, `count`, `fps`, `loop: false`, `anchor`).
- A espada do Penitente e a lança de Beatriz devem caber inteiras na célula.
- O rosto do Penitente **não aparece**: ele usa o capacete em todos os quadros. Beatriz mantém o rosto atual.
- Arte original. Não copie sprites, poses ou personagens de outros jogos.

Depois de acrescentar os quadros, rode `tests/animation_smoke.gd`, `tests/v43_smoke.gd` e `tests/v43_beatriz_smoke.gd`.

## Não faça

- Não reduza o sangue nem as execuções.
- Não troque a arte do Penitente e não mostre o rosto dele fora da cena final.
- Não chame o chefe final de "Penitente": o nome é **O FLAGELADO**.
- Não diga quem deu a ordem de fechar os portões: isso fica para depois.
- Não use crianças como criaturas ou vítimas.
- Não cite os outros atos no README além do gancho que já está lá.
