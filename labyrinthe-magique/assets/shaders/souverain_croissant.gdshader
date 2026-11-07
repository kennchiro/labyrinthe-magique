shader_type canvas_item;
render_mode blend_mix;

// LE CROISSANT D'OURAGAN, le projectile : un grand croissant de vent blanc bordé de bleu ciel, une petite
// spirale qui tourne à sa pointe, et des traits de vitesse derrière lui. UV.x va de la queue à la pointe.

#include "res://assets/shaders/souverain.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;

const float LENGTH = 1.5;

void fragment() {
	vec2 p = vec2((UV.x - 0.62) * LENGTH, UV.y - 0.5);
	vec3 color = S_SKY;
	float a = 0.0;
	for (int i = 0; i < 4; i++) {
		float f = float(i);
		vec2 q = vec2(-0.25 - p.x - f * 0.03, p.y - (f - 1.5) * 0.12);
		float len = 0.5 - abs(f - 1.5) * 0.08;
		float line = q.x > 0.0 && q.x < len ? 0.022 * (1.0 - q.x / len) - abs(q.y) : -1.0;
		if (line > -0.01) {
			color = line <= 0.0 ? S_RIM : S_SILVER;
			a = 1.0;
		}
	}
	float moon = s_crescent(p, 0.42, 0.2);
	if (moon > -0.025) {
		color = moon <= 0.0 ? S_RIM : s_wind(clamp(moon / 0.12, 0.0, 1.0));
		a = 1.0;
	}
	vec2 tip = p - vec2(0.18, 0.0);
	float spin = s_spiral(tip, 0.07, 1.0, 0.35, TIME * 9.0, 0.17);
	if (spin > 0.0 && moon > 0.02) {
		color = S_DEEP;
	}
	COLOR = vec4(color, a);
}
