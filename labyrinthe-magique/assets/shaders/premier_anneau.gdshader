shader_type canvas_item;
render_mode blend_mix;

// IL RETOMBE : le sol se fend en étoile sous lui et un ANNEAU DE FEU part en s'élargissant, hérissé de langues de
// flamme, puis la fumée retombe.

#include "res://assets/shaders/premier.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	vec2 g = p * vec2(1.0, 1.7);
	float d = length(g);
	float ang = atan(g.y, g.x);
	float r = smoothstep(0.0, 0.6, t) * 0.85;
	float fade = 1.0 - smoothstep(0.6, 1.0, t);
	float crack = 0.018 - abs(fract(ang * 7.0 / TAU + seed) - 0.5) * d * 2.0;
	if (crack > 0.0 && d < r && fade > 0.0) {
		color = P_MAGMA;
		a = 1.0;
	}
	float band = 0.05 * fade - abs(d - r);
	if (band > 0.0) {
		color = band > 0.03 ? P_YELLOW : P_MAGMA;
		a = 1.0;
	}
	for (int i = 0; i < 12; i++) {
		float f = float(i);
		float an = f * TAU / 12.0 + seed;
		vec2 base = vec2(cos(an) * r, sin(an) * r / 1.7);
		vec3 c = color;
		if (fade > 0.05 && p_paint_tongue(p - base, 0.06, 0.28 * fade, c)) {
			color = c;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
