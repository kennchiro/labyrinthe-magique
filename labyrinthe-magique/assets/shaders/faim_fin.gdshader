shader_type canvas_item;
render_mode blend_mix;

// LA FIN DE L'ÉVEIL DE FAIM SANS FOND : la mâchoire du sol se referme lentement, et une flaque de bile se rétracte en
// bouillonnant. La faim se rendort.

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
	vec2 g = (p - vec2(0.0, 0.6)) * vec2(1.0, 2.6);
	vec3 c = color;
	if (t < 0.7 && g_paint_maw(g, 0.7 * (1.0 - t * 0.6), 0.6 * (1.0 - t / 0.7), 16.0, c)) {
		color = c;
		a = 1.0 - smoothstep(0.5, 0.7, t);
	}
	float pool = 0.5 * (1.0 - t) - length(g) + sin(atan(g.y, g.x) * 7.0 + TIME * 4.0) * 0.03;
	if (pool > 0.0 && a < 0.5) {
		color = pool > 0.06 ? G_BILE : G_DEEP;
		a = 0.8;
	}
	COLOR = vec4(color, a);
}
