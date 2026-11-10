shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLOSION : six grandes ailes de lumière s'ouvrent derrière lui en éventail, une colonne de lumière tombe sur lui, et
// un anneau émeraude court au sol.

#include "res://assets/shaders/seraphin.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float open = smoothstep(0.05, 0.4, t);
	float life = 1.0 - smoothstep(0.7, 1.0, t);
	vec4 color = vec4(0.0);
	// L'anneau au sol.
	vec2 g = vec2(p.x, (p.y - 0.5) * 2.4);
	color = s_over(vec4(S_EMERALD, smoothstep(0.06, 0.0, abs(length(g) - smoothstep(0.2, 0.7, t) * 0.95)) * life), color);
	// Les six ailes : trois paires, la haute la plus grande.
	vec2 root = vec2(0.0, -0.1);
	for (int k = 0; k < 3; k++) {
		float f = float(k);
		float lift = -0.5 + f * 0.45;
		float len = (0.85 - f * 0.18) * open;
		for (int side = 0; side < 2; side++) {
			float s = float(side) * 2.0 - 1.0;
			float dir = s > 0.0 ? lift : PI - lift;
			color = s_over(s_wing(p, root + vec2(s * 0.08, f * 0.12), dir, 0.55, len, 5, life), color);
		}
	}
	// La colonne de lumière.
	float column = smoothstep(0.22, 0.0, abs(p.x)) * step(p.y, 0.5) * (1.0 - smoothstep(0.1, 0.5, t)) * step(0.02, t);
	color = s_over(vec4(S_CORE, column), color);
	COLOR = color;
}
