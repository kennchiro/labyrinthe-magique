shader_type canvas_item;
render_mode blend_mix;

// L'AURA DE LA REINE, toute la minute : un cercle de fils d'argent tourne couché sous ses pieds, piqué de petits
// yeux émeraude, et des fils montent du cercle en ondulant jusqu'à sa croix de marionnettiste. Posée derrière
// elle : on la voit toujours.

#include "res://assets/shaders/reine.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float show = smoothstep(0.0, 0.012, progress) * (1.0 - smoothstep(0.985, 1.0, progress));
	vec3 color = vec3(0.0);
	float a = 0.0;
	vec2 g = (p - vec2(0.0, 0.64)) * vec2(1.0, 2.6);
	float d = length(g);
	vec2 rg = r_rot(g, -TIME * 0.4);
	float ang = atan(rg.y, rg.x);
	// Deux anneaux de fil, et un filet magenta qui tourne entre eux en sens inverse.
	float ring = max(0.022 - abs(d - 0.64), 0.014 - abs(d - 0.5));
	float back = atan(g.y, g.x) + TIME * 0.9;
	float dash = min(0.012 - abs(d - 0.57), abs(fract(back * 6.0 / TAU) - 0.5) - 0.18);
	if (ring > 0.0) {
		color = ring > 0.012 ? R_PALE : R_SILVER;
		a = 0.9;
	} else if (dash > 0.0) {
		color = R_MAGENTA;
		a = 0.9;
	} else if (ring > -0.012 && d < 0.7) {
		color = R_BLACK;
		a = 0.5;
	}
	// Six petits yeux sur l'anneau, qui clignent chacun à son tour.
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		float at = f * TAU / 6.0 + TIME * 0.4;
		vec2 c = vec2(cos(at), sin(at)) * 0.64;
		vec2 q = (g - c) * vec2(1.0, 0.45);
		float blink = 0.25 + 0.75 * step(0.12, fract(TIME * 0.35 + f * 0.17));
		vec3 eye = color;
		if (r_paint_eye(q, vec2(0.075, 0.04), blink, eye)) {
			color = eye;
			a = 0.95;
		}
	}
	// Les fils qui montent du cercle à la croix, au-dessus de sa tête.
	for (int i = 0; i < 4; i++) {
		float f = float(i);
		float side = f < 2.0 ? -1.0 : 1.0;
		vec2 foot = vec2(side * (0.42 + mod(f, 2.0) * 0.18), 0.6);
		vec2 top = vec2(side * 0.18, -0.92);
		vec2 q = p;
		float k = clamp((q.y - top.y) / (foot.y - top.y), 0.0, 1.0);
		float sway = sin(TIME * 2.2 + f * 1.7 + k * 5.0) * 0.05 * k;
		vec2 along = mix(top, foot, k) + vec2(sway, 0.0);
		float w = 0.008;
		if (q.y > top.y && q.y < foot.y && abs(q.x - along.x) < w + 0.006) {
			color = abs(q.x - along.x) < w ? R_SILVER : R_BLACK;
			a = max(a, 0.6 * (0.4 + 0.6 * k));
		}
	}
	COLOR = vec4(color, a * show);
}
