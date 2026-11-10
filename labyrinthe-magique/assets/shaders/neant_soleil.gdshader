shader_type canvas_item;
render_mode blend_mix;

// LE SOLEIL NOIR DE L'ÉCLIPSE, au-dessus de lui : un grand disque noir, sa couronne violette qui flambe
// en longs rayons, et l'anneau blanc de l'instant où le soleil s'éteint.

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
	float grow = smoothstep(0.0, 0.2, t) * (1.0 - smoothstep(0.85, 1.0, t));
	float ang = atan(p.y, p.x);
	float flare = pow(abs(cos(ang * 6.0 + TIME * 0.8)), 8.0) * 0.35 + pow(abs(cos(ang * 11.0 - TIME * 1.3)), 12.0) * 0.18;
	float corona = (0.5 + flare) * grow - length(p);
	if (corona > -0.02 && grow > 0.0) {
		color = corona <= 0.0 ? N_RIM : (corona > 0.15 ? N_DEEP : N_VIOLET);
		a = 1.0;
	}
	if (n_eclipse(p, 0.42 * grow, color) && grow > 0.0) {
		a = 1.0;
	}
	// L'anneau blanc de l'extinction, au tout début.
	float flash = 0.04 * (1.0 - smoothstep(0.1, 0.3, t)) - abs(length(p) - 0.42 * grow - 0.12 * t);
	if (flash > 0.0) {
		color = N_PALE;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
