shader_type canvas_item;
render_mode blend_mix;

// L'AURA DE FAIM SANS FOND, toute la minute : une MÂCHOIRE ronde de crocs ivoire tourne couchée sous ses pieds, à demi
// ouverte sur une gorge de bile, et des gouttes de bile tombent autour de lui. Posée derrière lui.

#include "res://assets/shaders/faim.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float show = smoothstep(0.0, 0.012, progress) * (1.0 - smoothstep(0.985, 1.0, progress));
	vec3 color = vec3(0.0);
	float a = 0.0;
	vec2 g = g_rot((p - vec2(0.0, 0.64)) * vec2(1.0, 2.6), TIME * 0.3);
	float breathe = 0.55 + 0.15 * sin(TIME * 2.0);
	vec3 c = color;
	if (g_paint_maw(g, 0.68, breathe, 16.0, c)) {
		color = c;
		a = length(g) < 0.68 * mix(0.15, 0.72, breathe) ? 0.45 : 0.85;
	}
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float life = fract(TIME * 0.35 + g_hash(f, seed));
		vec2 at = vec2((g_hash(f + 3.0, seed) - 0.5) * 1.3, -0.6 + life * 1.3);
		float v = g_drop(vec2(p.x - at.x, -(p.y - at.y)), 0.04);
		if (v > -0.012 && life < 0.9) {
			color = v <= 0.0 ? G_INK : (v > 0.02 ? G_PALE : G_BILE);
			a = max(a, 0.9 * (1.0 - smoothstep(0.7, 0.9, life)));
		}
	}
	COLOR = vec4(color, a * show);
}
