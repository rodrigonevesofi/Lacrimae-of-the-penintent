# Entrega v33

Registro recebido do autor. O patch enviado contém scripts e textos; os recursos efetivamente preparados e publicados nesta integração, com novas artes autorizadas, estão em [v33-integracao.md](v33-integracao.md).

**Base:** a "versão 32" do Codex, que já contém toda a v32 do Claude mais o refinamento de combate dele (comandos guardados durante a pausa de impacto, cancelamentos na recuperação, contra-ataque imediato depois do aparo, três ritmos de combo, carga variável, bloqueio por paredes) e as quatro folhas de Beatriz repintadas no tom do Penitente atual. Testada no Godot 4.6.3: a suíte inteira passa.

**Acrescentado nesta entrega:**
- **Impactos por material**: faíscas em armadura (Guardião, Devorador), lascas de pedra no caixão do Carregador e no golpe descendente, osso no golpe descendente dentro do Ossuário, sangue na carne. Teste: `tests/impact_material_smoke.gd`. [Contato das faíscas](contatos-v33/contato-impacto-faiscas.png).
- O pacote completo descrito pelo autor também inclui close de Beatriz, capturas e folhas de referência. Esses binários ficam fora do patch; os recursos desta integração estão relacionados no documento acima.
- As folhas do Penitente feitas pelo Argon servem de referência de movimento. A integração mantém o Penitente atual e acrescenta as execuções adaptadas ao seu estilo.

**Do envio do autor:** os 11 sons "sem zumbido" já estavam no jogo (idênticos byte a byte aos que o Codex integrou). `beatriz_peso.jpg` não entrou: a imagem não segue a grade (três poses grandes e uma fileira pequena); a mecânica do peso continua funcionando sem ela.
