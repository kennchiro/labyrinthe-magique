shader_type canvas_item;
render_mode blend_mix;

// L'ÉBLOUISSEMENT : sur un aveuglé, le coup en plus fait éclore une petite étoile vive au-dessus de lui.

#include "res://assets/shaders/aurore.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec2 q = p - vec2(0.0, -0.4 - 0.3 * t);
	vec4 color = a_star_paint(q, 0.45 * smoothstep(0.0, 0.2, t), t * 3.0, 1.0 - smoothstep(0.6, 1.0, t));
	color = a_over(vec4(A_WHITE, a_glow(length(q), 0.6) * 0.5 * (1.0 - t)), color);
	COLOR = color;
}
