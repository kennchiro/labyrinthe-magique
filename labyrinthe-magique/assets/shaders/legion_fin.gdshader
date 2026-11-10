shader_type canvas_item;
render_mode blend_mix;

// LA FIN DE LA LÉGION : les chaînes se brisent en maillons qui volent, et le sceau s'éteint.

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
	vec2 g = (p - vec2(0.0, 0.45)) * vec2(1.0, 2.2);
	if (l_seal(g, 0.6 * (1.0 - t * 0.5), 0.08, t * 2.0, 10.0, color)) {
		a = 1.0 - smoothstep(0.3, 0.8, t);
	}
	for (int i = 0; i < 14; i++) {
		float f = float(i);
		float dir = f / 14.0 * TAU + l_hash(f, seed);
		vec2 c = vec2(cos(dir), sin(dir) * 0.7) * (0.1 + t * 0.8);
		vec2 q = l_rot(p - c, dir + t * 8.0);
		// Un maillon : un petit anneau ovale.
		float link = 0.022 - abs(length(q * vec2(1.0, 1.8)) - 0.06);
		if (link > -0.01) {
			color = link <= 0.0 ? L_RIM : (i % 2 == 0 ? L_VIOLET : L_GOLD);
			a = 1.0 - smoothstep(0.6, 1.0, t);
		}
	}
	COLOR = vec4(color, a);
}
