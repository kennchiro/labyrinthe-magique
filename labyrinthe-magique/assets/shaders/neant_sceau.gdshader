shader_type canvas_item;
render_mode blend_mix;

// LE SCEAU DU GOUFFRE, la zone : un cercle de runes violettes au sol, un fond d'ombre, et des mains
// griffues qui sortent du sol, se referment, et replongent tour à tour.

#include "res://assets/shaders/neant.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float radius_tiles = 2.0;
uniform float aura = 0.0;
uniform float seed = 0.0;
uniform float phase = 0.0;
uniform float life = 1.0;

// Une main griffue vue de dessus : une paume et trois doigts recourbés. `grip` les referme (0 à 1).
float hand(vec2 q, float size, float grip) {
	float palm = size * 0.42 - length(q * vec2(1.0, 1.3));
	float best = palm;
	for (int i = 0; i < 3; i++) {
		float f = float(i) - 1.0;
		vec2 base = vec2(f * size * 0.3, -size * 0.25);
		vec2 dir = normalize(vec2(f * (0.5 - grip * 0.45), -1.0));
		vec2 r = q - base;
		float along = dot(r, dir);
		float across = dot(r, vec2(-dir.y, dir.x));
		float len = size * (0.75 - grip * 0.3);
		float finger = along > 0.0 && along < len ? size * 0.11 * (1.0 - along / len * 0.7) - abs(across + along * along * grip * f * 1.5) : -1.0;
		best = max(best, finger);
	}
	return best;
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float open = smoothstep(0.0, 0.3, phase);
	float edge = 0.9 * open * mix(0.5, 1.0, smoothstep(0.0, 0.2, life));
	float d = length(p);
	vec3 color = N_DEEP;
	float a = 0.0;
	if (d < edge) {
		color = N_VOID;
		a = 0.45;
	}
	// L'anneau de runes, qui tourne lentement.
	float ring = 0.08 - abs(d - edge * 0.88);
	if (ring > -0.015 && edge > 0.0) {
		color = ring <= 0.0 ? N_RIM : N_DEEP;
		a = 1.0;
		float ang = atan(p.y, p.x) + phase * 0.4;
		float slot = fract(ang / TAU * 12.0);
		if (ring > 0.025 && slot > 0.25 && slot < 0.7 && abs(fract(slot * 3.0) - 0.5) < 0.3) {
			color = N_VIOLET;
		}
	}
	// Quatre mains qui sortent tour à tour.
	for (int i = 0; i < 4; i++) {
		float f = float(i);
		float cycle = fract(phase * 0.5 + f * 0.25);
		float rise = smoothstep(0.0, 0.25, cycle) * (1.0 - smoothstep(0.7, 1.0, cycle));
		float ang = f / 4.0 * TAU + 0.6 + seed;
		vec2 c = vec2(cos(ang), sin(ang)) * edge * 0.45;
		float h = hand(p - c, 0.42 * rise * open, smoothstep(0.35, 0.6, cycle));
		if (h > -0.025 && rise > 0.0) {
			color = h <= 0.0 ? N_VIOLET : N_VOID;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a * smoothstep(0.0, 0.08, life));
}
