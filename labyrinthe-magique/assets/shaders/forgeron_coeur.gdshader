shader_type canvas_item;
render_mode blend_mix;

// LE CŒUR DE LA FORGE : la forge explose autour de lui — un grand anneau de métal en fusion, une colonne
// d'étincelles, des lames en couronne et un éclair d'or ; le sol reste fendu d'orange pendant que tout retombe.

#include "res://assets/shaders/forgeron.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec2 g = vec2(p.x, p.y * 2.0);
	float d = length(g);
	vec4 color = vec4(0.0);
	float fade = 1.0 - smoothstep(0.55, 1.0, t);
	float cracks = g_cracks(g, 11.0, seed, sqrt(t) * 0.95 + 0.01) * fade;
	color = g_over(vec4(g_heat(0.75 * (1.0 - d * 0.5)), cracks), color);
	color = g_over(vec4(g_heat(0.8), smoothstep(0.08, 0.0, abs(d - sqrt(t) * 0.95)) * fade), color);
	color = g_over(vec4(G_GOLD, smoothstep(0.03, 0.0, abs(d - sqrt(t) * 0.8)) * fade), color);
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float a = f * TAU / 10.0 + t;
		vec2 dir = vec2(cos(a), sin(a));
		vec2 at = vec2(dir.x, dir.y * 0.5) * (0.1 + t * 0.8);
		color = g_over(g_blade(p - at, dir, 0.1, fade), color);
	}
	color = g_over(vec4(g_heat(0.95), g_sparks(p, t, 1.0, 1.0, seed, 24)), color);
	float flash = 1.0 - smoothstep(0.0, 0.3, t);
	color = g_over(vec4(G_CORE, g_glow(length(p), 0.6) * flash), color);
	color = g_over(vec4(G_SPARK, g_glow(length(p), 0.25) * flash), color);
	COLOR = color;
}
