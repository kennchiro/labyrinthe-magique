shader_type canvas_item;
render_mode blend_mix;

// LES AILES DU VOL DU ZÉPHYR, dans son dos : deux éventails de trois plumes de vent qui s'ouvrent d'un
// coup vers le haut et les côtés, et battent pendant le vol.

#include "res://assets/shaders/souverain.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

// Une plume : un fuseau le long de +x, de 0 à `len`, épais de `w` au milieu. > 0 dedans.
float plume(vec2 q, float len, float w) {
	if (q.x < 0.0 || q.x > len || len <= 0.0) {
		return -1.0;
	}
	float s = q.x / len;
	return w * sqrt(max(0.0, s * (1.0 - s))) * 2.0 * (1.0 - 0.4 * s) - abs(q.y);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = S_SKY;
	float a = 0.0;
	float open = smoothstep(0.0, 0.12, t) * (1.0 - smoothstep(0.9, 1.0, t));
	float beat = sin(TIME * 9.0) * 0.15;
	for (int side = 0; side < 2; side++) {
		float s = side == 0 ? -1.0 : 1.0;
		vec2 q = vec2(p.x * s, p.y);
		for (int i = 0; i < 3; i++) {
			float f = float(i);
			// Du plus haut (vers le ciel) au plus bas (vers le côté).
			float ang = -(1.1 - f * 0.35) * open - beat * (1.0 - f * 0.3);
			vec2 w = s_rot(q - vec2(0.08, 0.1), -ang);
			float feather = plume(w, (0.85 - f * 0.12) * open, 0.13 - f * 0.02);
			if (feather > -0.02 && open > 0.0) {
				color = feather <= 0.0 ? S_RIM : s_wind(feather / 0.09);
				a = 1.0;
			}
		}
	}
	COLOR = vec4(color, a);
}
