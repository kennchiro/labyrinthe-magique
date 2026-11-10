shader_type canvas_item;
render_mode blend_mix;

// L'ANNONCE DE L'ÉPÉE GÉANTE, couchée au sol : un grand cercle d'or qui se resserre, six ailes de lumière qui s'ouvrent
// autour en éventail sur le sol, et une croix émeraude au centre.

#include "res://assets/shaders/seraphin.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec2 g = vec2(p.x, p.y * 2.0);
	float t = progress;
	float d = length(g);
	float r = mix(0.95, 0.8, t);
	float pulse = 0.7 + 0.3 * sin(TIME * 14.0);
	vec4 color = vec4(S_GOLD, smoothstep(0.035, 0.0, abs(d - r)) * pulse);
	color = s_over(vec4(S_EMERALD, smoothstep(0.03, 0.0, min(abs(g.x), abs(g.y))) * step(d, 0.3)), color);
	for (int i = 0; i < 6; i++) {
		float a = float(i) * TAU / 6.0;
		color = s_over(s_wing(g, vec2(0.0), a, 0.45, 0.75 * t, 4, 0.45), color);
	}
	COLOR = color;
}
