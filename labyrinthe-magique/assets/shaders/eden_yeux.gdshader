shader_type canvas_item;
render_mode blend_mix;

// LES AILES DU TRÔNE S'OUVRENT : une couronne de douze yeux d'or s'ouvre autour de lui en s'élargissant, dans un
// anneau de flamme saphir couché au sol.

#include "res://assets/shaders/eden.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float fade = 1.0 - smoothstep(0.65, 1.0, t);
	float r = mix(0.2, 0.85, sqrt(t));
	vec2 g = vec2(p.x, p.y * 1.8);
	vec4 color = vec4(e_flame(0.6), smoothstep(0.06, 0.0, abs(length(g) - r)) * fade);
	for (int i = 0; i < 12; i++) {
		float a = float(i) * TAU / 12.0;
		vec2 at = vec2(cos(a) * r, sin(a) * r / 1.8);
		float open = smoothstep(0.1, 0.35, t);
		color = e_over(e_eye(p - at, 0.11, open, fade), color);
	}
	color = e_over(vec4(E_CORE, e_glow(length(p), 0.5) * (1.0 - smoothstep(0.0, 0.25, t))), color);
	COLOR = color;
}
