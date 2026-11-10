shader_type canvas_item;
render_mode blend_mix;

// LA CHARGE DE L'ÉVEIL : des runes montent du sol en spirale autour de lui, et un sceau s'ouvre sous
// ses pieds.

#include "res://assets/shaders/legion.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = L_DEEP;
	float a = 0.0;
	// Le sceau au sol, écrasé en ellipse.
	vec2 g = (p - vec2(0.0, 0.55)) * vec2(1.0, 2.4);
	if (l_seal(g, 0.7 * smoothstep(0.0, 0.4, t), 0.1, t * 4.0, 10.0, color)) {
		a = 1.0;
	}
	// Douze runes qui montent en spirale.
	for (int i = 0; i < 12; i++) {
		float f = float(i);
		float ang = f / 12.0 * TAU + t * 7.0;
		float rise = fract(f * 0.37 + t * 1.4);
		vec2 c = vec2(cos(ang) * 0.62 * (1.0 - rise * 0.35), 0.55 - rise * 1.3 + sin(ang) * 0.14);
		vec2 q = l_rot(p - c, f + t * 3.0);
		float glyph = 0.075 - (abs(q.x) + abs(q.y));
		if (glyph > -0.015 && t < 0.95) {
			color = glyph <= 0.0 ? L_RIM : (glyph > 0.04 ? L_PALE : L_VIOLET);
			a = 1.0;
		}
	}
	COLOR = vec4(color, a * (1.0 - smoothstep(0.85, 1.0, t)));
}
