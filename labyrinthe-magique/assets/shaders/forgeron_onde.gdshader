shader_type canvas_item;
render_mode blend_mix;

// LE COUP QUI ÉTOURDIT : un anneau de métal en fusion court au sol, le sol se fend d'orange en étoile, et une gerbe
// d'étincelles jaillit au centre.

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
	float ring = smoothstep(0.06, 0.0, abs(d - sqrt(t) * 0.9)) * (1.0 - t);
	color = g_over(vec4(g_heat(0.75), ring), color);
	float crack = g_cracks(g, 6.0, seed, 0.8 * sqrt(t) + 0.01) * (1.0 - t);
	color = g_over(vec4(G_MOLTEN, crack), color);
	float sparks = g_sparks(p, t, 0.9, 2.4, seed, 12);
	color = g_over(vec4(g_heat(0.95), sparks), color);
	COLOR = color;
}
