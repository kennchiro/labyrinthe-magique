shader_type canvas_item;
render_mode blend_mix;

// LA FIN : les ailes de lumière se replient et se dissolvent en plumes qui tombent en tournoyant.

#include "res://assets/shaders/seraphin.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec4 color = vec4(0.0);
	float fold = 1.0 - smoothstep(0.0, 0.4, t);
	for (int side = 0; side < 2; side++) {
		float s = float(side) * 2.0 - 1.0;
		float dir = s > 0.0 ? -0.2 : PI + 0.2;
		color = s_over(s_wing(p, vec2(s * 0.1, -0.05), dir, 0.5 * fold, 0.75 * fold, 4, fold), color);
	}
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		vec2 at = vec2((s_hash(f, seed) - 0.5) * 1.4, -0.4 + t * (0.6 + s_hash(f, 4.0) * 0.6));
		float a = t * 6.0 + f;
		color = s_over(s_wing(p, at, a, 0.1, 0.12, 1, (1.0 - t) * step(0.2, t)), color);
	}
	COLOR = color;
}
