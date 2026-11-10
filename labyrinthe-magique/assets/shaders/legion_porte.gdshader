shader_type canvas_item;
render_mode blend_mix;

// LA PORTE DES ABYSSES, la zone : un cercle de runes ouvert sur un gouffre violet qui tourne, d'où des
// griffes surgissent tour à tour, et deux yeux qui regardent.

#include "res://assets/shaders/legion.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float radius_tiles = 2.0;
uniform float aura = 0.0;
uniform float seed = 0.0;
uniform float phase = 0.0;
uniform float life = 1.0;

// Une griffe recourbée qui sort vers +y local, de longueur `len`.
float claw(vec2 q, float len) {
	if (q.y < 0.0 || q.y > len || len <= 0.0) {
		return -1.0;
	}
	float k = q.y / len;
	return 0.07 * (1.0 - k) - abs(q.x - k * k * 0.12);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float open = smoothstep(0.0, 0.4, phase);
	float edge = 0.88 * open * mix(0.4, 1.0, smoothstep(0.0, 0.15, life));
	float d = length(p);
	vec3 color = L_VOID;
	float a = 0.0;
	if (d < edge) {
		// Le gouffre : une spirale qui s'enroule vers le centre.
		float ang = atan(p.y, p.x) + phase * 1.2;
		float f = fract(d / 0.22 - ang / TAU * 3.0);
		color = f < 0.45 ? L_DEEP : L_VOID;
		if (abs(f - 0.45) < 0.05) {
			color = L_VIOLET * 0.8;
		}
		a = 0.92;
	}
	if (l_seal(p, edge * 0.92, 0.09, phase * 0.5, 14.0, color)) {
		a = 1.0;
	}
	// Les yeux, au fond.
	float blink = step(0.08, abs(fract(phase * 0.3 + seed) - 0.5));
	for (int i = 0; i < 2; i++) {
		vec2 e = (p - vec2(float(i) * 0.3 - 0.15, -0.05)) / max(0.01, open);
		float eye = 0.09 - (abs(e.x) + e.y * e.y * 9.0);
		if (eye > 0.0 && blink > 0.5) {
			color = eye > 0.04 ? L_PALE : L_VIOLET;
			a = 1.0;
		}
	}
	// Quatre griffes qui sortent du bord tour à tour.
	for (int i = 0; i < 4; i++) {
		float fi = float(i);
		float cycle = fract(phase * 0.45 + fi * 0.25);
		float rise = smoothstep(0.0, 0.3, cycle) * (1.0 - smoothstep(0.6, 1.0, cycle));
		float ang = fi / 4.0 * TAU + 0.4 + seed;
		vec2 dir = vec2(cos(ang), sin(ang));
		vec2 base = dir * edge * 0.62;
		for (int k = 0; k < 3; k++) {
			float fk = float(k) - 1.0;
			vec2 side = vec2(-dir.y, dir.x);
			vec2 q = p - base - side * fk * 0.08;
			vec2 local = vec2(dot(q, side), dot(q, -dir));
			float c = claw(local, 0.32 * rise * open);
			if (c > -0.015 && rise > 0.0) {
				color = c <= 0.0 ? L_RIM : L_BONE;
				a = 1.0;
			}
		}
	}
	COLOR = vec4(color, a * smoothstep(0.0, 0.1, life));
}
