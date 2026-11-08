shader_type canvas_item;
render_mode unshaded;

// The adjustment is local to the Penitent, not an exposure change to the room.
uniform float midtone_gain : hint_range(1.0, 1.5) = 1.24;
uniform float color_strength : hint_range(0.8, 1.3) = 1.08;
uniform float edge_strength : hint_range(0.0, 1.0) = 0.30;
uniform vec4 frame_bounds = vec4(0.0, 0.0, 1.0, 1.0);

varying vec4 actor_tint;

void vertex() {
	actor_tint = COLOR;
}

void fragment() {
	vec4 paint = texture(TEXTURE, UV);
	vec4 tint = actor_tint;
	float luminance = dot(paint.rgb, vec3(0.2126, 0.7152, 0.0722));
	float metal = smoothstep(0.12, 0.65, luminance);
	vec3 richer = mix(vec3(luminance), paint.rgb, color_strength);
	vec3 readable = richer * mix(1.025, midtone_gain, metal);
	// A restrained warm edge keeps steel distinct from both ochre and slate walls.
	readable += vec3(0.020, 0.014, 0.007) * metal;
	vec2 step_uv = TEXTURE_PIXEL_SIZE * 1.8;
	vec2 minimum = frame_bounds.xy + TEXTURE_PIXEL_SIZE * 0.5;
	vec2 maximum = frame_bounds.zw - TEXTURE_PIXEL_SIZE * 0.5;
	vec2 right_uv = UV + vec2(step_uv.x, 0.0);
	vec2 left_uv = UV - vec2(step_uv.x, 0.0);
	vec2 down_uv = UV + vec2(0.0, step_uv.y);
	vec2 up_uv = UV - vec2(0.0, step_uv.y);
	float right_alpha = right_uv.x <= maximum.x ? texture(TEXTURE, right_uv).a : 0.0;
	float left_alpha = left_uv.x >= minimum.x ? texture(TEXTURE, left_uv).a : 0.0;
	float down_alpha = down_uv.y <= maximum.y ? texture(TEXTURE, down_uv).a : 0.0;
	float up_alpha = up_uv.y >= minimum.y ? texture(TEXTURE, up_uv).a : 0.0;
	float adjacent = max(max(right_alpha, left_alpha), max(down_alpha, up_alpha));
	float edge = max(adjacent - paint.a, 0.0) * edge_strength;
	float combined_alpha = paint.a + edge * (1.0 - paint.a);
	vec3 outline = vec3(0.17, 0.13, 0.11);
	vec3 combined = mix(outline, readable, paint.a / max(combined_alpha, 0.0001));
	COLOR = vec4(clamp(combined, vec3(0.0), vec3(1.0)) * tint.rgb, combined_alpha * tint.a);
}
