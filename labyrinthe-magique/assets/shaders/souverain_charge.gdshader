shader_type canvas_item;
render_mode blend_mix;

// LE GESTE D'ÉVEIL : des rubans de vent montent en spirale autour de lui en se resserrant.

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
	for (int i = 0; i < 4; i++) {
		float f = float(i);
		float height = 0.5 - f * 0.28 - t * 0.2;
		vec2 q = vec2(p.x, (p.y - height) * 3.0);
		float rel;
		float arc = s_arc(q, mix(0.9, 0.4, t), t * 9.0 + f * 1.6, 2.6, 0.12, rel);
		if (arc > -0.03) {
			color = arc <= 0.0 ? S_RIM : s_wind(arc / 0.12);
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
