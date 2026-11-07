shader_type canvas_item;
render_mode blend_mix;

// LA MÉTÉORITE, le projectile : un gros rocher fendu de lave qui ROULE vers l'avant, deux cristaux
// verts sur sa face, trois traits de vitesse et des cailloux derrière lui. UV.x va de la queue (0) à
// la pointe (1).

#include "res://assets/shaders/colosse.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;

const float LENGTH = 1.6;

void fragment() {
	vec2 p = vec2((UV.x - 0.68) * LENGTH, UV.y - 0.5);
	vec3 color = C_ROCK;
	float a = 0.0;
	// Les traits de vitesse, derrière lui, en dents d'orange.
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		float y = (f - 1.0) * 0.17;
		float x0 = -0.32 - f * 0.04;
		vec2 q = vec2(x0 - p.x, p.y - y);
		float len = 0.55 - abs(f - 1.0) * 0.12;
		float tooth = q.x > 0.0 && q.x < len ? 0.035 * (1.0 - q.x / len) - abs(q.y) : -1.0;
		if (tooth > -0.012) {
			color = tooth <= 0.0 ? C_RIM : (tooth > 0.015 ? C_LAVA_HOT : C_LAVA);
			a = 1.0;
		}
	}
	// Les cailloux qui sautent derrière, en se décalant avec le temps.
	for (int i = 0; i < 4; i++) {
		float f = float(i);
		float x = -0.3 - fract(TIME * 1.6 + f * 0.27 + seed) * 0.45;
		vec2 c = vec2(x, 0.22 + 0.12 * c_hash(f, seed) - 0.06);
		float r = 0.05 + 0.03 * c_hash(f + 4.0, seed);
		float pebble = c_rock(p - c, r, f + seed);
		if (pebble > -0.012) {
			color = pebble <= 0.0 ? C_RIM : c_rock_shade(p - c, pebble, r);
			a = 1.0;
		}
	}
	// Le rocher, qui tourne sur lui-même dans le sens de la course.
	float r = 0.4;
	vec2 q = c_rot(p, -TIME * 7.0 - seed * 6.0);
	float body = c_rock(q, r, 3.0 + floor(seed * 7.0));
	if (body > -0.018) {
		a = 1.0;
		if (body <= 0.0) {
			color = C_RIM;
		} else {
			// L'éclairage reste en haut à gauche de l'écran : il se lit sur `p`, pas sur `q`.
			color = c_rock_shade(p, body, r);
			// Les fissures de lave tournent avec lui.
			for (int k = 0; k < 3; k++) {
				float ang = float(k) * 2.1 + 0.4;
				vec2 cq = c_rot(q + vec2(0.06, -0.03), -ang);
				float crack = c_crack(cq, r * 1.1, 0.035, 0.12, float(k) + 9.0);
				if (crack > 0.0) {
					color = c_lava(crack / 0.035, 1.0);
				}
			}
			// Deux cristaux verts sertis dans la roche.
			for (int k = 0; k < 2; k++) {
				vec2 at = c_rot(vec2(0.2, 0.0), float(k) * 3.4 + 1.0);
				vec2 gq = c_rot(q - at, float(k) * 1.7);
				float gem = c_gem(gq, 0.1, 0.055);
				if (gem > -0.012) {
					color = gem <= 0.0 ? C_RIM : c_gem_shade(gq, gem, 0.055);
				}
			}
		}
	}
	COLOR = vec4(color, a);
}
