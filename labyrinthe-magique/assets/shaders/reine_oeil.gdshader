shader_type canvas_item;
render_mode blend_mix;

// L'ŒIL DE LA REINE : un grand œil émeraude s'ouvre dans le ciel au-dessus de la cible, regarde, puis trois fils
// d'argent à cœur magenta en tombent sur elle et ses voisins. Il se referme à la fin. Quad haut : l'œil en haut,
// les fils descendent jusqu'au sol, en bas du quad.

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
	float open = smoothstep(0.0, 0.25, t) * (1.0 - smoothstep(0.82, 1.0, t));
	vec2 e = p - vec2(0.0, -0.55);
	// Le halo : des cils d'argent rayonnent autour de l'œil.
	float ang = atan(e.y, e.x);
	float lash = 0.6 * open - length(e * vec2(0.8, 1.5)) - abs(fract(ang * 14.0 / TAU) - 0.5) * 0.6;
	if (lash > 0.0 && e.y < 0.05) {
		color = lash > 0.06 ? R_SILVER : R_BLACK;
		a = 1.0;
	}
	float glow = 0.035 - abs(length(e * vec2(1.0, 2.0)) - 0.6 * open);
	if (glow > 0.0 && open > 0.1) {
		color = R_MAGENTA;
		a = 1.0;
	}
	// Trois fils tombent de l'œil : au centre, et en biais vers ses deux voisins.
	float fall = smoothstep(0.22, 0.5, t) * (1.0 - smoothstep(0.85, 1.0, t));
	for (int i = 0; i < 3; i++) {
		float f = float(i) - 1.0;
		vec2 from = vec2(f * 0.18, -0.42);
		vec2 to = vec2(f * 0.75, 0.9);
		vec2 tip = mix(from, to, fall);
		vec3 c = color;
		if (fall > 0.0 && r_paint_thread(p, from, tip, 0.016, true, c)) {
			color = c;
			a = 1.0;
		}
		// Un nœud d'émeraude au bout du fil, sur la proie.
		if (fall > 0.95 && length(p - to) < 0.06) {
			color = length(p - to) < 0.04 ? R_EMERALD : R_BLACK;
			a = 1.0;
		}
	}
	vec3 eye = color;
	if (r_paint_eye(e, vec2(0.48, 0.24), open, eye)) {
		color = eye;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
