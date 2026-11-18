shader_type canvas_item;
render_mode unshaded;

// Um pedaço de corpo: mostra só o lado do quadro que fica de um lado do corte,
// e pinta a borda do corte de carne e sangue, irregular.
uniform vec4 frame_bounds = vec4(0.0, 0.0, 1.0, 1.0);
uniform vec3 plano = vec3(0.0, 1.0, -0.5);   // mantém onde plano.x*u + plano.y*v + plano.z >= 0 (u, v na célula)
uniform vec3 cor_ferida : source_color = vec3(0.42, 0.01, 0.03);
uniform vec3 cor_carne : source_color = vec3(0.72, 0.18, 0.16);
uniform float largura = 0.022;
uniform float semente = 0.0;

float acaso(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7)) + semente) * 43758.5453);
}

void fragment() {
	vec2 cel = (UV - frame_bounds.xy) / max(frame_bounds.zw - frame_bounds.xy, vec2(0.0001));
	vec4 c = texture(TEXTURE, UV);
	// Corte irregular: a linha treme um pouco, como carne rasgada.
	float d = dot(plano.xy, cel) + plano.z + (acaso(floor(cel * 60.0)) - 0.5) * 0.012;
	if (d < 0.0) {
		c.a = 0.0;
	} else {
		float ferida = 1.0 - smoothstep(0.0, largura, d);
		vec3 carne = mix(cor_ferida, cor_carne, step(0.55, acaso(floor(cel * 90.0) + 3.0)) * 0.6);
		c.rgb = mix(c.rgb, carne, ferida * 0.92);
	}
	COLOR = c * COLOR;
}
