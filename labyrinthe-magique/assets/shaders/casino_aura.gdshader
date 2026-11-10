shader_type canvas_item;
render_mode blend_mix;

// L'AURA DU MAÎTRE DU CASINO, toute la minute : un TAPIS DE ROULETTE rond tourne couché sous ses pieds, cases rouges
// et noires bordées d'or autour d'un cœur vert, et des jetons d'or tombent doucement autour de lui. Posée derrière lui.

#include "res://assets/shaders/casino.gdshaderinc"

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
	vec2 rg = k_rot(g, TIME * 0.5);
	float ang = atan(rg.y, rg.x);
	if (d > 0.48 && d < 0.66) {
		float sector = floor(ang * 18.0 / TAU);
		color = mod(sector, 2.0) < 1.0 ? K_RED : K_BLACK;
		if (abs(fract(ang * 18.0 / TAU)) < 0.05) {
			color = K_GOLD;
		}
		a = 0.85;
	}
	float rim = max(0.018 - abs(d - 0.66), 0.012 - abs(d - 0.48));
	if (rim > 0.0) {
		color = K_GOLD;
		a = 0.9;
	}
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float life = fract(TIME * 0.22 + k_hash(f, seed));
		vec2 at = vec2((k_hash(f + 3.0, seed) - 0.5) * 1.5, -0.95 + life * 1.6);
		vec2 q = vec2((p - at).x / max(abs(cos(TIME * 3.0 + f)), 0.2), (p - at).y);
		vec3 c = color;
		if (life < 0.92 && k_paint_chip(q, 0.045, c)) {
			color = c;
			a = max(a, 0.9 * (1.0 - smoothstep(0.75, 0.92, life)));
		}
	}
	COLOR = vec4(color, a * show);
}
