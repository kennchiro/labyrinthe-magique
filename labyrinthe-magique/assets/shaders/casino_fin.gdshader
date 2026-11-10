shader_type canvas_item;
render_mode blend_mix;

// LA FIN DE L'ÉVEIL DU MAÎTRE DU CASINO : le tapis de roulette se replie vers le centre, et les derniers jetons
// retombent et s'éteignent. La banque ferme.

#include "res://assets/shaders/casino.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	vec2 g = (p - vec2(0.0, 0.6)) * vec2(1.0, 2.6);
	float d = length(g);
	float r = 0.62 * (1.0 - t);
	if (abs(d - r) < 0.06 * (1.0 - t)) {
		color = mod(floor(atan(g.y, g.x) * 18.0 / TAU), 2.0) < 1.0 ? K_RED : K_BLACK;
		a = 1.0;
	}
	for (int i = 0; i < 7; i++) {
		float f = float(i);
		vec2 at = vec2((k_hash(f, seed) - 0.5) * 1.3, -0.8 + t * 1.4 + k_hash(f + 2.0, seed) * 0.3);
		vec3 c = color;
		if (t < 0.92 && k_paint_chip(p - at, 0.05 * (1.0 - t * 0.5), c)) {
			color = c;
			a = 1.0 - t;
		}
	}
	COLOR = vec4(color, a);
}
