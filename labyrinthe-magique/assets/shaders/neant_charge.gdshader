shader_type canvas_item;
render_mode blend_mix;

// LE GESTE D'ÉVEIL : les ombres du sol rampent vers lui de tous les côtés, en vrilles qui se resserrent,
// et un cercle violet se referme sous ses pieds.

#include "res://assets/shaders/neant.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec2 g = (p - vec2(0.0, 0.4)) * vec2(1.0, 2.0);
	float t = progress;
	vec3 color = N_VOID;
	float a = 0.0;
	float ring = 0.05 - abs(length(g) - mix(0.95, 0.3, t));
	if (ring > -0.02) {
		color = ring <= 0.0 ? N_RIM : N_VIOLET;
		a = 1.0;
	}
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float ang = f / 8.0 * TAU + seed;
		vec2 start = vec2(cos(ang), sin(ang)) * 0.95;
		vec2 q = n_rot(g - start, -(ang + PI));
		float tendril = n_tendril(q, 0.95 * smoothstep(0.0, 0.8, t), 0.07, 0.15, f + TIME);
		if (tendril > -0.02) {
			color = tendril <= 0.0 ? N_VIOLET : N_VOID;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
