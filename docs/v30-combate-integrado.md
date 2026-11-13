# Versão 30 — cooperação e combate refinado

Integra o patch v30 recebido do autor com o refino de combate já entregue sobre a v29. Mantém comandos antecipados, defesa e salto na recuperação, ritmo dos três golpes, impacto curto, alcance da lança e bloqueio dos ataques por paredes.

O Penitente e Beatriz atuam juntos. Beatriz segue e combate por IA até o segundo jogador assumir seus controles; F4 devolve o controle à IA. O parceiro pode levantar quem caiu, e só há derrota quando ambos caem. Os controles estão em `v30-entrega.md`.

A integração usa `pressed`, `held` e `released` de cada personagem para separar as entradas. A direção da esquiva também é preservada para o jogador 2. A câmera mantém o deslocamento compartilhado durante a atualização física. Inimigos próximos coordenam ataques quando estão mirando o mesmo personagem.

Validação: 591 verificações funcionais em 13 suítes, incluindo 16 de cooperação, 23 de comandos e 339 de animação. Dados de teste isolados do salvamento pessoal. Alguns encerramentos acelerados do Godot em modo sem janela ainda emitem avisos de recursos de áudio; esses avisos são preservados nos registros, sem serem confundidos com falhas de script ou de verificação.

As limitações de arte da v30 permanecem: Beatriz ainda usa sua representação provisória. Os novos ganchos de som ficam inativos quando os WAV correspondentes não existem. Esta integração não afirma entregar as folhas de arte ou os sons ainda solicitados nos prompts do autor.
