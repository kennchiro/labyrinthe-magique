shader_type canvas_item;
render_mode blend_mix;

// L'AURA DU GARDIEN, toute la minute : un CERCLE DE MAILLONS givrés tourne couché sous lui, et de petits CRISTAUX DE
// GLACE tombent doucement autour de lui. Posée derrière lui.

#include "res://assets/shaders/abime.gdshaderinc"

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
	vec2 rg = a_rot(g, TIME * 0.3);
	float ang = atan(rg.y, rg.x);
	float n = 16.0;
	float k = floor(ang * n / TAU + 0.5);
	float at_ang = k * TAU / n;
	vec2 c = vec2(cos(at_ang), sin(at_ang)) * 0.62;
	vec2 q = a_rot(rg - c, -at_ang - 1.5708);
	vec3 col = color;
	if (a_paint_link(mod(k, 2.0) > 0.5 ? vec2(q.x, q.y * 2.0) : q, 0.13, 0.07, col)) {
		color = col;
		a = 0.9;
	}
	float frost = 0.012 - abs(d - 0.5);
	if (frost > 0.0) {
		color = A_CYAN;
		a = max(a, 0.7);
	}
	for (int i = 0; i < 9; i++) {
		float f = float(i);
		float life = fract(TIME * 0.2 + a_hash(f, seed));
		vec2 at = vec2((a_hash(f + 3.0, seed) - 0.5) * 1.5, -0.95 + life * 1.6);
		vec2 sq = a_rot(p - at, TIME * (0.8 + f * 0.2));
		float s = a_shard(sq, 0.025, 0.05);
		if (s > -0.25 && life < 0.92) {
			color = s <= 0.0 ? A_OBSIDIAN : (s > 0.5 ? A_PALE : A_CYAN);
			a = max(a, 0.85 * (1.0 - smoothstep(0.75, 0.92, life)));
		}
	}
	COLOR = vec4(color, a * show);
}
