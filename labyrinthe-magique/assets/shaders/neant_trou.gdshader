shader_type canvas_item;
render_mode blend_mix;

// LE TROU NOIR, ouvert tout le temps qu'il aspire : une grande éclipse au centre d'un disque d'accrétion
// qui s'enroule vers elle, des traits d'argent qui y plongent, et l'anneau qui palpite de plus en plus vite.

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
	float open = smoothstep(0.0, 0.15, t);
	vec2 g = p * vec2(1.0, 1.5);
	// Le disque d'accrétion : une spirale à quatre bras, plus serrée et plus rapide à mesure.
	float spin = n_spiral(g, 0.2, 4.0, 0.4, -TIME * (4.0 + t * 10.0), 0.95 * open);
	if (spin > -0.04 && length(g) > 0.2) {
		color = spin <= 0.0 ? N_VIOLET : (length(g) < 0.5 ? N_DEEP : N_VOID);
		a = 0.9;
	}
	// Les traits d'argent aspirés.
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float k = fract(t * 2.5 + f / 8.0);
		float ang = f / 8.0 * TAU + k * 1.8 + seed;
		vec2 dir = vec2(cos(ang), sin(ang));
		vec2 q = n_rot(g - dir * mix(1.0, 0.25, k), -ang);
		float streak = q.x > 0.0 && q.x < 0.18 ? 0.02 * (1.0 - k) - abs(q.y) : -1.0;
		if (streak > -0.008 && open > 0.0) {
			color = streak <= 0.0 ? N_RIM : N_SILVER;
			a = 1.0;
		}
	}
	float beat = 1.0 + 0.08 * sin(TIME * (8.0 + t * 20.0));
	if (n_eclipse(p, 0.26 * open * beat, color) && open > 0.0) {
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
