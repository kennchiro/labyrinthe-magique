shader_type canvas_item;
render_mode blend_mix;

// LA GUEULE QUI SE CHARGE : huit flammèches convergent vers un cœur qui s'allume, juste avant que la boule
// de feu ne parte.

#include "res://assets/shaders/legion.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = L_EMBER;
	float a = 0.0;
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float ang = f / 8.0 * TAU + seed * 4.0;
		float dist = mix(0.85, 0.15, t);
		vec2 c = vec2(cos(ang), sin(ang)) * dist;
		// Une langue pointée vers le centre.
		vec2 q = l_rot(p - c, -ang - 1.5708);
		float tongue = l_flame(q, 0.11, 0.3 * (1.0 - t * 0.5));
		if (tongue > -0.015) {
			color = tongue <= 0.0 ? vec3(0.29, 0.04, 0.02) : (tongue > 0.05 ? L_FLAME : L_EMBER);
			a = 1.0;
		}
	}
	float core = 0.12 + 0.3 * t * t - length(p);
	if (core > -0.02) {
		color = core <= 0.0 ? L_BLOOD : (core > 0.1 ? vec3(1.0, 0.97, 0.82) : L_FLAME);
		a = 1.0;
	}
	COLOR = vec4(color, a * (1.0 - smoothstep(0.85, 1.0, t)));
}
