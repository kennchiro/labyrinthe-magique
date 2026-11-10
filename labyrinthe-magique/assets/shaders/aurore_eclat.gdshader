shader_type canvas_item;
render_mode blend_mix;

// L'IMPACT DU TRAIT SOLAIRE : une étoile qui éclate, et un anneau qui s'ouvre.

#include "res://assets/shaders/aurore.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float d = length(p);
	vec4 color = vec4(0.0);
	float ring = smoothstep(0.06, 0.0, abs(d - 0.8 * smoothstep(0.0, 0.7, t))) * (1.0 - t);
	color = a_over(vec4(A_GOLD_LIGHT, ring), color);
	color = a_over(a_star_paint(p, 0.75 * (1.0 - t * 0.6) * smoothstep(0.0, 0.15, t), t * 2.0, 1.0 - smoothstep(0.5, 1.0, t)), color);
	COLOR = color;
}
