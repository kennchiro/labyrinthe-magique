shader_type canvas_item;
render_mode blend_mix;

// LE TRAIT DE LA LAME FANTÔME : une coupe rouge et fine qui file d'un bout à l'autre et se referme. Quad étiré, x le
// long du trait. Avec `petal` à 1, ce sont les PÉTALES-LAMES de la Rengaine : trois pétales qui filent vers le voisin.

#include "res://assets/shaders/seigneur.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;
uniform float petal = 0.0;

void fragment() {
	float t = progress;
	float x = UV.x;
	float y = (UV.y - 0.5) * 2.0;
	vec3 color = vec3(0.0);
	float a = 0.0;
	if (petal > 0.5) {
		for (int i = 0; i < 3; i++) {
			float f = float(i);
			float at = clamp(t * 1.6 - f * 0.12, 0.0, 1.0);
			vec2 q = vec2((x - at) * 6.0, y - (f - 1.0) * 0.35);
			vec3 c = color;
			if (at > 0.0 && at < 1.0 && s_paint_petal(s_rot(q, 1.5708 + t * 10.0), 0.35, true, c)) {
				color = c;
				a = 1.0;
			}
		}
	} else {
		float head = clamp(t * 3.0, 0.0, 1.0);
		float tail = clamp(t * 2.0 - 0.6, 0.0, 1.0);
		float k = clamp((x - tail) / max(0.01, head - tail), 0.0, 1.0);
		float w = 0.22 * sin(k * 3.14159);
		float v = w - abs(y);
		if (x >= tail && x <= head && v > -0.1) {
			color = v <= 0.0 ? S_BLACK : (v > w * 0.5 ? S_BRIGHT : S_RED);
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
