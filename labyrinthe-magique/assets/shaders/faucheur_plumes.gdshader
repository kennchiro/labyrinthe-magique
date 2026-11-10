shader_type canvas_item;
render_mode blend_mix;

// LE PAS DE L'OMBRE, aux deux bouts : il se défait, ou se reforme, en un tourbillon de plumes noires.

#include "res://assets/shaders/faucheur.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec4 color = vec4(0.0);
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float a = f * TAU / 10.0 + t * 5.0 + seed;
		float r = 0.2 + 0.55 * t + f_hash(f, seed) * 0.15;
		vec2 at = vec2(cos(a), sin(a) * 0.7) * r;
		vec2 q = p - at;
		vec2 dir = vec2(cos(a + 1.2), sin(a + 1.2));
		float along = dot(q, dir);
		float across = dot(q, vec2(-dir.y, dir.x));
		float feather = step(abs(across), 0.05 * (1.0 - abs(along) / 0.18)) * step(abs(along), 0.18);
		color = f_over(vec4(mix(F_BLACK, F_EMBER, step(0.13, abs(along))), feather * (1.0 - t)), color);
	}
	color = f_over(vec4(F_EMBER, f_glow(length(p), 0.5) * (1.0 - t) * 0.35), color);
	COLOR = color;
}
