shader_type canvas_item;
render_mode blend_mix;

// LA MARQUE DU GRIMOIRE : un sceau dressé au-dessus de la proie, un œil ouvert en son centre. Toute la
// meute la regarde.

#include "res://assets/shaders/legion.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float pop = smoothstep(0.0, 0.05, t) * (1.0 + 0.25 * (1.0 - smoothstep(0.0, 0.12, t)));
	vec3 color = L_DEEP;
	float a = 0.0;
	if (l_seal(p, 0.68 * pop, 0.12, TIME * 1.6, 8.0, color)) {
		a = 1.0;
	}
	// L'œil : une amande pâle, un iris violet, une pupille fendue.
	vec2 e = p / max(0.01, pop);
	float lid = 0.42 - (abs(e.x) * 0.9 + e.y * e.y * 3.2);
	float blink = step(0.06, abs(fract(TIME * 0.4 + seed) - 0.5));
	if (lid > -0.03 && blink > 0.5) {
		color = lid <= 0.0 ? L_RIM : L_PALE;
		float iris = 0.2 - length(e);
		if (iris > 0.0) {
			color = iris < 0.03 ? L_RIM : L_VIOLET;
			if (abs(e.x) < 0.045) {
				color = L_RIM;
			}
		}
		a = 1.0;
	}
	COLOR = vec4(color, a * (1.0 - smoothstep(0.9, 1.0, t)));
}
