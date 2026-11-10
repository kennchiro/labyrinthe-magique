shader_type canvas_item;
render_mode blend_mix;

// LES YEUX DU CIEL, toute la minute : six petites ailes de lumière derrière lui, qui battent lentement, translucides.

#include "res://assets/shaders/seraphin.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float born = smoothstep(0.0, 0.03, progress) * (1.0 - smoothstep(0.985, 1.0, progress));
	vec4 color = vec4(0.0);
	vec2 root = vec2(0.0, -0.05);
	for (int k = 0; k < 3; k++) {
		float f = float(k);
		float beat = 0.12 * sin(TIME * 2.2 + f * 0.8);
		float lift = -0.45 + f * 0.45 + beat;
		float len = 0.8 - f * 0.17;
		for (int side = 0; side < 2; side++) {
			float s = float(side) * 2.0 - 1.0;
			float dir = s > 0.0 ? lift : PI - lift;
			color = s_over(s_wing(p, root + vec2(s * 0.1, f * 0.13), dir, 0.5, len, 4, 0.55), color);
		}
	}
	color.a *= born;
	COLOR = color;
}
