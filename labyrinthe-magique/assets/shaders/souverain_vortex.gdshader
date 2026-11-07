shader_type canvas_item;
render_mode blend_mix;

// LE GRAND VORTEX, au sol sous la tornade : une spirale à quatre bras qui tourne et s'enroule vers le
// centre, des traits de vent qui y plongent, un anneau d'argent. Elle montre jusqu'où il aspire.

#include "res://assets/shaders/souverain.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	p.y *= 1.6;
	float t = progress;
	vec3 color = S_SKY;
	float a = 0.0;
	float show = smoothstep(0.0, 0.08, t) * (1.0 - smoothstep(0.9, 1.0, t));
	float spin = s_spiral(p, 0.28, 4.0, 0.22, -TIME * 4.0, 0.9 * show);
	if (spin > 0.0) {
		float r = length(p);
		color = r < 0.35 ? S_WHITE : (r < 0.65 ? S_PALE : S_SKY);
		a = 0.6;
	}
	float ring = 0.03 - abs(length(p) - 0.9 * show);
	if (ring > -0.012 && show > 0.0) {
		color = ring <= 0.0 ? S_RIM : S_SILVER;
		a = 1.0;
	}
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		float k = fract(TIME * 1.2 + f / 6.0);
		float ang = f / 6.0 * TAU + k * 1.5;
		vec2 c = vec2(cos(ang), sin(ang)) * mix(0.9, 0.2, k);
		vec2 q = s_rot(p - c, -ang);
		float dash = q.x > 0.0 && q.x < 0.2 ? 0.025 * (1.0 - k) - abs(q.y) : -1.0;
		if (dash > -0.01 && show > 0.0) {
			color = dash <= 0.0 ? S_RIM : S_WHITE;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
