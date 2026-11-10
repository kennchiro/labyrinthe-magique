shader_type canvas_item;
render_mode blend_mix;

// LA FIN : les yeux se ferment un à un en cercle, et le cercle de flamme s'éteint en langues qui montent.

#include "res://assets/shaders/eden.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec4 color = vec4(0.0);
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float a = f * TAU / 8.0;
		vec2 at = vec2(cos(a), sin(a)) * 0.7;
		float open = 1.0 - smoothstep(f * 0.08, f * 0.08 + 0.2, t);
		color = e_over(e_eye(p - at, 0.12, open, step(0.02, open)), color);
		float lift = smoothstep(f * 0.08, 1.0, t);
		float tongue = e_tongue(p - at - vec2(0.0, -lift * 0.4), 0.25 * (1.0 - lift), t, f);
		color = e_over(vec4(e_flame(0.6), tongue * (1.0 - lift)), color);
	}
	COLOR = color;
}
