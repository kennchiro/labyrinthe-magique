shader_type canvas_item;
render_mode blend_mix;

// LE MÉTAL EN FUSION AU SOL : une flaque orange qui bouillonne, à cœur jaune, et qui refroidit en gris sur la fin.

#include "res://assets/shaders/forgeron.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec2 g = vec2(p.x, p.y * 1.8);
	float t = progress;
	float a = atan(g.y, g.x);
	float edge = 0.62 + 0.08 * sin(a * 5.0 + seed * 7.0) + 0.04 * sin(a * 9.0 + TIME);
	float d = length(g) / edge;
	if (d > 1.0) {
		COLOR = vec4(0.0);
	} else {
		float born = smoothstep(0.0, 0.08, t);
		float cool = 1.0 - smoothstep(0.65, 1.0, t);
		float bubble = 0.5 + 0.5 * sin(g.x * 14.0 + TIME * 3.0 + seed) * sin(g.y * 12.0 - TIME * 2.0);
		float heat = (1.0 - d) * 0.6 + bubble * 0.3 + 0.2;
		vec3 c = g_heat(heat * cool);
		c = d > 0.88 ? G_RIM : c;
		COLOR = vec4(c, born * (0.35 + 0.65 * cool) * 0.9);
	}
}
