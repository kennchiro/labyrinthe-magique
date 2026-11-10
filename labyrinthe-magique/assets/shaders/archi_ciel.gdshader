shader_type canvas_item;
render_mode blend_mix;

// L'APOCALYPSE DE SANG : le ciel vire au rouge sombre sur tout l'écran, une pluie de sang tombe en biais, et au
// début la tête cornue de l'Archidémon se dessine dans le ciel, ses yeux d'or fendus, avant de s'effacer. Le voile
// reste clair au centre pour qu'on voie les couloirs, et la tête reste haute et petite : elle ne couvre jamais le
// héros.

#include "res://assets/shaders/archi.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

// La distance au segment [a, b], et où l'on en est le long de lui (0 en a, 1 en b).
vec2 seg(vec2 q, vec2 a, vec2 b) {
	vec2 ab = b - a;
	float h = clamp(dot(q - a, ab) / dot(ab, ab), 0.0, 1.0);
	return vec2(length(q - a - ab * h), h);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float show = smoothstep(0.0, 0.05, t) * (1.0 - smoothstep(0.9, 1.0, t));
	float edge = max(abs(p.x), abs(p.y));
	vec3 color = mix(F_SHADE, F_NIGHT, smoothstep(0.3, 1.0, edge));
	float a = (0.16 + smoothstep(0.35, 1.0, edge) * 0.32) * show;
	float drift = texture(noise, p * 0.7 + vec2(TIME * 0.03, 0.0) + seed).r;
	if (drift > 0.62) {
		color = mix(color, F_VENOM, 0.35);
		a = max(a, 0.24 * show);
	}
	// La pluie de sang, en biais.
	vec2 r = vec2(p.x + p.y * 0.25, p.y) * vec2(28.0, 3.0);
	float col = floor(r.x);
	float fall = fract(r.y * 0.25 - TIME * (1.5 + f_hash(col, 3.0)) + f_hash(col, 7.0));
	float streak = step(0.8, f_hash(col, 11.0)) * step(abs(fract(r.x) - 0.5), 0.12) * smoothstep(0.0, 0.25, fall) * step(fall, 0.3);
	if (streak > 0.0) {
		color = fall > 0.27 ? F_BRIGHT : F_VENOM;
		a = max(a, 0.8 * show);
	}
	// La tête cornue, au début.
	float head_t = smoothstep(0.0, 0.08, t) * (1.0 - smoothstep(0.24, 0.36, t));
	vec2 m = (p - vec2(0.0, -0.21)) / 0.12;
	vec2 hm = vec2(abs(m.x), m.y);
	// Le crâne s'affine vers un menton pointu.
	float skull = 0.72 - length(vec2(m.x * (1.0 + max(0.0, m.y) * 0.55), m.y * 0.95));
	// Deux cornes qui s'écartent et remontent, fines au bout.
	vec2 h1 = seg(hm, vec2(0.42, -0.42), vec2(0.95, -0.9));
	vec2 h2 = seg(hm, vec2(0.95, -0.9), vec2(0.82, -1.55));
	float horn = max(0.2 - h1.y * 0.06 - h1.x, 0.14 * (1.0 - h2.y * 0.9) - h2.x);
	float shape = max(skull, horn);
	if (head_t > 0.0 && shape > -0.05) {
		vec3 head_color = shape <= 0.0 ? F_RIM : F_NIGHT;
		if (horn > skull) {
			head_color = shape <= 0.0 ? F_RIM : (h2.y > 0.6 ? F_BRIGHT : F_NIGHT);
			// Les anneaux d'or des cornes.
			if (abs(h1.y - 0.55) < 0.07 && horn > 0.0) {
				head_color = F_BRONZE;
			}
		}
		// Les yeux fendus : rouges, à pupille d'or.
		for (int s = -1; s <= 1; s += 2) {
			vec2 e = f_rot(m - vec2(float(s) * 0.27, -0.06), float(s) * 0.4);
			float eye = 0.15 - length(e * vec2(1.0, 2.8));
			if (eye > 0.0) {
				head_color = abs(e.x) < 0.035 ? F_BRONZE : F_BRIGHT;
			}
		}
		// La gueule et ses crocs.
		if (m.y > 0.28 && m.y < 0.44 && abs(m.x) < 0.3) {
			head_color = F_RIM;
			float fang = 0.06 - abs(fract(m.x * 5.0) - 0.5) * 0.3 - abs(m.y - 0.3);
			if (fang > 0.0) {
				head_color = F_CORE;
			}
		}
		color = mix(color, head_color, head_t);
		a = max(a, 0.8 * head_t);
	}
	COLOR = vec4(color, a);
}
