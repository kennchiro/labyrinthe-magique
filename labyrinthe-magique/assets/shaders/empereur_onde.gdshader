shader_type canvas_item;
render_mode blend_mix;

// L'ONDE DE CENDRES du Retour de l'Empire : un anneau de cendre grise ourlé de lave part de lui au sol, soulève des
// braises, et des pointes de couronne d'or se dressent un instant sur son passage.

#include "res://assets/shaders/empereur.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	vec2 g = p * vec2(1.0, 1.8);
	float d = length(g);
	float ang = atan(g.y, g.x);
	float r = smoothstep(0.0, 0.75, t) * 0.92;
	float fade = 1.0 - smoothstep(0.6, 1.0, t);
	float band = (0.1 * fade) - abs(d - r);
	if (band > 0.0) {
		color = band > 0.065 ? E_LAVA : (band > 0.03 ? E_ASH_LIGHT : E_ASH);
		a = 1.0;
	} else if (band > -0.015 && fade > 0.0) {
		color = E_BLACK;
		a = 1.0;
	}
	// Les pointes d'or qui se dressent sur l'anneau.
	float sector = fract(ang * 10.0 / TAU + seed) - 0.5;
	vec2 q = vec2(sector * d * 0.6, (d - r) * 1.0 + 0.08);
	float spike = e_spike(vec2(q.x, q.y + 0.04), 0.035, 0.12 * fade);
	if (spike > -0.15 && fade > 0.05 && d > 0.1) {
		color = spike <= 0.0 ? E_BLACK : (spike > 0.4 ? E_EMBER : E_GOLD);
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
