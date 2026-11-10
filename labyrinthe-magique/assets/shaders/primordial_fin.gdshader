shader_type canvas_item;
render_mode blend_mix;

// LA FIN DE L'ÉVEIL : l'anneau d'or se referme à ses pieds, ses runes pâlissent l'une après l'autre, et une poussière
// d'or retombe.

#include "res://assets/shaders/primordial.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec2 g = p * vec2(1.0, 2.2);
	vec4 lit = vec4(1.0 - smoothstep(0.0, 0.2, t), 1.0 - smoothstep(0.15, 0.35, t),
		1.0 - smoothstep(0.3, 0.5, t), 1.0 - smoothstep(0.45, 0.65, t));
	vec4 ring = p_ring(g, mix(0.7, 0.05, smoothstep(0.3, 1.0, t)), 0.045, -t * 4.0, lit);
	ring.a *= 1.0 - smoothstep(0.85, 1.0, t);
	vec4 color = ring;
	for (int i = 0; i < 12; i++) {
		float f = float(i);
		float fall = fract(t + p_hash(f, seed));
		vec2 at = vec2((p_hash(f, 4.0) - 0.5) * 1.4, -0.8 + fall * 1.2);
		float s = p_glow(length(p - at), 0.05);
		color = p_over(vec4(P_GOLD_LIGHT, s * (1.0 - t)), color);
	}
	COLOR = color;
}
