shader_type canvas_item;
render_mode blend_mix;

// L'AURA D'UNE CRÉATURE DE LA LÉGION : un petit sceau qui tourne sous ses pieds, tant qu'elle en est.

#include "res://assets/shaders/legion.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec2 g = p * vec2(1.0, 2.2);
	vec3 color = L_DEEP;
	float a = 0.0;
	if (l_seal(g, 0.62, 0.11, TIME * 0.9 + seed * 6.0, 9.0, color)) {
		a = 0.9;
	}
	// Trois flammèches violettes qui montent du bord.
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		float cycle = fract(TIME * 0.8 + f / 3.0 + seed);
		vec2 c = vec2(sin(f * 2.1 + seed * 4.0) * 0.5, 0.0);
		float tongue = l_flame((p - c) * vec2(1.0, -1.0), 0.09, 0.5 * sin(cycle * 3.14));
		if (tongue > -0.012) {
			color = tongue <= 0.0 ? L_RIM : L_VIOLET;
			a = 0.9;
		}
	}
	COLOR = vec4(color, a * smoothstep(0.0, 0.01, progress) * (1.0 - smoothstep(0.985, 1.0, progress)));
}
