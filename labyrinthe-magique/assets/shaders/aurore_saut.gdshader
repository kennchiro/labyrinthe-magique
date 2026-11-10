shader_type canvas_item;
render_mode blend_mix;

// LE TRAIT DE L'ÉTOILE, aux deux bouts : une étoile s'ouvre où il part et où il arrive, avec un éclat blanc.

#include "res://assets/shaders/aurore.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec4 color = vec4(0.0);
	float flash = a_glow(length(p), 0.9) * (1.0 - smoothstep(0.0, 0.4, t));
	color = a_over(vec4(A_WHITE, flash * 0.8), color);
	float r = 0.95 * sin(smoothstep(0.0, 1.0, t) * PI);
	color = a_over(a_star_paint(p, r, t * 2.5 + seed, 1.0), color);
	float ring = smoothstep(0.05, 0.0, abs(length(p) - 0.9 * t)) * (1.0 - t);
	color = a_over(vec4(A_GOLD_LIGHT, ring), color);
	COLOR = color;
}
