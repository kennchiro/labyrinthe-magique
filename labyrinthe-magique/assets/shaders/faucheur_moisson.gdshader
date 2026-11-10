shader_type canvas_item;
render_mode blend_mix;

// LA GRANDE MOISSON : un cercle complet de lame noire au tranchant de braise tranche tout autour de lui, puis
// laisse un anneau de braise qui s'éteint.

#include "res://assets/shaders/faucheur.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float d = length(p);
	float a = fract((atan(p.y, p.x) + PI) / TAU);
	float sweep = smoothstep(0.0, 0.4, t);
	vec4 color = vec4(0.0);
	// Le sillage noir de la lame, de l'angle zéro jusqu'à elle.
	float band = smoothstep(0.16, 0.0, abs(d - 0.66)) * step(a, sweep);
	float fade = 1.0 - smoothstep(0.45, 1.0, t);
	color = f_over(vec4(F_BLACK, band * 0.85 * fade), color);
	float edge = smoothstep(0.03, 0.0, abs(d - 0.8)) * step(a, sweep);
	color = f_over(vec4(mix(F_EMBER, F_CORE, 0.5), edge * fade), color);
	// La tête de la lame, qui tourne.
	float head = sweep * TAU - PI;
	vec2 tip = vec2(cos(head), sin(head)) * 0.66;
	color = f_over(f_blade((p - tip) * 2.2, 0.75, 0.4, head + PI * 0.5, step(t, 0.45)), color);
	COLOR = color;
}
