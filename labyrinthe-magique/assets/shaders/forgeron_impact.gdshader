shader_type canvas_item;
render_mode blend_mix;

// L'ENCLUME FRAPPE : un éclair blanc chaud, le sol qui se fend d'orange en étoile, une onde d'or qui court au sol,
// une gerbe d'étincelles et des éclats de pierre qui retombent.

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
	float fade = 1.0 - smoothstep(0.5, 1.0, t);
	float cracks = g_cracks(g, 8.0, seed * 3.0, 0.9) * fade;
	color = g_over(vec4(g_heat(0.7 * (1.0 - d)), cracks), color);
	color = g_over(vec4(G_GOLD, smoothstep(0.06, 0.0, abs(d - sqrt(t) * 0.95)) * (1.0 - t)), color);
	color = g_over(vec4(g_heat(0.6), g_glow(d, 0.5) * fade * 0.7), color);
	color = g_over(vec4(g_heat(0.95), g_sparks(p, t, 1.4, 2.0, seed, 20)), color);
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float a = f * TAU / 8.0 + g_hash(f, seed);
		vec2 at = vec2(cos(a) * t * 0.8, -sin(abs(a)) * 0.6 * sin(t * PI) + t * 0.2);
		color = g_over(vec4(G_SHADE, step(length(p - at), 0.04) * (1.0 - t)), color);
	}
	float flash = 1.0 - smoothstep(0.0, 0.25, t);
	color = g_over(vec4(G_SPARK, g_glow(length(p), 0.8) * flash), color);
	COLOR = color;
}
