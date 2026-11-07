shader_type canvas_item;
render_mode blend_mix;

// UN PAS DU COLOSSE : le sol se fend sous son pied, la lave luit un instant dans la fente, puis elle
// refroidit et s'efface.

#include "res://assets/shaders/colosse.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = C_RIM;
	float a = 0.0;
	float open = smoothstep(0.0, 0.1, t);
	float heat = 1.0 - smoothstep(0.2, 0.9, t);
	float fade = 1.0 - smoothstep(0.7, 1.0, t);
	vec2 g = p * vec2(1.0, 1.7);
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		vec2 q = c_rot(g, -(f / 3.0 * TAU + seed * 5.0));
		float crack = c_crack(q, 0.75 * open, 0.1 * fade, 0.25, f + seed * 7.0);
		if (crack > -0.025 && fade > 0.0) {
			color = crack <= 0.0 ? C_RIM : c_lava(crack / 0.1, heat);
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
