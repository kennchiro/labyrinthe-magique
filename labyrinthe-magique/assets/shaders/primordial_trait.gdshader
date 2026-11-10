shader_type canvas_item;
render_mode blend_mix;

// LE TRAIT PRIMORDIAL : une lance de la matière de l'orbe en tête, gainée d'anneaux d'or qui filent vers l'arrière,
// et une pointe blanche.

#include "res://assets/shaders/primordial.gdshaderinc"

uniform float seed = 0.0;
uniform int kind = 0;

void fragment() {
	float x = UV.x;
	float y = abs(UV.y - 0.5) * 2.0;
	float body = smoothstep(1.0, 0.74, x) * pow(x, 0.7);
	vec4 matter = paint_element(kind, vec2(x * 1.4, (UV.y - 0.5) * 0.9 + seed), TIME * 1.2 + seed, (body - y) * 1.2);
	vec4 color = matter;
	// Les anneaux d'or, minces, qui glissent le long du corps.
	float slide = fract(x * 5.0 + TIME * 4.0);
	float hoop = step(0.9, slide) * step(y, body * 0.8) * step(0.3, x) * step(x, 0.8);
	color = p_over(vec4(mix(P_GOLD, P_GOLD_LIGHT, slide), hoop * 0.75), color);
	// Le filet d'or au cœur.
	float core = clamp(1.0 - y / max(0.02, body * 0.22), 0.0, 1.0) * step(0.15, x);
	color = p_over(vec4(P_GOLD_LIGHT, core * 0.8), color);
	float tip = (0.44 * smoothstep(1.0, 0.8, x) * smoothstep(0.55, 0.8, x) - y) * 3.0;
	color = p_over(vec4(P_WHITE, smoothstep(0.0, 0.25, tip)), color);
	color.a *= COLOR.a;
	COLOR = color;
}
