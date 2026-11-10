shader_type canvas_item;
render_mode blend_mix;

// LA CHARGE DE L'ÉVEIL : cinq étoiles s'allument une à une autour d'elle et se relient par des traits d'argent,
// en tournant de plus en plus vite.

#include "res://assets/shaders/firmament.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float turn = t * t * 9.0;
	float r = 0.72 - t * 0.2;
	vec4 color = vec4(0.0);
	for (int i = 0; i < 5; i++) {
		float lit = smoothstep(float(i) * 0.14, float(i) * 0.14 + 0.08, t);
		vec2 a = r_point(i, r, turn);
		vec2 b = r_point(i + 1, r, turn);
		float drawn = smoothstep(float(i) * 0.14 + 0.08, float(i) * 0.14 + 0.2, t);
		color = r_over(r_ray(p, a, mix(a, b, drawn), 0.022, drawn * 0.9), color);
		color = r_over(r_star(p - a, 0.12 * lit, -turn * 2.0, lit), color);
	}
	float core = smoothstep(0.7, 1.0, t);
	color = r_over(r_star(p, 0.3 * core, t * 6.0, core), color);
	COLOR = color;
}
