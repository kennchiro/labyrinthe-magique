shader_type canvas_item;
render_mode blend_mix;

// LE TRAIT DE COMÈTE : une petite étoile blanche à cœur d'or qui tourne en tête, et une queue bleue qui s'effile
// vers l'arrière, semée de points blancs. Cernée de nuit pour tenir sur les sols clairs.

#include "res://assets/shaders/firmament.gdshaderinc"

uniform float seed = 0.0;

void fragment() {
	vec2 q = vec2(UV.x * 2.6, UV.y - 0.5);
	vec2 head = vec2(2.15, 0.0);
	float along = clamp((head.x - q.x) / 1.9, 0.0, 1.0);
	float width = 0.22 * (1.0 - along);
	float tail = step(q.x, head.x) * smoothstep(width, width * 0.4, abs(q.y)) * (1.0 - along);
	vec4 color = vec4(R_RIM, smoothstep(width * 1.12, width * 1.02, abs(q.y)) * step(q.x, head.x) * (1.0 - along) * 0.6);
	color = r_over(vec4(mix(R_BLUE, R_SHINE, smoothstep(0.6, 0.0, along) * 0.6), tail), color);
	for (int i = 0; i < 4; i++) {
		float f = float(i);
		float x = fract(f * 0.27 - TIME * 2.0) * 1.6;
		vec2 dot_at = vec2(head.x - 0.3 - x, (r_hash(f, seed) - 0.5) * 0.18);
		color = r_over(vec4(R_SHINE, r_glow(length(q - dot_at), 0.035) * (1.0 - x / 1.6)), color);
	}
	color = r_over(r_star(q - head, 0.28, TIME * 8.0 + seed, 1.0), color);
	COLOR = vec4(color.rgb, color.a * COLOR.a);
}
