shader_type canvas_item;
render_mode blend_mix;

// LA CHARGE DE L'ÉVEIL : des étincelles montent du sol autour de lui, et une lueur de forge grandit à ses pieds.

#include "res://assets/shaders/forgeron.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec4 color = vec4(0.0);
	vec2 g = vec2(p.x, (p.y - 0.55) * 2.6);
	float pool = g_glow(length(g), 0.8 * t);
	color = g_over(vec4(g_heat(0.4 + pool * 0.5), pool * 0.8), color);
	for (int i = 0; i < 14; i++) {
		float f = float(i);
		float x = (g_hash(f, seed) - 0.5) * 1.4;
		float rise = fract(t * (1.2 + g_hash(f, 3.0)) + g_hash(f, 9.0));
		vec2 at = vec2(x * (1.0 - rise * 0.3), 0.6 - rise * 1.4);
		float spark = g_glow(length((p - at) * vec2(1.0, 0.45)), 0.04);
		color = g_over(vec4(g_heat(0.9), spark * (1.0 - rise) * smoothstep(0.0, 0.2, t)), color);
	}
	COLOR = color;
}
