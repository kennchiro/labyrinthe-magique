shader_type canvas_item;
render_mode blend_mix;

// LA COLONNE DE LAVE : la terre se fend, une colonne de lave jaillit vers le ciel, s'épanouit en gerbe et retombe en
// scories noires. La Statue de cendres qui s'effondre, et chaque cage de l'Empire des Cendres qui éclate.

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
	float up = smoothstep(0.0, 0.3, t);
	float down = smoothstep(0.55, 1.0, t);
	float top = 0.75 - up * 1.7 + down * 1.4;
	// La fissure au sol.
	vec2 g = (p - vec2(0.0, 0.75)) * vec2(1.0, 3.0);
	float crack = 0.04 - abs(g.y + sin(g.x * 14.0 + seed * 3.0) * 0.08);
	if (crack > 0.0 && abs(g.x) < 0.55 * up) {
		color = E_LAVA;
		a = 1.0 - down;
	}
	// La colonne, qui ondule.
	float w = 0.17 * (1.0 - down * 0.7) * (0.85 + 0.15 * sin(p.y * 10.0 - TIME * 14.0));
	float col = min(w - abs(p.x + sin(p.y * 5.0 + TIME * 5.0) * 0.03), min(p.y - top, 0.78 - p.y));
	if (col > -0.016) {
		color = col <= 0.0 ? E_BLACK : (col > w * 0.6 ? E_PALE : (col > w * 0.25 ? E_EMBER : E_LAVA));
		a = 1.0;
	}
	// La gerbe au sommet, puis les scories qui retombent.
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float ang = -1.5708 + (f / 7.0 - 0.5) * 2.4;
		float k = clamp((t - 0.25) / 0.6, 0.0, 1.0);
		vec2 at = vec2(0.0, top) + vec2(cos(ang), sin(ang)) * k * 0.45 + vec2(0.0, k * k * 0.9);
		float r = 0.05 * (1.0 - k * 0.5);
		float blob = r - length(p - at);
		if (k > 0.0 && blob > -0.012) {
			color = blob <= 0.0 ? E_BLACK : (k > 0.6 ? E_ASH : E_EMBER);
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
