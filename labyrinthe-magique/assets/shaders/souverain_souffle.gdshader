shader_type canvas_item;
render_mode blend_mix;

// UNE BOURRASQUE : ce que le vent rejette part dans un éclat de trois croissants qui s'ouvrent, avec une
// petite spirale au centre. Pour le Rempart de vent, les coups du Croissant, le Cocon.

#include "res://assets/shaders/souverain.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = S_SKY;
	float a = 0.0;
	float open = smoothstep(0.0, 0.5, t);
	float fade = 1.0 - smoothstep(0.5, 1.0, t);
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		float rel;
		float arc = s_arc(p, 0.3 + open * 0.45, f / 3.0 * TAU + seed * 3.0 + t * 2.0, 1.6, 0.09 * fade, rel);
		if (arc > -0.02 && fade > 0.0) {
			color = arc <= 0.0 ? S_RIM : s_wind(arc / (0.09 * fade + 0.001));
			a = 1.0;
		}
	}
	float spin = s_spiral(p, 0.12, 1.0, 0.4 * fade, t * 8.0, 0.3 * (1.0 - open * 0.5));
	if (spin > 0.0) {
		color = S_WHITE;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
