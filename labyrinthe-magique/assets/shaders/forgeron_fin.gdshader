shader_type canvas_item;
render_mode blend_mix;

// LA FIN : la lueur s'éteint en refroidissant du jaune au gris, dans un nuage de vapeur grise qui monte.

#include "res://assets/shaders/forgeron.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec4 color = vec4(0.0);
	for (int i = 0; i < 7; i++) {
		float f = float(i);
		vec2 at = vec2((g_hash(f, seed) - 0.5) * 1.0, 0.4 - t * (0.8 + g_hash(f, 2.0) * 0.6));
		float puff = g_glow(length(p - at), 0.2 + t * 0.25);
		color = g_over(vec4(mix(G_STEEL, G_SHADE, 0.3), puff * 0.5 * (1.0 - t)), color);
	}
	vec2 g = vec2(p.x, (p.y - 0.55) * 2.6);
	float cool = 1.0 - t;
	color = g_over(vec4(g_heat(cool * 0.8), g_glow(length(g), 0.6) * cool), color);
	COLOR = color;
}
