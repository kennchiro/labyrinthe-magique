shader_type canvas_item;
render_mode blend_mix;

// LA CHARGE DE L'ÉVEIL : des âmes pâles montent du sol autour de lui et tournent de plus en plus vite.

#include "res://assets/shaders/faucheur.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec4 color = vec4(0.0);
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		float a = f * TAU / 6.0 + t * t * 14.0;
		float lift = fract(t * 0.9 + f_hash(f, seed) * 0.4);
		vec2 at = vec2(cos(a) * 0.6 * (1.0 - t * 0.4), 0.7 - lift * 1.3 + sin(a) * 0.15);
		vec2 trail = normalize(vec2(sin(a), 0.6));
		color = f_over(f_soul(p - at, 0.1, trail, smoothstep(0.0, 0.2, t)), color);
	}
	COLOR = color;
}
