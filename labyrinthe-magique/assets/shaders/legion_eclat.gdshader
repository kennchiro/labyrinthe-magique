shader_type canvas_item;
render_mode blend_mix;

// LE DIABLOTIN EXPLOSE : une gerbe de flammes violettes en couronne, et un anneau qui part.

#include "res://assets/shaders/legion.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = L_VIOLET;
	float a = 0.0;
	float grow = smoothstep(0.0, 0.35, t);
	float fade = 1.0 - smoothstep(0.55, 1.0, t);
	// Huit langues de flamme en étoile, trois couches.
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float ang = f / 8.0 * TAU + seed * 3.0;
		vec2 q = l_rot(p, -ang + 1.5708);
		float h = 0.78 * grow * fade * (0.75 + 0.25 * l_hash(f, seed));
		float tongue = l_flame(q - vec2(0.0, 0.08), 0.2, h);
		if (tongue > -0.02 && h > 0.02) {
			float k = q.y / max(0.01, h);
			color = tongue <= 0.0 ? L_RIM : (tongue > 0.1 ? L_PALE : (k > 0.5 ? L_DEEP : L_VIOLET));
			a = 1.0;
		}
	}
	// Le cœur.
	float core = 0.3 * (1.0 - smoothstep(0.2, 0.6, t)) - length(p);
	if (core > -0.02) {
		color = core <= 0.0 ? L_RIM : L_PALE;
		a = 1.0;
	}
	// L'anneau.
	float front = 0.25 + t * 0.6;
	float ring = 0.04 * fade - abs(length(p) - front);
	if (ring > -0.012 && t > 0.1) {
		color = ring <= 0.0 ? L_RIM : L_VIOLET;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
