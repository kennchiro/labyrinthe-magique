shader_type canvas_item;
render_mode blend_mix;

// LE GESTE D'ÉVEIL, sous ses pieds : le sol se fend en étoile et les fissures s'allument une à une,
// pendant que des éclats de roche et de cristal montent vers lui.

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
	// L'étoile de fissures, au sol, aplatie par la plongée.
	vec2 g = (p - vec2(0.0, 0.45)) * vec2(1.0, 2.0);
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		float lit = smoothstep(f * 0.1, f * 0.1 + 0.15, t);
		vec2 q = c_rot(g, -(f / 6.0 * TAU + 0.3));
		float crack = c_crack(q, 0.85 * lit, 0.1, 0.2, f + 2.0);
		if (crack > -0.03 && lit > 0.0) {
			color = crack <= 0.0 ? C_RIM : c_lava(crack / 0.1, lit);
			a = 1.0;
		}
	}
	// Les éclats qui montent vers lui en convergeant.
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float k = fract(t * 1.6 + f / 8.0);
		float ang = f / 8.0 * TAU;
		vec2 c = vec2(cos(ang) * 0.85, sin(ang) * 0.4 + 0.45) * (1.0 - k) + vec2(0.0, -0.35) * k;
		vec2 q = p - c;
		float size = 0.09 * (1.0 - k * 0.6);
		if (mod(f, 2.0) == 0.0) {
			float gem = c_gem(q, size * 1.8, size * 0.6);
			if (gem > -0.012) {
				color = gem <= 0.0 ? C_RIM : c_gem_shade(q, gem, size * 0.6);
				a = 1.0;
			}
		} else {
			float rock = c_rock(q, size, f);
			if (rock > -0.012) {
				color = rock <= 0.0 ? C_RIM : c_rock_shade(q, rock, size);
				a = 1.0;
			}
		}
	}
	COLOR = vec4(color, a);
}
