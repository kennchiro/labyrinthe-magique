shader_type canvas_item;
render_mode blend_mix;

// LA FIN DE L'ÉVEIL DU DRAGON : la lave du cercle se fige en obsidienne qui se fend, et une fumée noire monte en
// boules. Le premier feu se rendort.

#include "res://assets/shaders/premier.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	vec2 g = (p - vec2(0.0, 0.6)) * vec2(1.0, 2.6);
	float d = length(g);
	float band = 0.08 * (1.0 - t) - abs(d - 0.6);
	if (band > 0.0) {
		color = mix(P_MAGMA, P_OBSIDIAN, smoothstep(0.1, 0.6, t));
		a = 1.0;
	}
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		vec2 at = vec2((p_hash(f, seed) - 0.5) * 1.0, 0.5 - t * (0.9 + p_hash(f + 2.0, seed) * 0.5));
		float r = 0.08 + t * 0.12;
		float puff = r - length(p - at);
		if (puff > -0.015 && t < 0.92) {
			color = puff <= 0.0 ? P_OBSIDIAN : P_SMOKE;
			a = 1.0 - smoothstep(0.6, 0.92, t);
		}
	}
	COLOR = vec4(color, a);
}
