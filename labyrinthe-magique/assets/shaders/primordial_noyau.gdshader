shader_type canvas_item;
render_mode blend_mix;

// LE NOYAU DE LA GRANDE CONVERGENCE : un cœur d'or blanc, quatre bras des éléments qui tournent autour, et l'anneau
// d'or aux quatre runes qui le tient.

#include "res://assets/shaders/primordial.gdshaderinc"

uniform float seed = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	vec4 color = pinwheel(p * 1.05, TIME * 1.6 + seed, 0.95, -TIME * 5.0, 2.6);
	vec4 ring = p_ring(p, 0.8, 0.045, TIME * 2.0, vec4(1.0));
	color = p_over(ring, color);
	float core = p_glow(d, 0.42);
	color = p_over(vec4(mix(P_GOLD, P_WHITE, core), smoothstep(0.0, 0.25, core)), color);
	color.a *= COLOR.a;
	COLOR = color;
}
