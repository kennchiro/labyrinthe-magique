shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLOSION DE LA REINE : un anneau de fils d'argent part de ses pieds et s'élargit, ses fils jaillissent en étoile
// et se tendent, et un grand œil émeraude s'ouvre au-dessus d'elle avant de se refermer en éclair.

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
	// L'anneau couché à ses pieds, qui s'élargit.
	vec2 g = (p - vec2(0.0, 0.55)) * vec2(1.0, 2.6);
	float d = length(g);
	float r = mix(0.1, 0.92, smoothstep(0.0, 0.5, t));
	float fade = 1.0 - smoothstep(0.7, 1.0, t);
	float ring = 0.03 * fade - abs(d - r);
	if (ring > 0.0) {
		color = ring > 0.015 ? R_PALE : R_SILVER;
		a = 1.0;
	} else if (ring > -0.016 && fade > 0.0) {
		color = R_MAGENTA;
		a = 1.0;
	}
	// Les fils en étoile, du centre vers l'anneau.
	float ang = atan(g.y, g.x);
	float spoke = abs(fract(ang * 10.0 / TAU + seed) - 0.5);
	if (d < r && spoke < 0.03 * fade && d > 0.1) {
		color = R_SILVER;
		a = 1.0;
	}
	// Des fils jaillissent vers le haut et retombent.
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float x0 = (r_hash(f, seed) - 0.5) * 1.4;
		float h = smoothstep(0.05, 0.4, t) * (0.7 + r_hash(f + 1.0, seed) * 0.5) * fade;
		vec2 foot = vec2(x0 * 0.6, 0.55);
		vec2 head = vec2(x0, 0.55 - h * 1.4);
		vec3 c = color;
		if (h > 0.0 && r_paint_thread(p, foot, head, 0.011, i % 2 == 0, c)) {
			color = c;
			a = 1.0;
		}
	}
	// Le grand œil s'ouvre au-dessus d'elle.
	float open = smoothstep(0.15, 0.4, t) * (1.0 - smoothstep(0.8, 0.95, t));
	vec3 eye = color;
	vec2 e = p - vec2(0.0, -0.6);
	if (open > 0.0) {
		float halo = 0.03 - abs(length(e * vec2(1.0, 1.8)) - 0.42 - 0.05 * sin(TIME * 8.0));
		if (halo > 0.0) {
			color = R_EMERALD;
			a = 1.0;
		}
		if (r_paint_eye(e, vec2(0.36, 0.17), open, eye)) {
			color = eye;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
