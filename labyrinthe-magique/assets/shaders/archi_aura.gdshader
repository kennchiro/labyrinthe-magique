shader_type canvas_item;
render_mode blend_mix;

// L'AURA DE L'ARCHIDÉMON, pendant toute la minute : le SCEAU D'OR du pacte tourne couché sous ses pieds, et des
// GOUTTES de sang jaillissent du sceau, montent et retombent, d'autant plus nombreuses que `rage` monte (sa Rage,
// qui grandit à mesure qu'il perd des PV). Rien d'autre : le joueur a préféré le cercle et les gouttes seuls
// (2026-11-08), sans les flammes. Posée derrière le héros : on le voit toujours, surtout à 1 PV.

#include "res://assets/shaders/archi.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;
// 0 à pleine vie, 1 à 1 PV : le `Level` la met à jour quand ses PV changent.
uniform float rage = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float show = smoothstep(0.0, 0.012, progress) * (1.0 - smoothstep(0.985, 1.0, progress));
	vec3 color = vec3(0.0);
	float a = 0.0;
	// Le sceau, couché sous ses pieds, qui tourne.
	vec2 g = (p - vec2(0.0, 0.64)) * vec2(1.0, 2.6);
	float d = length(g);
	vec2 rg = f_rot(g, TIME * 0.45);
	float ang = atan(rg.y, rg.x);
	float ring = 0.03 - abs(d - 0.64);
	float inner = 0.016 - abs(d - 0.5);
	float ticks = min(0.035 - abs(d - 0.72), abs(fract(ang * 18.0 / TAU) - 0.5) * 0.25 - 0.07);
	float diamond = 0.022 - abs(abs(rg.x) + abs(rg.y) - 0.46);
	float seal = max(max(ring, inner), max(ticks, diamond));
	if (seal > 0.0) {
		color = seal > 0.016 ? F_CORE : F_BRONZE;
		a = 0.85;
	} else if (seal > -0.012 && d < 0.8) {
		color = F_RIM;
		a = 0.55;
	}
	// LES GOUTTES DE SANG MONTENT PUIS RETOMBENT : chacune jaillit du sceau, monte en arc, s'arrête au sommet et
	// redescend sur le sceau, comme une fontaine. Pointe en bas quand elle monte, pointe en haut quand elle tombe.
	// Plus il a perdu de PV, plus il en jaillit : jusqu'à douze gouttes à 1 PV.
	int drops = 8 + int(round(clamp(rage, 0.0, 1.0) * 4.0));
	for (int i = 0; i < 12; i++) {
		if (i >= drops) {
			break;
		}
		float f = float(i);
		float life = fract(TIME * 0.5 + f_hash(f, seed));
		float start_x = (f_hash(f + 3.0, seed) - 0.5) * 1.3;
		float drift = (f_hash(f + 5.0, seed) - 0.5) * 0.5;
		float peak = 0.75 + f_hash(f + 7.0, seed) * 0.7;
		float arc = sin(life * PI);
		vec2 at = vec2(start_x + drift * life, 0.64 - peak * arc);
		vec2 q = p - at;
		bool rising = life < 0.5;
		float drop = f_drop(rising ? vec2(q.x, -q.y) : q, 0.05);
		if (drop > 0.0) {
			color = drop > 0.022 ? F_VENOM : F_SHADE;
			if (drop > 0.035) {
				color = F_BRIGHT;
			}
			a = 0.95;
		}
	}
	COLOR = vec4(color, a * show);
}
