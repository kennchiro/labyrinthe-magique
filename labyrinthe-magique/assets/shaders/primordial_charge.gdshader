shader_type canvas_item;
render_mode blend_mix;

// LE GESTE D'ÉVEIL DE L'ARCHIMAGE : quatre filets des éléments montent en spirale autour de lui en se resserrant, se
// nouent au-dessus de sa tête, puis un éclair d'or.

#include "res://assets/shaders/primordial.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float reach = mix(1.0, 0.32, t);
	vec4 arms = pinwheel(p / max(0.2, reach) * 0.95, TIME * 1.4 + seed, 0.95, t * 9.0, 3.4);
	arms.a *= smoothstep(0.0, 0.18, t) * (1.0 - smoothstep(0.86, 1.0, t));
	vec4 color = arms;
	// Le nœud d'or au-dessus de sa tête.
	float knot = p_glow(length(p - vec2(0.0, -0.35)), 0.12 + 0.3 * smoothstep(0.6, 1.0, t));
	color = p_over(vec4(mix(P_GOLD, P_WHITE, knot), knot * smoothstep(0.45, 0.8, t)), color);
	float flash = smoothstep(0.82, 1.0, t);
	float core = p_glow(length(p), 0.55 * flash);
	color = p_over(vec4(mix(P_GOLD, P_WHITE, core), core * flash), color);
	COLOR = color;
}
