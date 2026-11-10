shader_type canvas_item;
render_mode blend_mix;

// UN GOUFFRE : là où l'Orbe du néant frappe (et où l'ombre répète un coup), un petit tourbillon noir au
// liseré violet s'ouvre, aspire en tournant, puis se referme sur lui-même.

#include "res://assets/shaders/neant.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	p.y *= 1.4;
	float t = progress;
	vec3 color = N_VOID;
	float a = 0.0;
	float size = smoothstep(0.0, 0.25, t) * (1.0 - smoothstep(0.6, 1.0, t));
	float spin = n_spiral(p, 0.16, 3.0, 0.45, -TIME * 7.0 - t * 6.0, 0.8 * size);
	if (spin > -0.05 && size > 0.0) {
		color = spin <= 0.0 ? N_VIOLET : N_DEEP;
		a = 1.0;
	}
	if (n_eclipse(p, 0.22 * size, color) && size > 0.0) {
		a = 1.0;
	}
	// Des éclats d'argent aspirés vers le centre.
	for (int i = 0; i < 5; i++) {
		float f = float(i);
		float k = fract(t * 1.5 + f / 5.0);
		float ang = f / 5.0 * TAU + k * 2.0 + seed;
		vec2 c = vec2(cos(ang), sin(ang)) * mix(0.9, 0.15, k);
		float shard = 0.05 * (1.0 - k) - length(p - c);
		if (shard > 0.0 && size > 0.0) {
			color = N_SILVER;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
