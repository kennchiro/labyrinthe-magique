shader_type canvas_item;
render_mode blend_mix;

// LA FIN : son ombre se défait en vrilles qui replongent dans une flaque, et la flaque se referme.

#include "res://assets/shaders/neant.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = N_VOID;
	float a = 0.0;
	vec2 g = (p - vec2(0.0, 0.4)) * vec2(1.0, 2.2);
	float pool = 0.7 * (1.0 - smoothstep(0.5, 1.0, t)) - length(g);
	if (pool > -0.04) {
		color = pool <= 0.0 ? N_VIOLET : N_VOID;
		a = 1.0;
	}
	float sink = 1.0 - smoothstep(0.0, 0.6, t);
	for (int i = 0; i < 5; i++) {
		float f = float(i);
		vec2 foot = vec2((f - 2.0) * 0.22, 0.4);
		vec2 q = n_rot(p - foot, PI * 0.5);
		// Le quart de tour couche la verticale sur +x : la vrille monte, et rentre à mesure.
		float tendril = n_tendril(q, 0.9 * sink, 0.07, 0.12, f + seed + TIME);
		if (tendril > -0.02 && sink > 0.0) {
			color = tendril <= 0.0 ? N_VIOLET : N_VOID;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
