shader_type canvas_item;
render_mode blend_mix;

// PENDANT LA MINUTE : deux rubans de vent tournent lentement autour de lui, l'un devant, l'autre derrière.

#include "res://assets/shaders/souverain.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec3 color = S_SKY;
	float a = 0.0;
	float show = smoothstep(0.0, 0.01, progress) * (1.0 - smoothstep(0.98, 1.0, progress));
	for (int i = 0; i < 2; i++) {
		float f = float(i);
		vec2 q = vec2(p.x, (p.y - 0.15 + f * 0.45) * 3.0);
		float rel;
		float arc = s_arc(q, 0.8, TIME * 1.5 + f * PI, 1.8, 0.1 * show, rel);
		if (arc > -0.025 && show > 0.0) {
			color = arc <= 0.0 ? S_RIM : s_wind(arc / 0.1);
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
