shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLAT DE FILS : un pantin meurt pendant le Grand Bal et ses fils éclatent en étoile, à cœur magenta, avec un
// éclair pâle et des nœuds qui s'envolent. Blesse ses voisins.

#include "res://assets/shaders/reine.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	float flash = 0.4 * (1.0 - smoothstep(0.0, 0.3, t)) - length(p);
	if (flash > 0.0) {
		color = flash > 0.15 ? R_PALE : R_MAGENTA;
		a = 1.0;
	}
	float reach = smoothstep(0.0, 0.45, t);
	float fade = 1.0 - smoothstep(0.6, 1.0, t);
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float ai = f * TAU / 10.0 + r_hash(f, seed) * 0.4;
		float len = (0.55 + r_hash(f + 2.0, seed) * 0.4) * reach;
		vec2 dir = vec2(cos(ai), sin(ai));
		vec2 from = dir * len * 0.35 * smoothstep(0.4, 0.9, t);
		vec2 to = dir * len;
		vec3 c = color;
		if (fade > 0.0 && r_paint_thread(p, from, to, 0.02 * fade + 0.004, true, c)) {
			color = c;
			a = 1.0;
		}
		float knot = 0.05 * fade - length(p - to);
		if (knot > -0.012 && fade > 0.0) {
			color = knot > 0.0 ? R_EMERALD : R_BLACK;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
