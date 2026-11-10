shader_type canvas_item;
render_mode blend_mix;

// L'ABÎME SE REFERME : deux rangées de crocs de glace surgissent des bords et se referment au centre comme une
// mâchoire, dans un claquement blanc, puis volent en éclats.

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
	float bite = smoothstep(0.0, 0.35, t);
	float shatter = smoothstep(0.55, 0.9, t);
	for (int side = 0; side < 2; side++) {
		float sgn = side == 0 ? -1.0 : 1.0;
		float jaw = sgn * mix(0.85, 0.12, bite);
		for (int i = 0; i < 7; i++) {
			float f = float(i);
			float x = (f / 6.0 - 0.5) * 1.6;
			vec2 base = vec2(x, jaw);
			vec2 q = (p - base) * vec2(1.0, -sgn);
			q += vec2(0.0, shatter * (0.3 + a_hash(f + float(side) * 7.0, seed) * 0.4)) * sgn;
			float fang = a_shard(vec2(q.x, q.y - 0.12), 0.1, 0.22) * (1.0 - shatter);
			if (fang > -0.15 && shatter < 0.95) {
				color = fang <= 0.0 ? A_OBSIDIAN : (fang > 0.45 ? A_PALE : A_CYAN);
				a = 1.0;
			}
		}
	}
	float clap = smoothstep(0.3, 0.36, t) * (1.0 - smoothstep(0.38, 0.55, t));
	if (clap > 0.0 && abs(p.y) < 0.08 * clap && abs(p.x) < 0.9) {
		color = A_PALE;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
