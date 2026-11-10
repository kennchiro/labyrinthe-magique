shader_type canvas_item;
render_mode blend_mix;

// LES CENDRES ARDENTES du Sillage : sur la case, un lit de cendres grises semé de braises qui rougeoient et de petites
// flammes qui dansent ; à la fin, les braises noircissent et une fumée monte. Couché sur le sol.

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
	float grow = smoothstep(0.0, 0.1, t);
	float dying = smoothstep(0.65, 1.0, t);
	float d = length(p * vec2(1.0, 1.5));
	float edge = 0.6 * grow - d + sin(atan(p.y, p.x) * 7.0 + seed * 5.0) * 0.05;
	if (edge > 0.0) {
		color = edge > 0.06 ? E_ASH : E_BLACK;
		a = 0.75 * (1.0 - dying * 0.6);
	}
	// Les braises.
	for (int i = 0; i < 7; i++) {
		float f = float(i);
		vec2 at = vec2(e_hash(f, seed) - 0.5, (e_hash(f + 2.0, seed) - 0.5) * 0.66) * 0.9;
		float glow = 0.5 + 0.5 * sin(TIME * (3.0 + f) + f);
		float r = 0.07 * grow * (1.0 - dying);
		float ember = r - length(p - at);
		if (ember > 0.0) {
			color = ember > r * 0.5 ? mix(E_EMBER, E_PALE, glow) : E_LAVA;
			a = 1.0;
		}
	}
	// Trois petites flammes.
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		vec2 base = vec2((f - 1.0) * 0.32, 0.15 + e_hash(f + 9.0, seed) * 0.15);
		float h = 0.45 * grow * (1.0 - dying) * (0.7 + 0.3 * sin(TIME * 7.0 + f * 2.0));
		vec3 c = color;
		if (h > 0.02 && e_paint_tongue(p - base, 0.09, h, c)) {
			color = c;
			a = 1.0;
		}
	}
	// La fumée de la fin.
	float puff = 0.18 * dying * (1.0 - dying) * 4.0 - length(p - vec2(0.0, -0.3 - dying * 0.5));
	if (puff > 0.0) {
		color = E_ASH_LIGHT;
		a = 0.8;
	}
	COLOR = vec4(color, a);
}
