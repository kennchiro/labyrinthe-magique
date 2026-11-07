shader_type canvas_item;
render_mode blend_mix;

// LE PIC DU BASTION : sur qui le frappe, trois pics de roche jaillissent du sol d'un coup, puis
// rentrent.

#include "res://assets/shaders/colosse.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = C_ROCK;
	float a = 0.0;
	float up = smoothstep(0.0, 0.12, t) * (1.0 + 0.2 * sin(clamp(t / 0.3, 0.0, 1.0) * PI));
	float down = 1.0 - smoothstep(0.6, 1.0, t);
	// La fissure au pied.
	vec2 cq = p - vec2(-0.6, 0.35);
	float crack = c_crack(cq, 1.2, 0.07 * down, 0.15, seed * 9.0);
	if (crack > -0.02 && down > 0.0) {
		color = crack <= 0.0 ? C_RIM : c_lava(crack / 0.07, down);
		a = 1.0;
	}
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		vec2 base = vec2((f - 1.0) * 0.32, 0.35 + abs(f - 1.0) * 0.06);
		float h = (f == 1.0 ? 1.05 : 0.7) * up * down;
		float w = (f == 1.0 ? 0.2 : 0.15);
		vec2 q = p - base;
		q.x -= q.y * (f - 1.0) * 0.35;
		float spike = c_spike(q, h, w);
		if (spike > -0.03 && h > 0.0) {
			a = 1.0;
			color = spike <= 0.0 ? C_RIM : (q.x < 0.0 ? C_ROCK_LIGHT : C_ROCK);
		}
	}
	COLOR = vec4(color, a);
}
