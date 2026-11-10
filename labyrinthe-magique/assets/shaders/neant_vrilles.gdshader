shader_type canvas_item;
render_mode blend_mix;

// IL SURGIT : une couronne de vrilles d'ombre jaillit du sol tout autour de lui et frappe, puis replonge.
// Les vrilles se dressent vers le haut de l'écran, comme des lances noires au liseré violet.

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
	float rise = smoothstep(0.0, 0.18, t) * (1.0 - smoothstep(0.55, 0.95, t));
	// La flaque d'où elles sortent.
	vec2 g = (p - vec2(0.0, 0.35)) * vec2(1.0, 2.4);
	float pool = 0.8 * smoothstep(0.0, 0.1, t) * (1.0 - smoothstep(0.7, 1.0, t)) - length(g);
	if (pool > -0.04) {
		color = pool <= 0.0 ? N_VIOLET : N_VOID;
		a = 1.0;
	}
	for (int i = 0; i < 7; i++) {
		float f = float(i);
		float ang = f / 7.0 * TAU + seed;
		vec2 foot = vec2(cos(ang) * 0.6, 0.35 + sin(ang) * 0.25);
		vec2 q = n_rot(p - foot, PI * 0.5);
		float len = (0.55 + 0.25 * n_hash(f, seed)) * rise;
		// Le quart de tour couche la verticale sur +x : la vrille monte.
		float tendril = n_tendril(q, len, 0.08, 0.1, f + seed);
		if (tendril > -0.025 && rise > 0.0) {
			color = tendril <= 0.0 ? N_VIOLET : N_VOID;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
