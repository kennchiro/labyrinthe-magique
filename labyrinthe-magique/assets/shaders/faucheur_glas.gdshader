shader_type canvas_item;
render_mode blend_mix;

// UN COUP DU GLAS : une onde noire bordée de braise part en cercle depuis lui.

#include "res://assets/shaders/faucheur.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float d = length(p);
	float front = 0.8 * smoothstep(0.0, 0.8, t);
	float band = smoothstep(0.12, 0.0, abs(d - front + 0.05)) * (1.0 - t);
	float edge = smoothstep(0.025, 0.0, abs(d - front)) * (1.0 - t);
	vec4 color = vec4(F_BLACK, band * 0.7);
	color = f_over(vec4(F_EMBER, edge), color);
	COLOR = color;
}
