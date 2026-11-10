shader_type canvas_item;
render_mode blend_mix;

// LA BOMBE DE MAGMA : la boule de lave s'écrase et explose en COURONNE DE FLAMMES, puis une flaque de lave craquelée
// reste un instant, cernée d'éclats d'obsidienne.

#include "res://assets/shaders/premier.gdshaderinc"

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
	float pool = 0.6 * smoothstep(0.0, 0.25, t) * (1.0 - smoothstep(0.7, 1.0, t)) - length(g)
		+ sin(atan(g.y, g.x) * 8.0 + seed * 3.0) * 0.04;
	if (pool > -0.02) {
		float crack = abs(fract(atan(g.y, g.x) * 5.0 / TAU + length(g) * 2.0) - 0.5);
		color = pool <= 0.0 ? P_OBSIDIAN : (crack < 0.08 ? P_YELLOW : P_MAGMA);
		a = 1.0;
	}
	float crown = smoothstep(0.05, 0.3, t) * (1.0 - smoothstep(0.5, 0.85, t));
	for (int i = 0; i < 9; i++) {
		float f = float(i);
		float an = f * TAU / 9.0 + seed;
		vec2 base = vec2(cos(an) * 0.45, sin(an) * 0.27);
		vec3 c = color;
		if (crown > 0.02 && p_paint_tongue(p - base, 0.09, 0.45 * crown, c)) {
			color = c;
			a = 1.0;
		}
	}
	float flash = 0.5 * (1.0 - smoothstep(0.0, 0.2, t)) - length(p);
	if (flash > 0.0) {
		color = P_CORE;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
