# Encerramento do Ato I

Arquivo: `assets/ending/ato1_portoes.png`, PNG RGB opaco, 1920×1080. Ilustração original gerada a partir do pátio e do atlas do Penitente como referências visuais. A imagem nativa de 1672×941 foi padronizada com Lanczos, conforme autorização anterior; isso não acrescenta detalhe nativo.

O Penitente está de costas, quase em silhueta, diante dos três painéis selados por correntes. Uma lanterna baixa concentra a luz; marcas de unhas ficam discretas nas pedras laterais. A escala dos portões faz o gesto humano parecer pequeno. Sem texto, criança ou rosto do protagonista. Os relevos religiosos são parte dos portões, obscurecidos pela sombra.

A primeira geração tinha fontes de luz extras e foi corrigida. Revisei visualmente a versão final: postura de costas, correntes, hierarquia de luz e faixa inferior escura. Os 160 pixels inferiores ficam reservados para legenda. `tools/review_v15_ending.gd` produz uma prévia em 1280×720 com frase de teste; a legenda não está gravada na arte nem foi adicionada ao roteiro.

Verificações automáticas: dimensão, opacidade e luminância média da faixa inferior em `docs/v15-assets-result.json`. Essa média não certifica contraste de qualquer tipografia. A captura de revisão permite conferir a frase de exemplo. Falta testar apresentação no fluxo real, monitores com brilho diferente e leitura com jogadores. A imagem ainda não está conectada à cena de encerramento: integração fica para o Claude, sem alterações de scripts nesta entrega.
