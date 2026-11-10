shader_type canvas_item;
render_mode blend_mix;

// LE POIDS DES CHAÎNES : au-dessus d'un ennemi entravé, un CADENAS cyan se referme d'un coup sec, puis tremble tant
// qu'il est pris. À la fin, il s'ouvre et se défait. Quad posé au-dessus de sa tête.

#include "res://assets/shaders/abime.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	float shut = smoothstep(0.0, 0.12, t);
	float gone = 1.0 - smoothstep(0.88, 1.0, t);
	vec2 q = p + vec2(sin(TIME * 30.0) * 0.015 * (1.0 - smoothstep(0.12, 0.3, t)), 0.0);
	// L'anse, qui descend et se ferme.
	vec2 s = q - vec2(0.0, -0.28 - (1.0 - shut) * 0.25 + (1.0 - gone) * 0.2);
	float shackle = 0.07 - abs(length(vec2(s.x, min(s.y, 0.0))) - 0.3);
	if (s.y > 0.0) {
		shackle = 0.07 - abs(abs(s.x) - 0.3);
		shackle = min(shackle, 0.3 - s.y);
	}
	// Le corps du cadenas.
	vec2 b = q - vec2(0.0, 0.2);
	float body = min(0.45 - abs(b.x), 0.36 - abs(b.y)) * gone;
	if (body > -0.03) {
		color = body <= 0.0 ? A_OBSIDIAN : (body > 0.08 ? A_CYAN : A_DEEP);
		a = 1.0;
		if (a_keyhole(b, 0.2) > 0.0) {
			color = A_OBSIDIAN;
		}
	} else if (shackle > -0.03 && gone > 0.0) {
		color = shackle <= 0.0 ? A_OBSIDIAN : A_LINK;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
