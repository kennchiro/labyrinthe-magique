shader_type canvas_item;
render_mode blend_mix;

// L'ORDRE DE LA MEUTE : un trait de runes part d'une créature vers la proie marquée. Quad étiré, x le
// long du trait.

#include "res://assets/shaders/legion.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	float t = progress;
	float x = UV.x;
	float y = (UV.y - 0.5) * 2.0;
	float head = t * 1.6;
	float tail = max(0.0, head - 0.55);
	vec3 color = L_VIOLET;
	float a = 0.0;
	if (x < head && x > tail) {
		float w = 0.35 * (0.4 + 0.6 * (x - tail) / max(0.01, head - tail));
		float d = w - abs(y);
		if (d > -0.08) {
			color = d <= 0.0 ? L_RIM : (d > w * 0.55 ? L_PALE : L_VIOLET);
			a = 1.0;
		}
		// Des runes en losange le long du trait.
		float s = fract(x * 9.0 - t * 4.0);
		float rune = 0.32 - (abs(s - 0.5) * 2.4 + abs(y));
		if (rune > 0.0 && d < 0.0) {
			color = L_GOLD;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a * (1.0 - smoothstep(0.85, 1.0, t)));
}
