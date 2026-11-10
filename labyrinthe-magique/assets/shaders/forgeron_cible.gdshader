shader_type canvas_item;
render_mode blend_mix;

// L'ANNONCE DE L'ENCLUME, couchée au sol : un cercle d'or qui se resserre, une croix d'or au centre, et une ombre
// d'enclume qui grandit à mesure qu'elle approche.

#include "res://assets/shaders/forgeron.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec2 g = vec2(p.x, p.y * 2.0);
	float t = progress;
	float d = length(g);
	float r = mix(0.95, 0.75, t);
	float pulse = 0.7 + 0.3 * sin(TIME * 16.0);
	vec4 color = vec4(G_RIM, step(abs(g.x), 0.55 * t) * step(abs(g.y), 0.28 * t) * 0.45);
	color = g_over(vec4(G_GOLD, smoothstep(0.04, 0.0, abs(d - r)) * pulse), color);
	color = g_over(vec4(G_GOLD, smoothstep(0.03, 0.0, min(abs(g.x), abs(g.y))) * step(d, r * 0.4) * 0.8), color);
	COLOR = color;
}
