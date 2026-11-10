shader_type canvas_item;
render_mode blend_mix;

// LE TROU NOIR S'EFFONDRE : il se contracte en un point, puis éclate d'un coup en étoile violette à
// huit branches, une onde noire au liseré violet court jusqu'au bout du rayon, et des vrilles retombent.

#include "res://assets/shaders/neant.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float t = progress;
	vec3 color = N_VOID;
	float a = 0.0;
	// L'onde, jusqu'au rayon du sort (0,8 du quad).
	float front = 0.1 + smoothstep(0.05, 0.55, t) * 0.72;
	float width = 0.09 * (1.0 - smoothstep(0.35, 0.85, t));
	float ring = width - abs(d - front);
	if (ring > -0.02 && width > 0.0) {
		color = ring <= 0.0 ? N_VIOLET : (ring > width * 0.5 ? N_VOID : N_DEEP);
		a = 1.0;
	}
	// Les vrilles qui partent en étoile.
	float reach = smoothstep(0.05, 0.4, t) * 0.75;
	float fade = 1.0 - smoothstep(0.5, 0.95, t);
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		vec2 q = n_rot(p, -(f / 8.0 * TAU + seed));
		float tendril = n_tendril(q - vec2(0.1, 0.0), reach, 0.07 * fade, 0.15, f + seed);
		if (tendril > -0.02 && fade > 0.0) {
			color = tendril <= 0.0 ? N_VIOLET : N_VOID;
			a = 1.0;
		}
	}
	// L'étoile de l'éclatement.
	float burst = 1.0 - smoothstep(0.0, 0.3, t);
	float star = 0.6 * burst * (0.3 + 0.7 * pow(abs(cos(atan(p.y, p.x) * 4.0)), 8.0)) - d;
	if (star > -0.02 && burst > 0.0) {
		color = star <= 0.0 ? N_RIM : (star > 0.1 ? N_PALE : N_VIOLET);
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
