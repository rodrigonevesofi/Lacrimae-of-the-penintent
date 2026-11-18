shader_type canvas_item;
render_mode unshaded;

// Destaca um personagem do cenário pintado, como nos jogos de ação 2D góticos:
//  - contorno escuro em volta da silhueta (o corpo nunca se mistura com a parede);
//  - luz de borda do lado da luz (cima e esquerda), com a cor de cada personagem;
//  - um pouco mais de contraste e de cor que o cenário, que fica mais apagado (pintura_viva, "recuo");
//  - aura clara opcional para quem não é inimigo (Iria).
// O desenho vem de uma célula de uma folha maior: frame_bounds limita a amostragem à célula.

uniform vec4 frame_bounds = vec4(0.0, 0.0, 1.0, 1.0);
uniform vec3 cor_contorno : source_color = vec3(0.05, 0.03, 0.03);
uniform float contorno : hint_range(0.0, 1.0) = 0.9;
uniform float raio = 5.0;                 // espessura do contorno, em pontos da folha
uniform vec3 cor_borda : source_color = vec3(1.0, 0.78, 0.45);
uniform float borda : hint_range(0.0, 2.0) = 0.5;
uniform vec2 luz = vec2(-0.6, -0.8);      // de onde vem a luz
uniform float realce : hint_range(0.8, 1.6) = 1.15;
uniform float saturacao : hint_range(0.5, 1.6) = 1.1;
uniform float brilho : hint_range(0.6, 1.6) = 1.05;
uniform vec3 cor_aura : source_color = vec3(1.0, 0.95, 0.82);
uniform float aura : hint_range(0.0, 1.0) = 0.0;
uniform float raio_aura = 22.0;
// Clarão ao ser atingido: a silhueta inteira pisca numa cor clara por um instante.
uniform float clarao : hint_range(0.0, 1.0) = 0.0;
uniform vec3 cor_clarao : source_color = vec3(1.0, 0.95, 0.88);

varying vec4 cor_vertice;

void vertex() {
	cor_vertice = COLOR;
}

// 1 dentro da célula do quadro, 0 fora (não lê o quadro vizinho da folha).
float dentro(vec2 uv, vec2 px) {
	vec2 lo = frame_bounds.xy + px * 0.5;
	vec2 hi = frame_bounds.zw - px * 0.5;
	return (uv.x < lo.x || uv.y < lo.y || uv.x > hi.x || uv.y > hi.y) ? 0.0 : 1.0;
}

void fragment() {
	vec4 tinta = texture(TEXTURE, UV);
	vec2 px = TEXTURE_PIXEL_SIZE;

	// Cor: contraste e saturação um pouco acima do cenário.
	float lum = dot(tinta.rgb, vec3(0.2126, 0.7152, 0.0722));
	vec3 cor = mix(vec3(lum), tinta.rgb, saturacao);
	cor = (cor - 0.42) * realce + 0.42;
	cor *= brilho;

	// Luz de borda: o ponto é do corpo, mas logo ao lado, na direção da luz, já é vazio.
	vec2 dir = normalize(luz);
	float vazio_luz = 1.0 - (texture(TEXTURE, UV + dir * px * raio * 1.1).a * dentro(UV + dir * px * raio * 1.1, px));
	float vazio_luz2 = 1.0 - (texture(TEXTURE, UV + dir * px * raio * 0.55).a * dentro(UV + dir * px * raio * 0.55, px));
	float aro = clamp(max(vazio_luz, vazio_luz2 * 0.7), 0.0, 1.0) * step(0.35, tinta.a);
	cor += cor_borda * aro * borda * (0.45 + 0.55 * smoothstep(0.05, 0.6, lum));

	// Contorno: o ponto é vazio, mas algum vizinho próximo é corpo.
	float vizinho = 0.0;
	for (int i = 0; i < 8; i++) {
		float a = float(i) * 0.785398;
		vizinho = max(vizinho, (texture(TEXTURE, UV + vec2(cos(a), sin(a)) * px * raio).a * dentro(UV + vec2(cos(a), sin(a)) * px * raio, px)));
	}
	float linha = clamp(vizinho - tinta.a, 0.0, 1.0) * contorno;

	// Aura: claridade suave fora da silhueta (só Iria).
	float halo = 0.0;
	if (aura > 0.0) {
		for (int i = 0; i < 12; i++) {
			float a = float(i) * 0.523599;
			halo += (texture(TEXTURE, UV + vec2(cos(a), sin(a)) * px * raio_aura).a * dentro(UV + vec2(cos(a), sin(a)) * px * raio_aura, px));
			halo += (texture(TEXTURE, UV + vec2(cos(a + 0.26), sin(a + 0.26)) * px * raio_aura * 0.55).a * dentro(UV + vec2(cos(a + 0.26), sin(a + 0.26)) * px * raio_aura * 0.55, px)) * 0.6;
		}
		halo = clamp(halo / 12.0, 0.0, 1.0) * aura * (1.0 - tinta.a);
	}

	float alfa_final = tinta.a + linha * (1.0 - tinta.a);
	vec3 final_rgb = mix(cor_contorno, clamp(cor, 0.0, 1.0), tinta.a / max(alfa_final, 0.0001));
	vec4 saida = vec4(final_rgb, alfa_final);
	// A aura fica por baixo do contorno e some onde já há corpo ou linha.
	float a_halo = halo * (1.0 - saida.a) * 0.75;
	saida.rgb = mix(cor_aura, saida.rgb, saida.a / max(saida.a + a_halo, 0.0001));
	saida.a = saida.a + a_halo;
	saida.rgb = mix(saida.rgb, cor_clarao, clarao * step(0.05, tinta.a + linha));
	COLOR = vec4(saida.rgb * cor_vertice.rgb, saida.a * cor_vertice.a);
}
