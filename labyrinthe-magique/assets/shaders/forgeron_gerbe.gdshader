shader_type canvas_item;
render_mode blend_mix;

// LE BASTION S'OUVRE : douze lames en fusion partent en couronne depuis lui, en tournant, avec un anneau de chaleur.

#include "res://assets/shaders/forgeron.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec4 color = vec4(0.0);
	float fade = 1.0 - smoothstep(0.6, 1.0, t);
	vec2 g = vec2(p.x, p.y * 1.6);
	color = g_over(vec4(g_heat(0.7), smoothstep(0.08, 0.0, abs(length(g) - t * 0.9)) * fade * 0.7), color);
	for (int i = 0; i < 12; i++) {
		float f = float(i);
		float a = f * TAU / 12.0 + t * 1.5;
		vec2 dir = vec2(cos(a), sin(a));
		vec2 at = vec2(dir.x, dir.y * 0.62) * (0.15 + t * 0.75);
		color = g_over(g_blade(p - at, dir, 0.16, fade), color);
	}
	color = g_over(vec4(G_CORE, g_glow(length(p), 0.4) * (1.0 - smoothstep(0.0, 0.3, t))), color);
	COLOR = color;
}
