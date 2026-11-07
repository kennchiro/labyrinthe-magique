shader_type canvas_item;
render_mode blend_mix;

// UNE COLONNE DE LAVE DU CATACLYSME, dressée : le sol se fend sous elle, elle jaillit d'un coup à
// pleine hauteur en bouillonnant, crache des gouttes, puis retombe dans sa fissure. Le quad est haut :
// le pied est en bas (UV.y = 1).

#include "res://assets/shaders/colosse.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	float t = progress;
	// x de -1 à 1 en travers, h de 0 (pied) à 1 (sommet du quad).
	vec2 p = vec2((UV.x - 0.5) * 2.0, 1.0 - UV.y);
	vec3 color = C_LAVA;
	float a = 0.0;
	float rise = smoothstep(0.05, 0.2, t);
	float sink = smoothstep(0.65, 0.95, t);
	float top = 0.88 * rise * (1.0 - sink);
	// La fissure au pied, ovale, plus large que la colonne.
	vec2 foot = vec2(p.x, (p.y - 0.09) * 4.0);
	float crack = 0.75 * smoothstep(0.0, 0.08, t) * (1.0 - smoothstep(0.85, 1.0, t)) - length(foot);
	if (crack > -0.06) {
		a = 1.0;
		color = crack <= 0.0 ? C_RIM : (crack > 0.3 ? C_LAVA_HOT : C_LAVA_DEEP);
	}
	// La colonne, qui ondule et s'effile vers le haut.
	if (p.y > 0.06 && p.y < top + 0.06) {
		float u = (p.y - 0.06) / max(top, 0.001);
		float half_width = mix(0.55, 0.32, u) * (1.0 - sink * 0.5)
			+ 0.07 * sin(p.y * 22.0 - TIME * 14.0 + seed * 6.0);
		float inside = half_width - abs(p.x);
		if (inside > -0.06) {
			a = 1.0;
			if (inside <= 0.0) {
				color = C_RIM;
			} else {
				color = c_lava(inside / half_width, 1.0);
				// Des bulles plus sombres qui montent dans la colonne.
				float bubble = fract(p.y * 4.0 - TIME * 2.5 + c_hash(floor(p.x * 3.0), seed));
				if (bubble < 0.12 && abs(p.x) < half_width * 0.6) {
					color = C_LAVA_DEEP;
				}
			}
		}
		// La tête, une couronne de lave qui déborde.
		vec2 head = vec2(p.x, (p.y - top - 0.04) * 2.5);
		float crown = 0.5 * (1.0 - sink) - length(head);
		if (crown > -0.06 && rise > 0.5) {
			a = 1.0;
			color = crown <= 0.0 ? C_RIM : (crown > 0.25 ? C_LAVA_HOT : C_LAVA);
		}
	}
	// Les gouttes crachées sur les côtés.
	for (int i = 0; i < 4; i++) {
		float f = float(i);
		float k = fract(t * 2.2 + f * 0.25);
		float side = mod(f, 2.0) == 0.0 ? -1.0 : 1.0;
		vec2 c = vec2(side * (0.35 + k * 0.5), top * (0.6 + 0.4 * c_hash(f, seed)) + sin(k * PI) * 0.12 - k * 0.3);
		float drop = 0.07 * (1.0 - k) * (1.0 - sink) * rise - length((p - c) * vec2(1.0, 0.6));
		if (drop > -0.02) {
			a = 1.0;
			color = drop <= 0.0 ? C_RIM : C_LAVA_HOT;
		}
	}
	COLOR = vec4(color, a);
}
