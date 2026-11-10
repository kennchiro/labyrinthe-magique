shader_type canvas_item;
render_mode blend_mix;

// LE GESTE D'ÉVEIL DE FAIM SANS FOND : la bile monte en veines autour de lui, une gueule de crocs claque trois fois
// sous ses pieds en grandissant, puis s'ouvre en grand.

#include "res://assets/shaders/faim.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	vec2 g = (p - vec2(0.0, 0.62)) * vec2(1.0, 2.6);
	float snaps = abs(sin(t * 3.0 * 3.14159));
	float open = t < 0.75 ? snaps : smoothstep(0.75, 0.9, t);
	vec3 c = color;
	if (g_paint_maw(g, 0.4 + t * 0.45, open, 14.0, c)) {
		color = c;
		a = 0.95;
	}
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		float x = (f / 5.0 - 0.5) * 0.9;
		float top = 0.6 - smoothstep(0.05, 0.7, t) * (1.0 + g_hash(f, seed) * 0.4);
		float wave = x + sin(p.y * 10.0 + f * 2.0) * 0.05;
		if (p.y < 0.6 && p.y > top && abs(p.x - wave) < 0.02) {
			color = G_BILE;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
