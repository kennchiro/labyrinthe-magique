shader_type canvas_item;
render_mode blend_mix;

// L'ONDE DE GIVRE du Pas de l'Abîme : il se reforme dans un anneau de givre qui part au sol, hérissé de pics de
// glace, et qui fige ce qu'il touche.

#include "res://assets/shaders/abime.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	vec2 g = p * vec2(1.0, 1.7);
	float d = length(g);
	float ang = atan(g.y, g.x);
	float r = smoothstep(0.0, 0.6, t) * 0.85;
	float fade = 1.0 - smoothstep(0.55, 1.0, t);
	float band = 0.06 * fade - abs(d - r);
	if (band > 0.0) {
		color = band > 0.035 ? A_PALE : A_CYAN;
		a = 1.0;
	}
	float sector = fract(ang * 9.0 / TAU + seed) - 0.5;
	float s = a_shard(vec2(sector * d * 0.6, d - r + 0.1), 0.04, 0.18 * fade);
	if (s > -0.2 && fade > 0.05 && d > 0.1) {
		color = s <= 0.0 ? A_OBSIDIAN : (s > 0.45 ? A_PALE : A_CYAN);
		a = 1.0;
	}
	float flash = 0.4 * (1.0 - smoothstep(0.0, 0.25, t)) - d;
	if (flash > 0.0) {
		color = A_PALE;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
