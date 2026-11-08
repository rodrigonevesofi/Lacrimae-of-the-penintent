# Auditoria de luminância da arte-chave

Medição do arquivo, antes de modulação, vinheta, zoom ou iluminação do Godot. Usa Y′ = 0,2126R + 0,7152G + 0,0722B em RGB codificado de 0 a255; é um indicador de brilho, não luminância física nem luminância relativa WCAG. Sem conversão linear ou simulação de monitor. Alfa, se houver, é composto sobre preto.

Inventário: todos os PNGs de memory/boss/ending, os fundos declarados em `act_one_layout.gd` e a abertura adicional. Sprites, atlas e objetos transparentes não são fundos de sala. O script não modifica imagens; confere seus hashes.

**Triagem:** rever média <12 ou ≥75% de pixels abaixo de12; conferir sombras se média <22 ou ≥50% abaixo de12. São limiares editoriais conservadores, não prova de perda num monitor específico. P95 alto pode vir de uma única lanterna e não garante correntes, personagens ou caminhos legíveis.

| Arquivo | Uso | Média /255 | P95 /255 | Pixels <12 | Triagem |
|---|---|---:|---:|---:|---|
| `assets/boss/guardiao_01_corda.png` | cena / boss | 30.32 | 100.21 | 35.4% | Sem alerta pelo critério |
| `assets/boss/guardiao_02_gesto.png` | cena / boss | 22.81 | 66.37 | 37.4% | Sem alerta pelo critério |
| `assets/boss/guardiao_03_imovel.png` | cena / boss | 7.11 | 25.88 | 85.8% | REVER: média <12 |
| `assets/cistern.png` | fundo de sala | 84.81 | 188.93 | 1.2% | Sem alerta pelo critério |
| `assets/cloister.png` | fundo de sala | 81.14 | 170.59 | 0.0% | Sem alerta pelo critério |
| `assets/ending/ato1_portoes.png` | cena / ending | 3.76 | 11.93 | 95.1% | REVER: média <12 |
| `assets/ending/ato1_portoes_v2.png` | cena / ending | 17.53 | 48.01 | 45.8% | Conferir sombras |
| `assets/gallery.png` | fundo de sala | 66.35 | 139.82 | 0.1% | Sem alerta pelo critério |
| `assets/gates.png` | fundo de sala | 72.69 | 123.82 | 0.0% | Sem alerta pelo critério |
| `assets/memory/memoria_01_maos_na_roda.png` | cena / memory | 35.15 | 88.95 | 22.4% | Sem alerta pelo critério |
| `assets/memory/memoria_02_mao_pequena.png` | cena / memory | 43.03 | 111.19 | 7.2% | Sem alerta pelo critério |
| `assets/memory/memoria_02_mao_pequena_sem_sol.png` | cena / memory | 44.10 | 114.15 | 4.5% | Sem alerta pelo critério |
| `assets/memory/memoria_03_figura_atras.png` | cena / memory | 47.96 | 170.58 | 14.3% | Sem alerta pelo critério |
| `assets/memory/memoria_04_portao_fechado.png` | cena / memory | 18.78 | 49.68 | 44.0% | Conferir sombras |
| `assets/nave_silencio.png` | fundo de sala | 66.88 | 153.68 | 1.3% | Sem alerta pelo critério |
| `assets/opening.png` | abertura (adicional) | 44.45 | 100.75 | 7.5% | Sem alerta pelo critério |
| `assets/ossuary.png` | fundo de sala | 60.46 | 127.32 | 0.0% | Sem alerta pelo critério |
| `assets/patio_portoes.png` | fundo de sala | 77.85 | 165.72 | 1.0% | Sem alerta pelo critério |
| `assets/terraco_sinos.png` | fundo de sala | 81.86 | 170.56 | 0.1% | Sem alerta pelo critério |
| `assets/tower.png` | fundo de sala | 59.07 | 134.43 | 0.7% | Sem alerta pelo critério |
| `assets/vespera_panorama.png` | fundo de sala | 62.99 | 131.88 | 0.1% | Sem alerta pelo critério |

## Como usar

Priorizar os itens marcados REVER: conferir em brilho comum, tela de celular e capturas reais do jogo, sem alterar o brilho global para compensar uma única cena. Comparar correntes, rostos/gestos, bordas de plataformas e saídas, além da média. O encerramento v1 permanece como referência; v2 é uma alternativa, ainda sem substituição automática na HUD. Fundos grandes são recortados pela câmera: a média do panorama inteiro pode esconder um trecho problemático.

Reproduzir: `python3 tests/luminance_audit.py`. Resultados completos e hashes em `auditoria-luminancia.json`. Não houve teste humano nem calibração de monitores.
