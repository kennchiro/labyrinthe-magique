shader_type canvas_item;
render_mode blend_mix;

// LE GESTE D'ÉVEIL DU SEIGNEUR DES HEURES : deux cadrans se resserrent sur lui en tournant en sens contraire,
// douze grains d'or montent en spirale vers son cœur, puis l'éclair blanc.

#include "res://assets/shaders/heures.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = H_TEAL;
	float a = 0.0;
	float shrink = 1.0 - t * 0.6;
	if (h_dial(p, 0.82 * shrink, 0.07, t * 9.0, color)) {
		a = smoothstep(0.0, 0.12, t);
	}
	if (h_dial(p, 0.52 * shrink, 0.05, -t * 13.0, color)) {
		a = smoothstep(0.05, 0.2, t);
	}
	for (int i = 0; i < 12; i++) {
		float f = float(i);
		float ang = f / 12.0 * TAU + t * 7.0;
		float rr = mix(0.98, 0.08, t) + 0.05 * sin(f * 2.3);
		vec2 at = vec2(cos(ang), sin(ang)) * rr;
		float dm = length(p - at);
		if (dm < 0.065) {
			color = dm > 0.048 ? H_RIM : (dm < 0.025 ? H_WHITE : H_GOLD);
			a = 1.0;
		}
	}
	float flash = smoothstep(0.78, 1.0, t);
	float core = 0.42 * flash - length(p);
	if (core > 0.0) {
		color = mix(H_BRIGHT, H_WHITE, clamp(core / 0.2, 0.0, 1.0));
		a = max(a, flash);
	}
	COLOR = vec4(color, a);
}
