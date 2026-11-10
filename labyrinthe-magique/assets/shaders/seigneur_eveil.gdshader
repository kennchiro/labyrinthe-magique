shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLOSION DU SEIGNEUR : une croix de deux grandes coupes rouges s'ouvre au sol sous lui, une gerbe de pétales part
// tout autour, et un éclair blanc claque au-dessus de lui.

#include "res://assets/shaders/seigneur.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	float open = smoothstep(0.0, 0.2, t);
	float fade = 1.0 - smoothstep(0.7, 1.0, t);
	// La croix au sol, couchée.
	vec2 g = (p - vec2(0.0, 0.6)) * vec2(1.0, 2.6);
	for (int i = 0; i < 2; i++) {
		float ang = i == 0 ? 0.6 : -0.6;
		vec2 dir = vec2(cos(ang), sin(ang));
		vec3 c = color;
		if (fade > 0.0 && s_paint_cut(g, -dir * 0.95 * open, dir * 0.95 * open, 0.09 * fade, c)) {
			color = c;
			a = 1.0;
		}
	}
	// La gerbe de pétales.
	for (int i = 0; i < 12; i++) {
		float f = float(i);
		float ang = f * TAU / 12.0 + s_hash(f, seed) * 0.4;
		float reach = smoothstep(0.0, 0.8, t) * (0.6 + s_hash(f + 1.0, seed) * 0.35);
		vec2 at = vec2(cos(ang) * reach, sin(ang) * reach * 0.6 - 0.15 + t * 0.2);
		vec3 c = color;
		if (fade > 0.0 && s_paint_petal(s_rot(p - at, ang + t * 6.0), 0.07 * fade + 0.01, mod(f, 3.0) < 1.0, c)) {
			color = c;
			a = 1.0;
		}
	}
	float flash = 0.5 * (1.0 - smoothstep(0.0, 0.25, t)) - length((p - vec2(0.0, -0.4)) * vec2(1.6, 1.0))
		- abs(sin(atan(p.y + 0.4, p.x) * 2.0)) * 0.25;
	if (flash > 0.0) {
		color = flash > 0.12 ? S_WHITE : S_RED;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
