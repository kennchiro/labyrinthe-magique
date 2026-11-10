shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLOSION : une étoile à huit branches s'allume à ses pieds, une colonne de lumière monte jusqu'en haut, et un
// éclair blanc blanchit tout un instant.

#include "res://assets/shaders/aurore.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float life = 1.0 - smoothstep(0.7, 1.0, t);
	vec4 color = vec4(0.0);
	// L'étoile au sol, couchée.
	vec2 g = vec2(p.x, (p.y - 0.55) * 2.6);
	color = a_over(a_star_paint(g, 0.75 * smoothstep(0.0, 0.25, t), t * 1.5, life), color);
	// La colonne.
	float column = clamp(1.0 - abs(p.x) / (0.28 * smoothstep(0.05, 0.3, t)), 0.0, 1.0) * step(p.y, 0.6);
	color = a_over(vec4(mix(A_SUN, A_WHITE, column), column * life * 0.9), color);
	// Les rayons qui partent de lui.
	float ang = atan(p.y + 0.1, p.x);
	float beam = pow(abs(sin(ang * 8.0 + t * 2.0)), 10.0) * a_glow(length(p), 1.0) * smoothstep(0.15, 0.35, t);
	color = a_over(vec4(A_GOLD_LIGHT, beam * life * 0.7), color);
	// L'éclair blanc.
	float flash = (1.0 - smoothstep(0.0, 0.18, abs(t - 0.2))) * a_glow(length(p), 1.1);
	color = a_over(vec4(A_WHITE, flash * 0.85), color);
	COLOR = color;
}
