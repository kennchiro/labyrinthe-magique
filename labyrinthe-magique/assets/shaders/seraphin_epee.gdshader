shader_type canvas_item;
render_mode blend_mix;

// L'ÉPÉE GÉANTE TOMBE, debout : une immense épée d'or pointe en bas descend du haut du quad, entourée de six ailes de
// lumière ouvertes, et touche le sol à la fin de sa vie. SKY_GROUND = 0,97 : la pointe touche à 0,94.

#include "res://assets/shaders/seraphin.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float fall = t * t;
	vec2 at = vec2(0.0, mix(-1.8, 0.29, fall));
	vec4 color = vec4(0.0);
	for (int k = 0; k < 3; k++) {
		float f = float(k);
		for (int side = 0; side < 2; side++) {
			float s = float(side) * 2.0 - 1.0;
			float lift = -0.6 + f * 0.5;
			float dir = s > 0.0 ? lift : PI - lift;
			color = s_over(s_wing(p, at + vec2(0.0, -0.2), dir, 0.45, 0.75 - f * 0.12, 4, 0.6), color);
		}
	}
	color = s_over(s_sword(p, at, 1.3, 1.0), color);
	COLOR = color;
}
