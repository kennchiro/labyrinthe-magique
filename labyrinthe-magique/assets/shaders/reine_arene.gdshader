shader_type canvas_item;
render_mode blend_mix;

// L'ARÈNE DE DISCORDE : une arène ronde de fils tendus entre huit nœuds d'argent, qui tourne et se resserre, des
// traînées magenta qui convergent vers le centre (elle ATTIRE), et un petit œil émeraude au milieu. Le centre reste
// creux, semé seulement de fils : les liens entre les ennemis sont dessinés par le jeu. Elle se rompt à la fin.

#include "res://assets/shaders/reine.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float radius_tiles = 3.0;
uniform float seed = 0.0;
uniform float phase = 0.0;
uniform float life = 1.0;
uniform float aura = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float sweep = clamp(phase / 0.35, 0.0, 1.0);
	float breaking = smoothstep(0.22, 0.0, life);
	float squeeze = 0.86 - 0.04 * sin(phase * 3.0);
	vec2 q = r_rot(p, phase * 0.4 + seed);
	float ang = atan(q.y, q.x);
	vec3 color = vec3(0.0);
	float a = 0.0;
	// Le sol s'assombrit en plaques franches : on voit où l'arène mord.
	if (d < squeeze) {
		color = R_DEEP;
		a = 0.18 * sweep * (1.0 - breaking);
	}
	// L'octogone de fils tendus entre les huit nœuds, et leurs diagonales.
	float best = 1.0;
	for (int i = 0; i < 8; i++) {
		float a0 = float(i) * TAU / 8.0;
		vec2 n0 = vec2(cos(a0), sin(a0)) * squeeze;
		vec2 n1 = vec2(cos(a0 + TAU / 8.0), sin(a0 + TAU / 8.0)) * squeeze;
		vec2 n3 = vec2(cos(a0 + TAU * 3.0 / 8.0), sin(a0 + TAU * 3.0 / 8.0)) * squeeze;
		best = min(best, r_seg(q, n0, n1).x);
		best = min(best, r_seg(q, n0, n3).x * 1.6);
		// Les nœuds : des perles d'argent cernées.
		float bead = 0.065 * sweep * (1.0 - breaking) - length(q - n0);
		if (bead > -0.014) {
			color = bead > 0.0 ? (bead > 0.03 ? R_PALE : R_SILVER) : R_BLACK;
			a = 1.0;
		}
	}
	float chunks = abs(fract((ang + seed * 6.0) * 6.0 / TAU) - 0.5) - 0.5 * breaking;
	if (a < 1.0 && best < 0.016 && chunks > 0.0) {
		color = best < 0.01 ? R_SILVER : R_BLACK;
		a = sweep;
	}
	// Les traînées qui convergent vers le centre.
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float ai = f * TAU / 8.0 + TAU / 16.0;
		float k = fract(phase * 0.7 + r_hash(f, seed));
		vec2 dir = vec2(cos(ai), sin(ai));
		float along = dot(p, dir);
		float side = abs(dot(p, vec2(-dir.y, dir.x)));
		float head = squeeze * (1.0 - k) * 0.95;
		float tail = head + 0.22;
		float w = 0.03 * (along - head) / 0.22;
		if (along > head && along < tail && side < 0.035 - w && life > 0.2 && k < 0.85) {
			color = along < head + 0.05 ? R_PALE : R_MAGENTA;
			a = 0.95 * sweep;
		}
	}
	// Le petit œil du centre.
	vec3 eye = color;
	if (r_paint_eye(p, vec2(0.16, 0.08), sweep * (1.0 - breaking), eye)) {
		color = eye;
		a = 1.0;
	}
	COLOR = vec4(color, a * COLOR.a);
}
