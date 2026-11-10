shader_type canvas_item;
render_mode blend_mix;

// LA FUSION, sous lui pendant qu'il est fondu dans le sol : une flaque d'ombre qui ondule, cernée de
// violet, et ses deux yeux qui brillent dedans.

#include "res://assets/shaders/neant.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec2 g = p * vec2(1.0, 2.0);
	float t = progress;
	vec3 color = N_VOID;
	float a = 0.0;
	float size = 0.75 * smoothstep(0.0, 0.12, t) * (1.0 - smoothstep(0.88, 1.0, t));
	float wob = 0.06 * sin(atan(g.y, g.x) * 5.0 + TIME * 4.0);
	float pool = size + wob - length(g);
	if (pool > -0.04 && size > 0.0) {
		color = pool <= 0.0 ? N_VIOLET : (pool < 0.08 ? N_DEEP : N_VOID);
		a = 1.0;
	}
	for (int i = 0; i < 2; i++) {
		float s = float(i) * 2.0 - 1.0;
		vec2 e = (p - vec2(s * 0.14, -0.02)) * vec2(1.0, 2.2);
		float eye = 0.075 * size / 0.75 - length(e);
		if (eye > -0.012 && size > 0.0) {
			color = eye <= 0.0 ? N_VIOLET : N_PALE;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
