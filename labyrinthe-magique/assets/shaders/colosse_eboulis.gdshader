shader_type canvas_item;
render_mode blend_mix;

// LA FIN DU COLOSSE : les roches se détachent de lui et tombent en éboulis à ses pieds, dans un nuage
// de poussière. Les cristaux s'éteignent en tombant.

#include "res://assets/shaders/colosse.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = C_ROCK;
	float a = 0.0;
	// La poussière au sol.
	float puff = smoothstep(0.25, 0.5, t) * (1.0 - smoothstep(0.75, 1.0, t));
	for (int i = 0; i < 7; i++) {
		float f = float(i);
		vec2 c = vec2((f - 3.0) * 0.22, 0.62 + 0.06 * sin(f * 2.0));
		float blob = (0.22 + 0.06 * c_hash(f, seed)) * puff - length((p - c) * vec2(1.0, 1.5));
		if (blob > 0.0) {
			color = blob < 0.03 ? C_ROCK_LIGHT : C_DUST;
			a = 1.0;
		}
	}
	// Les roches, qui partent de son corps et tombent en s'écartant.
	for (int i = 0; i < 9; i++) {
		float f = float(i);
		float delay = c_hash(f, seed) * 0.25;
		float k = clamp((t - delay) / 0.55, 0.0, 1.0);
		vec2 start = vec2((c_hash(f + 2.0, seed) - 0.5) * 0.7, -0.55 + c_hash(f + 4.0, seed) * 0.7);
		vec2 c = start + vec2((start.x > 0.0 ? 1.0 : -1.0) * k * 0.35, k * k * (0.65 - start.y));
		float r = (0.09 + 0.05 * c_hash(f + 6.0, seed)) * (1.0 - smoothstep(0.75, 1.0, t));
		vec2 q = c_rot(p - c, k * 3.0);
		if (mod(f, 3.0) == 0.0) {
			float gem = c_gem(q, r * 1.8, r * 0.6);
			if (gem > -0.015 && r > 0.0) {
				a = 1.0;
				color = gem <= 0.0 ? C_RIM : mix(c_gem_shade(q, gem, r * 0.6), C_CRYSTAL_DARK, k);
			}
		} else {
			float rock = c_rock(q, r, f + seed);
			if (rock > -0.015 && r > 0.0) {
				a = 1.0;
				color = rock <= 0.0 ? C_RIM : c_rock_shade(p - c, rock, r);
			}
		}
	}
	COLOR = vec4(color, a);
}
