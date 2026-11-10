shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLOSION : un coup sur une enclume invisible — un éclair blanc chaud, une colonne d'étincelles qui jaillit, et
// un anneau de métal en fusion qui court au sol.

#include "res://assets/shaders/forgeron.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec4 color = vec4(0.0);
	// L'anneau au sol.
	vec2 g = vec2(p.x, (p.y - 0.3) * 2.4);
	float r = smoothstep(0.0, 0.6, t) * 0.95;
	float ring = smoothstep(0.07, 0.0, abs(length(g) - r)) * (1.0 - smoothstep(0.5, 1.0, t));
	color = g_over(vec4(g_heat(0.7 + ring * 0.3), ring), color);
	float crack = g_cracks(g, 7.0, seed, r) * (1.0 - t);
	color = g_over(vec4(G_MOLTEN, crack * 0.8), color);
	// La colonne d'étincelles.
	float sparks = g_sparks(p - vec2(0.0, 0.25), smoothstep(0.08, 0.9, t), 1.6, 1.2, seed, 22);
	color = g_over(vec4(g_heat(0.95), sparks), color);
	// L'éclair.
	float flash = 1.0 - smoothstep(0.0, 0.3, t);
	color = g_over(vec4(G_SPARK, g_glow(length(p - vec2(0.0, 0.25)), 0.7) * flash), color);
	color = g_over(vec4(G_CORE, g_glow(length(p - vec2(0.0, 0.25)), 0.35) * flash), color);
	COLOR = color;
}
