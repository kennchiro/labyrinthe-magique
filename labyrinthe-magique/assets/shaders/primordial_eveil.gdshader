shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLOSION DE L'ARCHIMAGE : un grand anneau d'or s'ouvre au sol, ses quatre runes s'allument l'une après l'autre,
// une colonne de lumière blanche le traverse, et chaque rune lâche un éclat de son élément.

#include "res://assets/shaders/primordial.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec4 color = vec4(0.0);
	// Le sol : l'anneau couché, vu en plongée.
	vec2 g = (p - vec2(0.0, 0.22)) * vec2(1.0, 2.3);
	float open = smoothstep(0.0, 0.25, t);
	vec4 lit = vec4(smoothstep(0.15, 0.2, t), smoothstep(0.28, 0.33, t), smoothstep(0.41, 0.46, t), smoothstep(0.54, 0.59, t));
	vec4 ring = p_ring(g, 0.72 * open, 0.06, t * 1.5, lit);
	ring.a *= 1.0 - smoothstep(0.85, 1.0, t);
	color = p_over(ring, color);
	// Les éclats des runes, chacun de son élément, qui montent un instant.
	for (int k = 0; k < 4; k++) {
		float born = 0.15 + 0.13 * float(k);
		float life = clamp((t - born) / 0.3, 0.0, 1.0);
		float ang = t * 1.5 + float(k) * TAU / 4.0 - TAU / 4.0;
		vec2 at = vec2(cos(ang) * 0.72, 0.22 + sin(ang) * 0.72 / 2.3) - vec2(0.0, life * 0.35);
		vec2 q = (p - at) / max(0.05, 0.08 + 0.22 * life);
		float h = 1.0 - length(q);
		vec4 burst = paint_element(k, q * 3.0 + seed, TIME * 2.0, h * 1.4);
		burst.a *= step(0.001, life) * (1.0 - life);
		color = p_over(burst, color);
	}
	// La colonne de lumière qui le traverse.
	float column = smoothstep(0.55, 0.65, t) * (1.0 - smoothstep(0.8, 1.0, t));
	float w = 0.16 + 0.12 * column;
	float beam = clamp(1.0 - abs(p.x) / w, 0.0, 1.0) * smoothstep(0.55, 0.3, p.y) * smoothstep(-1.0, -0.6, p.y);
	color = p_over(vec4(mix(P_GOLD_LIGHT, P_WHITE, beam), beam * column), color);
	COLOR = color;
}
