shader_type canvas_item;
render_mode blend_mix;

// LA VAGUE DE MIDI : le soleil est tombé sur lui, et un anneau de lumière blanche part jusqu'au bord de l'écran.

#include "res://assets/shaders/aurore.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float d = length(p);
	float front = smoothstep(0.0, 0.8, t);
	float ring = smoothstep(0.1, 0.0, abs(d - front)) * (1.0 - t);
	float inside = step(d, front) * (1.0 - t) * 0.25;
	vec4 color = vec4(A_WHITE, inside);
	color = a_over(vec4(mix(A_SUN, A_WHITE, 0.6), ring), color);
	float flash = a_glow(d, 0.3) * (1.0 - smoothstep(0.0, 0.25, t));
	color = a_over(vec4(A_WHITE, flash), color);
	COLOR = color;
}
