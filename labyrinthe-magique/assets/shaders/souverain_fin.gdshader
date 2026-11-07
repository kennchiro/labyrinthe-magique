shader_type canvas_item;
render_mode blend_mix;

// LA FIN DU SOUVERAIN : ses rubans se dénouent et s'envolent vers le ciel en s'effilant.

#include "res://assets/shaders/souverain.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = S_SKY;
	float a = 0.0;
	float fade = 1.0 - smoothstep(0.55, 1.0, t);
	for (int i = 0; i < 4; i++) {
		float f = float(i);
		float x = (f - 1.5) * 0.3;
		float rise = t * 1.4 + f * 0.08;
		vec2 q = vec2(p.x - x - sin((p.y + rise) * 7.0 + f) * 0.08, p.y + rise - 0.3);
		float len = 0.6;
		float ribbon = q.y < 0.0 && q.y > -len ? 0.06 * fade * sin(-q.y / len * PI) - abs(q.x) : -1.0;
		if (ribbon > -0.015 && fade > 0.0) {
			color = ribbon <= 0.0 ? S_RIM : s_wind(ribbon / (0.06 * fade + 0.001));
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
