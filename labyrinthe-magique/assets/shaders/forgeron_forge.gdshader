shader_type canvas_item;
render_mode blend_mix;

// LA FORGE VIVANTE, toute la minute : une lueur de forge bat sous ses pieds, couchée au sol, cerclée d'or, avec des
// fentes orange qui rayonnent, et quelques étincelles s'en échappent.

#include "res://assets/shaders/forgeron.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec2 g = vec2(p.x, p.y * 2.2);
	float born = smoothstep(0.0, 0.03, progress);
	float beat = 0.7 + 0.3 * sin(TIME * 3.0);
	float d = length(g);
	vec4 color = vec4(g_heat(0.5 * beat), g_glow(d, 0.7) * 0.5 * beat);
	color = g_over(vec4(G_GOLD, smoothstep(0.035, 0.0, abs(d - 0.74)) * 0.9), color);
	float cracks = g_cracks(g, 8.0, seed + TIME * 0.2, 0.72) * step(0.15, d);
	color = g_over(vec4(G_MOLTEN, cracks * beat), color);
	for (int i = 0; i < 5; i++) {
		float f = float(i);
		float rise = fract(TIME * 0.7 + f * 0.21);
		vec2 at = vec2((g_hash(f, seed) - 0.5) * 1.0, -rise * 0.9);
		color = g_over(vec4(G_CORE, g_glow(length(p - at), 0.03) * (1.0 - rise)), color);
	}
	color.a *= born;
	COLOR = color;
}
