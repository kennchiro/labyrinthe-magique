shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLOSION DE FAIM SANS FOND : un hurlement. Une onde de bile part au sol, ponctuée d'un cercle de crocs ivoire qui se
// dressent puis s'enfoncent, et des gouttes de bile jaillissent autour de lui.

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
	float fade = 1.0 - smoothstep(0.65, 1.0, t);
	vec2 g = (p - vec2(0.0, 0.62)) * vec2(1.0, 2.6);
	float d = length(g);
	float ang = atan(g.y, g.x);
	float r = smoothstep(0.0, 0.6, t) * 0.92;
	float band = 0.05 * fade - abs(d - r);
	if (band > 0.0) {
		color = band > 0.03 ? G_PALE : G_BILE;
		a = 1.0;
	}
	float sector = fract(ang * 14.0 / TAU + seed) - 0.5;
	vec2 tq = vec2(sector * d * 0.6, (d - r) + 0.05);
	float fang = 1.0 - abs(tq.x) / 0.04 - abs(tq.y + 0.06) / (0.16 * fade + 0.001);
	if (fang > -0.15 && fade > 0.05 && d > 0.1) {
		color = fang <= 0.0 ? G_INK : G_IVORY;
		a = 1.0;
	}
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float an = f * TAU / 10.0 + g_hash(f, seed);
		float k = clamp(t * 1.4, 0.0, 1.0);
		vec2 at = vec2(cos(an) * k * 0.6, 0.3 + sin(an) * k * 0.25 - sin(k * 3.14159) * 0.55);
		float v = g_drop(p - at, 0.05 * fade);
		if (v > -0.012 && fade > 0.05) {
			color = v <= 0.0 ? G_INK : (v > 0.025 ? G_PALE : G_BILE);
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
