shader_type canvas_item;
render_mode blend_mix;

// LA FIN DE L'ÉVEIL DE L'EMPEREUR : le sceau se fend et s'éteint, les dernières flammes retombent en fumée, et des
// cendres grises tombent sur lui. La couronne redevient brisée.

#include "res://assets/shaders/empereur.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	vec2 g = (p - vec2(0.0, 0.6)) * vec2(1.0, 2.6);
	float d = length(g);
	float ang = atan(g.y, g.x);
	float chunks = abs(fract((ang + seed * 6.0) * 6.0 / TAU) - 0.5) - 0.1 - t * 0.35;
	float ring = min(0.025 * (1.0 - t) - abs(d - 0.6 - t * 0.2), chunks);
	if (ring > 0.0) {
		color = mix(E_LAVA, E_ASH, smoothstep(0.1, 0.6, t));
		a = 1.0;
	}
	// La fumée monte en boules grises.
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		vec2 at = vec2((e_hash(f, seed) - 0.5) * 1.0, 0.5 - t * (0.9 + e_hash(f + 2.0, seed) * 0.5));
		float r = 0.08 + t * 0.12;
		float puff = r - length(p - at);
		if (puff > -0.015 && t < 0.9) {
			color = puff <= 0.0 ? E_BLACK : (puff > r * 0.5 ? E_ASH_LIGHT : E_ASH);
			a = 1.0 - smoothstep(0.6, 0.9, t);
		}
	}
	// Les cendres qui tombent sur lui.
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		vec2 at = vec2((e_hash(f + 5.0, seed) - 0.5) * 1.4, -0.9 + t * 1.5 + e_hash(f + 7.0, seed) * 0.3);
		float flake = e_spike(e_rot(p - at, f + t * 6.0), 0.03, 0.02);
		if (flake > 0.0) {
			color = E_ASH_LIGHT;
			a = 1.0 - t;
		}
	}
	COLOR = vec4(color, a);
}
