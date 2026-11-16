shader_type canvas_item;
render_mode unshaded;
// Pintura viva: faz a pintura de uma sala se mexer sem repintá-la.
// As máscaras (tools/gerar_mascaras_vivas.py) dizem o que é pano, água, céu, chama e vitral.
//   marcas_a  R = pano     G = água   B = céu
//   marcas_b  R = chama    G = halo   B = vitral ou luz fria
// O que se move: panos e hera ao vento, jorros caindo, a lâmina d'água ondulando, nuvens passando,
// chamas tremendo com o seu halo e a luz dos vitrais respirando.

uniform sampler2D marcas_a : filter_linear, repeat_disable;
uniform sampler2D marcas_b : filter_linear, repeat_disable;
uniform vec2 texel = vec2(0.001, 0.001);   // tamanho de um ponto da pintura, em UV
uniform float tempo = 0.0;
uniform float vento = 1.0;                 // força do vento da sala
uniform float rajada = 0.0;                // sopro extra de um golpe forte por perto
uniform float rajada_x = 0.5;              // onde, em UV, o sopro nasceu
uniform float pulso = 1.0;                 // 0 com "reduzir pulsos": nada pisca
uniform float chuva = 0.0;                  // chove do lado de fora: fios caem sobre o céu
uniform float clarao = 0.0;                // relâmpago: clareia o céu
uniform float faixa_agua = 2.0;            // abaixo deste V a água é lâmina parada; acima dele, jorro
uniform vec3 cor_halo : source_color = vec3(1.0, 0.62, 0.28);
uniform vec3 cor_clarao : source_color = vec3(0.62, 0.70, 0.95);

float acaso(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float ruido(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(acaso(i), acaso(i + vec2(1.0, 0.0)), f.x), mix(acaso(i + vec2(0.0, 1.0)), acaso(i + vec2(1.0, 1.0)), f.x), f.y);
}

float nuvens(vec2 p) {
	return ruido(p) * 0.55 + ruido(p * 2.1 + 7.3) * 0.30 + ruido(p * 4.3 + 1.7) * 0.15;
}

void fragment() {
	vec2 ponto = UV / texel;               // posição em pontos da pintura
	vec3 a = texture(marcas_a, UV).rgb;
	vec3 b = texture(marcas_b, UV).rgb;
	vec2 desvio = vec2(0.0);

	// ---- panos e hera: ondas que descem pelo tecido; o vento chega em sopros que atravessam a sala.
	float sopro = 0.55 + 0.45 * sin(tempo * 0.37 + UV.x * 5.0);
	float perto = rajada * smoothstep(0.30, 0.0, abs(UV.x - rajada_x));
	float onda = sin(tempo * 1.9 + ponto.y * 0.085 + sin(ponto.x * 0.031) * 2.0) * 0.62 + sin(tempo * 3.3 + ponto.y * 0.19 + ponto.x * 0.023) * 0.38;
	desvio.x += onda * a.r * (2.3 * sopro * vento + 3.4 * perto);
	desvio.y += cos(tempo * 1.4 + ponto.x * 0.05) * a.r * 0.5 * vento;

	// ---- água: o jorro treme de lado enquanto cai; a lâmina parada ondula devagar.
	float lamina = step(faixa_agua, UV.y);
	desvio.x += a.g * mix(sin(ponto.y * 0.55 - tempo * 11.0) * 0.9, sin(ponto.y * 1.9 + tempo * 1.6 + sin(ponto.x * 0.02 + tempo * 0.5) * 2.0) * 2.2, lamina);

	// ---- céu: as nuvens se deformam devagar.
	vec2 fluxo = vec2(ruido(ponto * 0.012 + vec2(tempo * 0.045, 0.0)), ruido(ponto * 0.012 + vec2(11.0, tempo * 0.03))) - 0.5;
	desvio += fluxo * a.b * 7.0;

	vec4 cor = texture(TEXTURE, UV + desvio * texel);

	// ---- céu: sombras de nuvem passam; o relâmpago clareia tudo.
	float sombra = nuvens(vec2(ponto.x * 0.006 - tempo * 0.022, ponto.y * 0.011));
	cor.rgb *= mix(1.0, 0.80 + 0.42 * sombra, a.b);
	cor.rgb += cor_clarao * a.b * clarao * 0.55;

	// ---- chuva: fios inclinados caem só onde há céu, isto é, do lado de fora dos arcos.
	vec2 pc = vec2(ponto.x + ponto.y * 0.22, ponto.y);
	float coluna = floor(pc.x / 3.0);
	float queda = fract(pc.y * 0.012 - tempo * (1.5 + acaso(vec2(coluna, 1.0)) * 0.9) + acaso(vec2(coluna, 7.0)));
	float fio = step(0.80, acaso(vec2(coluna, 3.0))) * smoothstep(0.78, 1.0, queda);
	cor.rgb += vec3(0.62, 0.72, 0.88) * fio * a.b * chuva * (0.30 + 0.5 * clarao);

	// ---- água: riscos claros descem pelo jorro; brilhos correm pela lâmina.
	float risco = ruido(vec2(ponto.x * 0.9, ponto.y * 0.14 - tempo * 6.5));
	float brilho = pow(ruido(vec2(ponto.x * 0.16 + tempo * 0.35, ponto.y * 1.3 - tempo * 0.22)), 5.0);
	cor.rgb += a.g * mix(vec3(0.75, 0.92, 1.0) * (risco - 0.42) * 0.55, vec3(0.85, 1.0, 0.92) * brilho * 0.9, lamina);

	// ---- chamas: cada região treme por conta própria, e o halo acompanha.
	vec2 q = ponto * 0.028;
	float treme = ruido(q + vec2(0.0, tempo * 5.2)) * 0.6 + ruido(q * 1.7 - vec2(tempo * 4.1, 0.0)) * 0.4;
	float lento = 0.5 + 0.5 * sin(tempo * 0.9 + ponto.x * 0.004);
	float chama = mix(1.0, 0.66 + 0.60 * treme + 0.08 * lento, pulso);
	cor.rgb *= mix(1.0, chama, b.r);
	cor.rgb += cor_halo * b.g * (0.05 + 0.20 * (chama - 0.62)) * (1.0 - b.r * 0.6);

	// ---- vitrais e luz fria: a claridade respira, como se a neblina passasse lá fora.
	float nevoa = ruido(vec2(ponto.x * 0.02 + tempo * 0.12, ponto.y * 0.03 - tempo * 0.05));
	cor.rgb *= 1.0 + b.b * (0.26 * (nevoa - 0.5) + 0.07 * sin(tempo * 0.7 + ponto.x * 0.01)) ;
	cor.rgb += cor_clarao * b.b * clarao * 0.35;

	COLOR = cor * COLOR;
}
