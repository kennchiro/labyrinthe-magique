shader_type canvas_item;
render_mode blend_mix;

// LE GESTE D'ÉVEIL DE LA REINE : des fils d'argent tombent du ciel l'un après l'autre et s'accrochent à ses doigts,
// puis le troisième œil s'ouvre en grand au-dessus d'elle dans un éclair émeraude.

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
	// Six fils tombent, chacun vers une main : leur bout descend, puis ils se tendent.
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		float start = f * 0.07;
		float k = clamp((t - start) / 0.3, 0.0, 1.0);
		if (k <= 0.0) {
			continue;
		}
		float side = i < 3 ? -1.0 : 1.0;
		vec2 top = vec2((r_hash(f, seed) - 0.5) * 1.6, -1.0);
		vec2 hand = vec2(side * (0.32 + r_hash(f + 2.0, seed) * 0.12), 0.3 + r_hash(f + 4.0, seed) * 0.1);
		vec2 tip = mix(top, hand, k);
		vec3 c = color;
		if (r_paint_thread(p, top, tip, 0.012, false, c)) {
			color = c;
			a = 1.0;
		}
		// Un anneau d'argent s'allume au doigt quand le fil s'y accroche.
		if (k >= 1.0 && abs(length(p - hand) - 0.045) < 0.014) {
			color = R_SILVER;
			a = 1.0;
		}
	}
	// Le troisième œil s'ouvre au-dessus d'elle.
	float open = smoothstep(0.55, 0.85, t);
	vec2 e = p - vec2(0.0, -0.62);
	float flash = smoothstep(0.78, 0.86, t) * (1.0 - smoothstep(0.88, 1.0, t));
	if (flash > 0.0) {
		float star = 0.55 * flash - length(e) - abs(sin(atan(e.y, e.x) * 4.0)) * 0.2;
		if (star > 0.0) {
			color = star > 0.12 ? R_PALE : R_EMERALD;
			a = 1.0;
		}
	}
	vec3 eye = color;
	if (open > 0.0 && r_paint_eye(r_rot(e, 1.5708), vec2(0.26, 0.12), open, eye)) {
		color = eye;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
