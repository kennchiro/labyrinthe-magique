shader_type canvas_item;
render_mode blend_mix;

// LA CHARGE DE L'ÉVEIL : des rayons convergent vers sa poitrine de tout autour, et s'y resserrent.

#include "res://assets/shaders/aurore.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float d = length(p);
	float ang = atan(p.y, p.x);
	vec4 color = vec4(0.0);
	for (int i = 0; i < 12; i++) {
		float f = float(i);
		float a = f * TAU / 12.0 + a_hash(f, seed) * 0.3;
		float off = abs(sin(ang - a)) * d;
		float head = 1.0 - fract(t * 1.3 + a_hash(f, 3.0));
		// Un trait de 0,3 qui file vers lui : sa tête est à `head`, sa queue derrière.
		float along = step(0.0, cos(ang - a)) * smoothstep(head + 0.3, head, d) * step(head - 0.05, d);
		vec4 ray = a_beam(off / 0.05, 1.0, along * 0.9);
		color = a_over(ray, color);
	}
	vec4 core = vec4(A_WHITE, a_glow(d, 0.15 + 0.2 * t) * t);
	color = a_over(core, color);
	color = a_over(a_star_paint(p, 0.12 + 0.25 * t, TIME, t), color);
	COLOR = color;
}
