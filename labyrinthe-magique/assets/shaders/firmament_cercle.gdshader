shader_type canvas_item;
render_mode blend_mix;

// LE FIRMAMENT, toute la minute : une constellation lente tourne sous ses pieds, couchée au sol — un anneau
// d'argent pointillé, et cinq petites étoiles reliées en figure.

#include "res://assets/shaders/firmament.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	p.y *= 2.2;
	float born = smoothstep(0.0, 0.03, progress);
	float turn = TIME * 0.35;
	float d = length(p);
	float a = atan(p.y, p.x) - turn;
	float dots = step(0.5, fract(a * 24.0 / TAU));
	vec4 color = vec4(R_SILVER, smoothstep(0.03, 0.0, abs(d - 0.8)) * dots * 0.75 * born);
	float beat = 0.75 + 0.25 * sin(TIME * 2.5);
	for (int i = 0; i < 5; i++) {
		vec2 s = r_point(i, 0.62, turn);
		vec2 n = r_point(i + 1, 0.62, turn);
		color = r_over(r_ray(p, s, n, 0.018, 0.55 * born * beat), color);
		color = r_over(r_star(p - s, 0.1, TIME * 0.8 + float(i), born), color);
	}
	COLOR = color;
}
