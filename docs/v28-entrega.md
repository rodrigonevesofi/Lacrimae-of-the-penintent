# Entrega v28 — combate mais rico, portões marcados, modo dev

Resposta ao feedback do professor (combate "só bater"; portões que não se distinguem do cenário; navegar pelos mapas na apresentação).

## Combate
- **Combo de três golpes:** os dois primeiros alternam; o **terceiro**, se vier logo em seguida, é o **arremate** (animação de golpe forte, avanço, 34 de dano, lança o inimigo para trás e para cima). Parar um instante recomeça a cadeia.
- **Golpe carregado (segure I):** o Penitente prepara a espada; com carga completa, um clarão dourado avisa. Ao soltar: arco grande, 48 de dano (62 com carga completa), **quebra a resistência**, arremessa e **quebra o caixão do Carregador de uma vez**.
- **Golpe descendente (↓ + J no ar):** cai em linha reta; ao tocar o chão, onda de poeira que atinge e arremessa o que estiver em volta.
- **Câmera lenta** por um instante no arremate que mata, no golpe carregado que acerta e no golpe mortal das execuções.
- Continuam: aparo e contra-ataque forte, execuções com sangue, resistência a interrupção.
Testes: `tests/combat_rich_smoke.gd` (10 verificações).

## Portões e passagens
Cada passagem tem agora um **arco aceso** sobre a abertura, luz no limiar e um **sinal** acima: **dourado** quando abre, **vermelho** quando está trancada. Funciona em qualquer sala, com qualquer textura de fundo.

## Modo dev (F3)
- **↑ ↓** escolhe a sala, **ENTER** vai até ela (entra pela primeira passagem da sala).
- **G** invencível, **N** voar (atravessa paredes; ESPAÇO sobe, ↓ desce), **B** vai à arena do chefe.
- O painel mostra a sala atual e a posição. **F3** de novo desliga tudo.
Teste: `tests/dev_mode_smoke.gd` (todas as 10 salas alcançadas pelo menu).

Captura: [v28-portoes-dev-golpe.png](imagens/v28-portoes-dev-golpe.png).

## Limites
Os números do combate novo são pontos de partida; nada foi jogado por pessoas.
