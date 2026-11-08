# Acessibilidade das cenas de culpa

Checagem funcional e conservadora, não certificação de acessibilidade nem teste com pessoas surdas/fotossensíveis. As três variantes do eco, memorial e memória foram examinadas.

| Cena | Item | Resultado | Evidência/limite |
|---|---|---|---|
| echo0 | flashes | PASSOU | Picos brancos observados em60Hz: [2.21666666666667, 2.86666666666667, 3.51666666666667]; máximo por janela1s=2 |
| echo0 | batidas | PASSOU | Três pulsos visuais e legenda que informa três batidas. |
| echo0 | mínimo | PASSOU | Interação anterior ao tempo mínimo preserva a cena. |
| echo0 | pular | PASSOU | Interação após mínimo encerra a cinemática; memorial pode abrir seu registro legível separado. |
| echo1 | flashes | PASSOU | Picos brancos observados em60Hz: []; máximo por janela1s=0 |
| echo1 | vozes | PASSOU | Voz abstrata acompanhada por fala escrita de echo_line. |
| echo1 | mínimo | PASSOU | Interação anterior ao tempo mínimo preserva a cena. |
| echo1 | pular | PASSOU | Interação após mínimo encerra a cinemática; memorial pode abrir seu registro legível separado. |
| echo2 | flashes | PASSOU | Picos brancos observados em60Hz: []; máximo por janela1s=0 |
| echo2 | vozes | PASSOU | Voz abstrata acompanhada por fala escrita de echo_line. |
| echo2 | mínimo | PASSOU | Interação anterior ao tempo mínimo preserva a cena. |
| echo2 | pular | PASSOU | Interação após mínimo encerra a cinemática; memorial pode abrir seu registro legível separado. |
| memorial | flashes | PASSOU | Picos brancos observados em60Hz: []; máximo por janela1s=0 |
| memorial | sino | FALHOU | Não foi encontrado equivalente explícito para a badalada inicial. Zoom/título sinalizam a cena, mas não identificam um sino. Revisar se o som é apenas atmosférico ou informação essencial. |
| memorial | mínimo | PASSOU | Interação anterior ao tempo mínimo preserva a cena. |
| memorial | pular | PASSOU | Interação após mínimo encerra a cinemática; memorial pode abrir seu registro legível separado. |
| memory | flashes | PASSOU | Picos brancos observados em60Hz: [24.6166666666667, 25.2666666666667, 25.9166666666667]; máximo por janela1s=2 |
| memory | batidas | PASSOU | Cada batida final aciona um pulso branco; contagem visual três. |
| memory | vozes | PASSOU | Legenda menciona vozes; montagem também escreve Abra/Ainda estamos aqui. |
| memory | sino | FALHOU | Não foi encontrado equivalente explícito para a badalada inicial. Zoom/título sinalizam a cena, mas não identificam um sino. Revisar se o som é apenas atmosférico ou informação essencial. |
| memory | mínimo | PASSOU | Interação anterior ao tempo mínimo preserva a cena. |
| memory | pular | PASSOU | Interação após mínimo encerra a cinemática; memorial pode abrir seu registro legível separado. |

Pendências: badaladas iniciais de memorial e memória não têm legenda explícita nem sino animado identificável na camada de cena. O título e o foco visual comunicam a entrada na cena, mas não o timbre/evento específico. Se esses sons forem considerados essenciais, acrescentar descrição como [badalada abafada] ou equivalente visual identificável. Se forem apenas ambientação, essa classificação precisa ser uma decisão editorial registrada. Nenhum script protegido foi alterado para corrigir isso.

Flashes: contador observa elevações da propriedade flash com amostragem60Hz e calcula o máximo em janelas móveis de1s. Não analisa luminância de cada pixel, área luminosa, contraste vermelho, efeitos fora da cena ou queda de quadros. Não comprova conformidade com WCAG nem segurança para todas as pessoas. Legendas foram verificadas por vínculo textual/estado, não por contraste, velocidade de leitura ou tamanho em todos os monitores. A soma de som, luz e legenda deve ser avaliada por pessoas.

Repetir com dados descartáveis: `XDG_DATA_HOME=/tmp/lacrimae-a11y-data XDG_CONFIG_HOME=/tmp/lacrimae-a11y-config XDG_CACHE_HOME=/tmp/lacrimae-a11y-cache godot --headless --path . --script res://tests/accessibility_scenes_check.gd`. O teste termina com código1 quando encontra pendências; isso é esperado nesta base.
