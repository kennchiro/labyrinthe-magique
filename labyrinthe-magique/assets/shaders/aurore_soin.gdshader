shader_type canvas_item;
render_mode blend_mix;

// UN PV RENDU PAR LA CATHÉDRALE : une petite étoile monte sur lui, et un anneau d'or se resserre.

#include "res://assets/shaders/aurore.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec4 color = vec4(0.0);
	float ring = smoothstep(0.05, 0.0, abs(length(vec2(p.x, (p.y - 0.5) * 2.0)) - 0.8 * (1.0 - t))) * (1.0 - t);
	color = a_over(vec4(A_GOLD, ring), color);
	color = a_over(a_star_paint(p - vec2(0.0, 0.3 - 0.9 * t), 0.35, t * 4.0, 1.0 - smoothstep(0.7, 1.0, t)), color);
	COLOR = color;
}
