shader_type canvas_item;
render_mode blend_mix;

// LA GERBE DE LAVE : le coup s'écrase, une flaque de lave s'étale, et une couronne de gouttes de lave part tout autour
// avant de retomber, noircies en scories. Le Poing impérial et les Gantelets de l'Empereur.

#include "res://assets/shaders/empereur.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	float flash = 0.45 * (1.0 - smoothstep(0.0, 0.25, t)) - length(p);
	vec2 g = p * vec2(1.0, 1.7);
	float pool = 0.5 * smoothstep(0.0, 0.3, t) * (1.0 - smoothstep(0.7, 1.0, t)) - length(g)
		+ sin(atan(g.y, g.x) * 9.0 + seed * 4.0) * 0.04;
	if (pool > -0.02) {
		color = pool <= 0.0 ? E_BLACK : (pool > 0.18 ? E_EMBER : (pool > 0.06 ? E_LAVA : E_DEEP));
		a = 1.0;
	}
	if (flash > 0.0) {
		color = flash > 0.15 ? E_PALE : E_EMBER;
		a = 1.0;
	}
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float ang = f * TAU / 10.0 + e_hash(f, seed) * 0.5;
		float reach = (0.45 + e_hash(f + 1.0, seed) * 0.45) * smoothstep(0.0, 0.6, t);
		float lift = sin(clamp(t * 1.6, 0.0, 1.0) * 3.14159) * 0.3;
		vec2 at = vec2(cos(ang) * reach, sin(ang) * reach * 0.6 - lift);
		float r = 0.06 * (1.0 - smoothstep(0.7, 1.0, t));
		float drop = r - length(p - at);
		if (drop > -0.014 && r > 0.0) {
			color = drop <= 0.0 ? E_BLACK : (t > 0.6 ? E_ASH : (drop > r * 0.5 ? E_PALE : E_LAVA));
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
