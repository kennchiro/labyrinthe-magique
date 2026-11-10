shader_type canvas_item;
render_mode blend_mix;

// LE GRAND BAL : l'écran s'assombrit en vert sapin, une immense croix de marionnettiste paraît en haut du ciel,
// son œil émeraude s'ouvre, et des fils d'argent en descendent en se balançant sur toute la salle. Le voile reste
// clair au centre pour qu'on voie les couloirs, et la croix reste haute : elle ne couvre jamais l'héroïne.

#include "res://assets/shaders/reine.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;
// La durée du bal, en secondes : les fils dansent au rythme du temps réel, pas de `progress`.
uniform float seconds = 8.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float show = smoothstep(0.0, 0.04, t) * (1.0 - smoothstep(0.92, 1.0, t));
	float edge = max(abs(p.x), abs(p.y));
	vec3 color = mix(R_PINE, R_BLACK, smoothstep(0.3, 1.0, edge));
	float a = (0.2 + smoothstep(0.35, 1.0, edge) * 0.36) * show;
	float drift = texture(noise, p * 0.7 + vec2(TIME * 0.03, 0.0) + seed).r;
	if (drift > 0.64) {
		color = mix(color, R_DEEP, 0.5);
		a = max(a, 0.22 * show);
	}
	// La croix, haute dans le ciel, qui descend un peu au début.
	float arrive = smoothstep(0.0, 0.1, t);
	// Le quad déborde largement de l'écran : comme la tête de l'Apocalypse, la croix se tient à -0,25.
	vec2 c = vec2(0.0, -0.25 - 0.08 * (1.0 - arrive));
	vec2 q = (p - c) / 0.11;
	q = r_rot(q, sin(TIME * 1.3) * 0.05);
	float cross_v = r_cross(q, 1.0);
	// Les fils, accrochés aux bouts de la croix, descendent en se balançant sur la salle.
	for (int i = 0; i < 12; i++) {
		float f = float(i);
		float x_top = (f / 11.0 - 0.5) * 0.11;
		vec2 top = c + vec2(x_top, 0.004);
		float x_bot = (f / 11.0 - 0.5) * 0.9 + sin(TIME * 1.6 + f * 0.9) * 0.03;
		vec2 bot = vec2(x_bot, 0.45);
		float k = clamp((t - 0.06 - f * 0.006) / 0.12, 0.0, 1.0);
		vec2 tip = mix(top, bot, k);
		vec3 th = color;
		if (k > 0.0 && r_paint_thread(p, top, tip, 0.0018, false, th)) {
			color = th;
			a = max(a, 0.75 * show);
		}
	}
	if (cross_v > -0.03 * 3.3) {
		color = cross_v > 0.0 ? (cross_v > 0.04 ? R_SILVER : mix(R_SILVER, R_PALE, 0.5)) : R_BLACK;
		a = max(a, 0.95 * show * arrive);
	}
	// L'œil au croisement.
	vec3 eye = color;
	float open = smoothstep(0.08, 0.18, t) * show;
	if (r_paint_eye(q, vec2(0.3, 0.14), open, eye)) {
		color = eye;
		a = max(a, show);
	}
	COLOR = vec4(color, a);
}
