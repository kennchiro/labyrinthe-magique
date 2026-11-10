shader_type canvas_item;
render_mode blend_mix;

// L'ANNONCE DU GROS MÉTÉORE, couchée au sol : un grand cercle d'argent qui se resserre, une étoile à quatre branches
// qui tourne au centre, et une lueur d'or pâle qui monte jusqu'à l'impact.

#include "res://assets/shaders/firmament.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	p.y *= 2.0;
	float t = progress;
	float d = length(p);
	float r = mix(0.95, 0.6, t);
	float pulse = 0.7 + 0.3 * sin(TIME * 14.0);
	vec4 color = vec4(R_GOLD, r_glow(d, r) * t * 0.35);
	color = r_over(vec4(R_SILVER, smoothstep(0.035, 0.0, abs(d - r)) * pulse), color);
	color = r_over(vec4(R_BLUE, smoothstep(0.025, 0.0, abs(d - r * 0.6)) * 0.6), color);
	color = r_over(r_star(vec2(p.x, p.y * 0.5), 0.32 * (0.6 + 0.4 * t), t * 4.0, 0.9), color);
	COLOR = color;
}
