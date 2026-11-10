shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLOSION DU GARDIEN : les chaînes éclatent en maillons qui volent, un anneau de clés s'allume au-dessus de lui, et
// une onde de givre part au sol, hérissée de cristaux.

#include "res://assets/shaders/abime.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	float fade = 1.0 - smoothstep(0.7, 1.0, t);
	// L'onde de givre couchée.
	vec2 g = (p - vec2(0.0, 0.62)) * vec2(1.0, 2.6);
	float d = length(g);
	float r = smoothstep(0.0, 0.7, t) * 0.95;
	float band = 0.05 * fade - abs(d - r);
	if (band > 0.0) {
		color = band > 0.03 ? A_PALE : A_CYAN;
		a = 1.0;
	}
	float ang = atan(g.y, g.x);
	float sector = fract(ang * 12.0 / TAU + seed) - 0.5;
	vec2 sq = vec2(sector * d * 0.5, (d - r) + 0.06);
	float shard = a_shard(sq, 0.03, 0.14 * fade);
	if (shard > -0.2 && fade > 0.05 && d > 0.1) {
		color = shard <= 0.0 ? A_OBSIDIAN : (shard > 0.5 ? A_PALE : A_CYAN);
		a = 1.0;
	}
	// Les maillons qui volent.
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float an = f * TAU / 10.0 + a_hash(f, seed);
		float reach = smoothstep(0.0, 0.6, t) * (0.5 + a_hash(f + 1.0, seed) * 0.4);
		vec2 at = vec2(cos(an) * reach, sin(an) * reach * 0.6 - 0.1 + t * t * 0.4);
		vec3 c = color;
		if (fade > 0.0 && a_paint_link(a_rot(p - at, an + t * 9.0), 0.07, 0.045, c)) {
			color = c;
			a = 1.0;
		}
	}
	// L'anneau de clés qui s'allume au-dessus de lui.
	vec2 k = (p - vec2(0.0, -0.72)) * vec2(1.0, 2.2);
	float lit = smoothstep(0.15, 0.4, t) * fade;
	float hoop = 0.03 * lit - abs(length(k) - 0.3);
	if (hoop > 0.0) {
		color = A_CYAN;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
