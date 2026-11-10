shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLOSION DU SEIGNEUR : une éclipse géante s'ouvre derrière lui, sa couronne violette jaillit en
// rayons, puis une onde noire au liseré violet part au sol en emportant des vrilles.

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
	// L'onde au sol.
	vec2 g = (p - vec2(0.0, 0.35)) * vec2(1.0, 1.8);
	float d = length(g);
	float front = 0.15 + smoothstep(0.3, 0.9, t) * 0.8;
	float width = 0.08 * (1.0 - smoothstep(0.6, 1.0, t)) * step(0.3, t);
	float ring = width - abs(d - front);
	if (ring > -0.02 && width > 0.0) {
		color = ring <= 0.0 ? N_VIOLET : N_VOID;
		a = 1.0;
	}
	// La couronne de l'éclipse, derrière lui, en haut.
	vec2 sun = p - vec2(0.0, -0.3);
	float grow = smoothstep(0.0, 0.3, t) * (1.0 - smoothstep(0.75, 1.0, t));
	float corona = (0.42 + 0.22 * pow(abs(cos(atan(sun.y, sun.x) * 8.0 + TIME)), 6.0)) * grow - length(sun);
	if (corona > -0.02 && grow > 0.0) {
		color = corona <= 0.0 ? N_RIM : (corona > 0.12 ? N_DEEP : N_VIOLET);
		a = 1.0;
	}
	if (n_eclipse(sun, 0.3 * grow, color) && grow > 0.0) {
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
