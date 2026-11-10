shader_type canvas_item;
render_mode blend_mix;

// L'ENCLUME CÉLESTE TOMBE, debout : une enclume d'acier cerclée d'or, au cœur orange, descend du haut du quad jusqu'au
// sol, traînant des lignes de chute. Elle touche le sol à la fin de sa vie.

#include "res://assets/shaders/forgeron.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

// Le corps de l'enclume : une table large en haut, une taille étroite, un pied large en bas, une corne à gauche.
float anvil(vec2 q) {
	float top = step(abs(q.x), 0.42) * step(abs(q.y + 0.12), 0.1);
	float horn = step(q.x, -0.42) * step(-0.62, q.x) * step(abs(q.y + 0.14), 0.05 * (q.x + 0.62) / 0.2);
	float waist = step(abs(q.x), 0.16) * step(-0.05, q.y) * step(q.y, 0.1);
	float foot = step(abs(q.x), 0.3) * step(0.1, q.y) * step(q.y, 0.2);
	return max(max(top, horn), max(waist, foot));
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float fall = t * t;
	vec2 at = vec2(0.0, mix(-1.5, 0.55, fall));
	vec2 q = (p - at) / 1.7;
	vec4 color = vec4(0.0);
	// Les lignes de chute au-dessus.
	for (int i = 0; i < 5; i++) {
		float f = float(i);
		float x = (f - 2.0) * 0.16;
		float line = smoothstep(0.016, 0.0, abs(p.x - x * 1.6)) * step(p.y, at.y - 0.3) * step(at.y - 0.3 - 0.9 * fall - 0.1, p.y);
		color = g_over(vec4(G_SPARK, line * 0.6), color);
	}
	float body = anvil(q);
	float edge = anvil(q * 0.93) - body;
	if (body > 0.5) {
		vec3 c = q.y < -0.15 ? G_STEEL : G_SHADE;
		if (abs(q.y + 0.12) < 0.02 && abs(q.x) < 0.42) {
			c = G_GOLD;
		}
		if (abs(q.x) < 0.05 && q.y > -0.04 && q.y < 0.08) {
			c = G_MOLTEN;
		}
		color = g_over(vec4(c, 1.0), color);
	}
	color = g_over(vec4(G_RIM, max(edge, 0.0)), color);
	COLOR = color;
}
