shader_type canvas_item;
render_mode blend_mix;

// L'ÉCHANGE : une colonne de runes jaillit d'un sceau, là où il part et là où il arrive.

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
	float fade = 1.0 - smoothstep(0.6, 1.0, t);
	vec2 g = (p - vec2(0.0, 0.75)) * vec2(1.0, 2.6);
	if (l_seal(g, 0.48, 0.1, t * 6.0, 8.0, color)) {
		a = fade;
	}
	float height = 1.6 * smoothstep(0.0, 0.25, t);
	float w = 0.2 * (1.0 - smoothstep(0.5, 1.0, t));
	float column = w - abs(p.x);
	if (column > -0.02 && p.y < 0.75 && p.y > 0.75 - height) {
		color = column <= 0.0 ? L_RIM : (column > w * 0.5 ? L_PALE : L_VIOLET);
		// Des runes qui montent dans la colonne.
		float s = fract((p.y - t * 3.0) * 4.0);
		if (abs(s - 0.5) < 0.12 && abs(p.x) < w * 0.45) {
			color = L_GOLD;
		}
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
