shader_type canvas_item;
render_mode blend_mix;

// LA FIN : la constellation se défait étoile par étoile — les traits se rompent, et cinq étoiles montent et
// s'éteignent.

#include "res://assets/shaders/firmament.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec4 color = vec4(0.0);
	for (int i = 0; i < 5; i++) {
		float f = float(i);
		float go = smoothstep(f * 0.1, f * 0.1 + 0.5, t);
		vec2 a = r_point(i, 0.6, 0.0) + vec2(0.0, -go * 0.6);
		vec2 b = r_point(i + 1, 0.6, 0.0) + vec2(0.0, -smoothstep((f + 1.0) * 0.1, (f + 1.0) * 0.1 + 0.5, t) * 0.6);
		float broken = 1.0 - smoothstep(0.0, 0.3, t);
		color = r_over(r_ray(p, a, mix(a, b, 0.5 * broken + 0.2), 0.02, broken), color);
		color = r_over(r_star(p - a, 0.11 * (1.0 - go * 0.6), f + t * 4.0, 1.0 - go), color);
	}
	COLOR = color;
}
