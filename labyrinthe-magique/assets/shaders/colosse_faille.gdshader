shader_type canvas_item;
render_mode blend_mix;

// LA FAILLE, ce qui reste planté : une case fendue de lave, hérissée de trois pics de roche qui
// jaillissent, rougeoient, puis s'effondrent quand la zone s'éteint.

#include "res://assets/shaders/colosse.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float radius_tiles = 0.5;
uniform float aura = 0.0;
uniform float seed = 0.0;
uniform float phase = 0.0;
uniform float life = 1.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec3 color = C_ROCK;
	float a = 0.0;
	float rise = smoothstep(0.0, 0.14, phase);
	float overshoot = 1.0 + 0.25 * sin(clamp(phase / 0.3, 0.0, 1.0) * PI);
	float stand = smoothstep(0.0, 0.3, life);
	float heat = 0.55 + 0.45 * sin(phase * 6.0 + seed * 10.0);
	heat = mix(0.25, heat, smoothstep(0.0, 0.4, life));
	// La fente de lave en travers de la case.
	vec2 cq = c_rot(p, seed * 6.283) + vec2(0.85, 0.0);
	float crack = c_crack(cq, 1.7, 0.13 * rise, 0.3, seed * 17.0);
	if (crack > -0.04 && rise > 0.0) {
		color = crack <= 0.0 ? C_RIM : c_lava(crack / 0.13, heat);
		a = 1.0;
	}
	// Les trois pics, du plus loin au plus proche pour que le plus bas passe devant.
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		vec2 base = vec2((f - 1.0) * 0.42 + (c_hash(f, seed) - 0.5) * 0.15, 0.1 + 0.18 * f - 0.1);
		float h = (0.75 + 0.35 * c_hash(f + 3.0, seed)) * rise * overshoot * stand;
		float w = 0.2 * stand;
		vec2 q = p - base;
		q.x += q.y * (c_hash(f + 7.0, seed) - 0.5) * 0.4;
		float spike = c_spike(q, h, w);
		if (spike > -0.035 && h > 0.0) {
			a = 1.0;
			if (spike <= 0.0) {
				color = C_RIM;
			} else {
				color = q.x < -w * 0.1 * (1.0 + q.y / h) ? C_ROCK_LIGHT : C_ROCK;
				// La lave monte dans le pic, le long d'une veine.
				if (abs(q.x - q.y * 0.08) < 0.025 && q.y > -h * 0.7) {
					color = c_lava(0.8, heat);
				}
			}
		}
	}
	COLOR = vec4(color, a * smoothstep(0.0, 0.08, life));
}
