shader_type canvas_item;
render_mode blend_mix;

// LE CHOC CONTRE LE MUR, sous le Souffle du titan : une étoile blanche, et trois petites spirales
// d'étourdissement qui tournent un instant au-dessus.

#include "res://assets/shaders/souverain.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = S_WHITE;
	float a = 0.0;
	float r = 0.55 * (1.0 - smoothstep(0.0, 0.4, t));
	float star = r * (0.35 + 0.65 * pow(abs(cos(atan(p.y, p.x) * 4.0)), 6.0)) - length(p);
	if (star > -0.02 && r > 0.0) {
		color = star <= 0.0 ? S_RIM : (star > 0.06 ? S_WHITE : S_SKY);
		a = 1.0;
	}
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		float ang = TIME * 5.0 + f / 3.0 * TAU;
		vec2 c = vec2(cos(ang) * 0.45, -0.55 + sin(ang) * 0.15);
		float spin = s_spiral(p - c, 0.06, 1.0, 0.5, TIME * 8.0, 0.13 * smoothstep(0.1, 0.25, t) * (1.0 - smoothstep(0.8, 1.0, t)));
		if (spin > 0.0) {
			color = S_SKY;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
