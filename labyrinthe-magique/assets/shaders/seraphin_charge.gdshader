shader_type canvas_item;
render_mode blend_mix;

// LA CHARGE DE L'ÉVEIL : des plumes de lumière montent en spirale autour de lui, et l'auréole s'allume au-dessus.

#include "res://assets/shaders/seraphin.gdshaderinc"

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
		float a = f * TAU / 10.0 + t * t * 12.0;
		float rise = fract(t * 1.1 + s_hash(f, seed) * 0.5);
		vec2 at = vec2(cos(a) * 0.6, 0.7 - rise * 1.3 + sin(a) * 0.15);
		vec2 d = normalize(vec2(-sin(a), 0.5));
		color = s_over(s_wing(p, at, atan(d.y, d.x), 0.25, 0.3, 2, 1.0 - rise), color);
	}
	vec2 h = vec2(p.x, (p.y + 0.62) * 2.8);
	float halo = smoothstep(0.05, 0.0, abs(length(h) - 0.34)) * smoothstep(0.3, 0.8, t);
	color = s_over(vec4(S_GOLD, halo), color);
	color = s_over(vec4(S_EMERALD, smoothstep(0.12, 0.0, abs(length(h) - 0.34)) * 0.5 * smoothstep(0.5, 1.0, t)), color);
	COLOR = color;
}
