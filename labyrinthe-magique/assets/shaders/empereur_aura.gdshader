shader_type canvas_item;
render_mode blend_mix;

// L'AURA DE L'EMPEREUR, toute la minute : un SCEAU IMPÉRIAL de lave tourne couché sous ses pieds, cerclé d'or et
// hérissé de pointes de couronne, et des CENDRES tombent doucement autour de lui, certaines encore rougeoyantes.
// Posée derrière lui : on le voit toujours.

#include "res://assets/shaders/empereur.gdshaderinc"

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
	vec2 rg = e_rot(g, TIME * 0.35);
	float ang = atan(rg.y, rg.x);
	float ring = max(0.026 - abs(d - 0.64), 0.014 - abs(d - 0.5));
	// Les pointes de couronne, tournées vers l'extérieur.
	float sector = fract(ang * 8.0 / TAU) - 0.5;
	float points = (0.12 - abs(sector) * 0.28) - (d - 0.66);
	points = min(points, d - 0.64);
	float lava = 0.012 - abs(d - 0.57 - 0.012 * sin(ang * 6.0 + TIME * 3.0));
	if (ring > 0.0) {
		color = ring > 0.014 ? E_EMBER : E_GOLD;
		a = 0.9;
	} else if (points > 0.0) {
		color = points > 0.03 ? E_GOLD : E_BLACK;
		a = 0.9;
	} else if (lava > 0.0) {
		color = E_LAVA;
		a = 0.9;
	} else if ((ring > -0.012 || points > -0.012) && d < 0.82) {
		color = E_BLACK;
		a = 0.55;
	}
	// Les cendres qui tombent, en losanges qui tournent ; une sur trois rougeoie encore.
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float life = fract(TIME * 0.22 + e_hash(f, seed));
		vec2 at = vec2((e_hash(f + 3.0, seed) - 0.5) * 1.5 + sin(TIME + f) * 0.06, -0.95 + life * 1.6);
		vec2 q = e_rot(p - at, TIME * (1.0 + f * 0.2));
		float flake = e_spike(q, 0.035, 0.022);
		if (flake > -0.25 && life < 0.92) {
			bool hot = mod(f, 3.0) < 1.0;
			color = flake <= 0.0 ? E_BLACK : (hot ? E_EMBER : E_ASH_LIGHT);
			a = max(a, 0.85 * (1.0 - smoothstep(0.75, 0.92, life)));
		}
	}
	COLOR = vec4(color, a * show);
}
