shader_type canvas_item;
render_mode blend_mix;

// L'ŒIL DU CYCLONE, porté sur lui : trois nuages bleu nuit tournent autour de lui, chacun crépite par
// en dessous. Ils arrivent en s'élargissant et repartent à la fin.

#include "res://assets/shaders/tempete.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

float puff(vec2 q, float r) {
	float a = r - length(q);
	a = max(a, r * 0.8 - length(q - vec2(-r * 0.9, r * 0.25)));
	a = max(a, r * 0.75 - length(q - vec2(r * 0.9, r * 0.3)));
	a = max(a, r * 0.6 - length(q - vec2(0.0, r * 0.55)));
	return a;
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = T_NIGHT;
	float a = 0.0;
	float show = smoothstep(0.0, 0.03, t) * (1.0 - smoothstep(0.96, 1.0, t));
	float flick = floor(TIME * 12.0);
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		float ang = TIME * 1.4 + f * TAU / 3.0 + seed;
		vec2 c = vec2(cos(ang) * 0.72, sin(ang) * 0.32 - 0.25) * show;
		vec2 q = p - c;
		// L'éclair qui pend sous le nuage, par moments.
		if (t_hash(f + flick, seed) > 0.55) {
			vec2 b = vec2(q.y - 0.05, q.x);
			float bolt = t_bolt(b, 0.32, 0.03, 0.12, f + flick, flick);
			if (bolt > -0.012) {
				color = bolt <= 0.0 ? T_RIM : t_bolt_color(bolt / 0.03);
				a = 1.0;
			}
		}
		float cloud = puff(q, 0.15 * show);
		if (cloud > -0.02 && show > 0.0) {
			a = 1.0;
			color = cloud <= 0.0 ? T_RIM : (q.y < -0.03 ? T_BLUE_DEEP : T_NIGHT);
		}
	}
	COLOR = vec4(color, a);
}
