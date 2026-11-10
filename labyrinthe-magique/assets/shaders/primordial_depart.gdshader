shader_type canvas_item;
render_mode blend_mix;

// LE PAS DES ÉLÉMENTS, AU DÉPART : il se dissout en quatre volutes de ses éléments qui s'envolent en spirale.

#include "res://assets/shaders/primordial.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec2 q = p - vec2(0.0, -0.2 - 0.3 * t);
	float reach = mix(0.35, 0.95, t);
	vec4 color = pinwheel(q / reach * 0.9, TIME * 1.4 + seed, 0.9, -t * 6.0, 4.0 - 2.0 * t);
	// Le creux au centre : il n'y a plus personne.
	color.a *= smoothstep(0.08, 0.3, length(q) / reach) * (1.0 - smoothstep(0.55, 1.0, t));
	float flash = p_glow(length(q), 0.4) * (1.0 - smoothstep(0.0, 0.25, t));
	color = p_over(vec4(P_GOLD_LIGHT, flash), color);
	COLOR = color;
}
