shader_type canvas_item;
render_mode blend_mix;

// LA LIGNE DE FEU du Roi-Dragon : elle s'allume derrière lui à mesure qu'il passe, d'un bord à l'autre,
// puis retombe. Quad étiré, x le long de la ligne.

#include "res://assets/shaders/legion.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	float t = progress;
	float x = UV.x;
	float y = (UV.y - 0.5) * 2.0;
	float front = t * 2.2;
	float burn = clamp((front - x) * 3.0, 0.0, 1.0) * (1.0 - smoothstep(0.65, 1.0, t));
	vec3 color = L_BLOOD;
	float a = 0.0;
	if (burn > 0.0) {
		// Des langues qui ondulent, plus hautes près du front.
		float tongue = 0.55 + 0.3 * sin(x * 70.0 + TIME * 9.0 + seed) + 0.15 * sin(x * 23.0 - TIME * 5.0);
		float w = tongue * burn;
		float d = w - abs(y);
		if (d > -0.06) {
			float k = abs(y) / max(0.01, w);
			color = d <= 0.0 ? vec3(0.29, 0.04, 0.02) : (k < 0.35 ? L_FLAME : (k < 0.7 ? L_EMBER : L_BLOOD));
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
