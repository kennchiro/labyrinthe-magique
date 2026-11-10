shader_type canvas_item;
render_mode blend_mix;

// UNE PLAQUE CASSE : elle éclate en morceaux d'acier aux bords orange qui partent tout autour de lui en tournant, avec
// un éclair de forge au centre.

#include "res://assets/shaders/forgeron.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec4 color = vec4(0.0);
	for (int i = 0; i < 9; i++) {
		float f = float(i);
		float a = f * TAU / 9.0 + g_hash(f, seed) * 0.5;
		vec2 dir = vec2(cos(a), sin(a) * 0.7);
		vec2 at = dir * (0.1 + t * 0.8);
		vec2 q = g_turn(p - at, t * 9.0 + f);
		color = g_over(g_blade(q, vec2(1.0, 0.0), 0.2 * (1.0 - t * 0.4), 1.0 - smoothstep(0.6, 1.0, t)), color);
	}
	float flash = 1.0 - smoothstep(0.0, 0.3, t);
	color = g_over(vec4(G_CORE, g_glow(length(p), 0.45) * flash), color);
	COLOR = color;
}
