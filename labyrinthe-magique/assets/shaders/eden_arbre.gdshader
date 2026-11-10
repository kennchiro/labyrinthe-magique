shader_type canvas_item;
render_mode blend_mix;

// L'ARBRE DE VIE, debout derrière l'épée plantée : un tronc d'or qui pousse, ses branches, puis une couronne de
// feuilles de lumière d'or semée de petits yeux, qui reste et s'éteint à la fin de l'Éden.

#include "res://assets/shaders/eden.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float grow = smoothstep(0.0, 0.05, t);
	float fade = 1.0 - smoothstep(0.92, 1.0, t);
	vec4 color = vec4(0.0);
	// Le tronc, du sol (y = 0,95) vers le haut.
	float top = mix(0.95, 0.0, grow);
	float trunk = step(top, p.y) * step(p.y, 0.95) * smoothstep(0.07, 0.04, abs(p.x + sin(p.y * 4.0) * 0.03));
	color = e_over(vec4(E_GOLD, trunk), color);
	// Les branches.
	for (int i = 0; i < 4; i++) {
		float f = float(i);
		float side = mod(f, 2.0) * 2.0 - 1.0;
		float y0 = 0.35 - f * 0.12;
		vec2 a = vec2(0.0, y0);
		vec2 b = vec2(side * (0.35 + f * 0.05), y0 - 0.25);
		vec2 ab = b - a;
		float h = clamp(dot(p - a, ab) / dot(ab, ab), 0.0, smoothstep(0.03, 0.08, t));
		float branch = smoothstep(0.03, 0.015, length(p - a - ab * h));
		color = e_over(vec4(E_GOLD, branch), color);
	}
	// La couronne de feuilles de lumière.
	float crown = smoothstep(0.06, 0.14, t);
	vec2 c = vec2(p.x, (p.y + 0.15) * 1.4);
	float leaves = 0.0;
	for (int i = 0; i < 14; i++) {
		float f = float(i);
		vec2 at = vec2((e_hash(f, seed) - 0.5) * 1.1, (e_hash(f, seed + 2.0) - 0.5) * 0.7);
		leaves = max(leaves, e_glow(length(c - at), 0.16));
	}
	color = e_over(vec4(mix(E_GOLD, vec3(1.0, 0.95, 0.75), leaves), smoothstep(0.1, 0.4, leaves) * crown * 0.85), color);
	for (int i = 0; i < 5; i++) {
		float f = float(i);
		vec2 at = vec2((f - 2.0) * 0.2, -0.12 - abs(f - 2.0) * 0.05);
		color = e_over(e_eye(p - at, 0.07, crown * (0.8 + 0.2 * sin(TIME * 2.0 + f)), crown), color);
	}
	color.a *= fade;
	COLOR = color;
}
