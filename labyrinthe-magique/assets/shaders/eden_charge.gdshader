shader_type canvas_item;
render_mode blend_mix;

// LA CHARGE DE L'ÉVEIL : huit yeux d'or s'ouvrent un à un en cercle autour de lui, et le cercle tourne de plus en
// plus vite, cerclé de flamme saphir.

#include "res://assets/shaders/eden.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec4 color = vec4(0.0);
	float turn = t * t * 8.0;
	float ring = smoothstep(0.03, 0.0, abs(length(p) - 0.78)) * smoothstep(0.2, 0.6, t);
	color = e_over(vec4(e_flame(0.6), ring), color);
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float a = f * TAU / 8.0 + turn;
		vec2 at = vec2(cos(a), sin(a)) * 0.7;
		float open = smoothstep(f * 0.09, f * 0.09 + 0.15, t);
		color = e_over(e_eye(p - at, 0.13, open, step(0.01, open)), color);
	}
	COLOR = color;
}
