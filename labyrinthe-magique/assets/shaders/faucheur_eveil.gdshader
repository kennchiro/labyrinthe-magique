shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLOSION : l'auréole se ressoude d'un éclat rouge, un cercle de faux tranche le sol autour de lui, et une
// colonne de cendres monte.

#include "res://assets/shaders/faucheur.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float life = 1.0 - smoothstep(0.7, 1.0, t);
	vec4 color = vec4(0.0);
	// La colonne de cendres.
	float column = clamp(1.0 - abs(p.x) / 0.3, 0.0, 1.0) * step(p.y, 0.6);
	float ash = texture(noise, vec2(p.x * 1.5 + seed, p.y * 0.8 + t * 1.5)).r;
	color = f_over(vec4(mix(F_ASH, F_EMBER, ash * column), column * ash * 0.8 * life * smoothstep(0.05, 0.3, t)), color);
	// Le cercle de faux au sol, couché : la lame fait le tour.
	vec2 g = vec2(p.x, (p.y - 0.55) * 2.4);
	float d = length(g);
	float sweep = fract((atan(g.y, g.x) + PI) / TAU);
	float drawn = step(sweep, smoothstep(0.1, 0.45, t));
	float ring = smoothstep(0.05, 0.0, abs(d - 0.8)) * drawn * life;
	color = f_over(vec4(mix(F_EMBER, F_CORE, 0.4), ring), color);
	// L'auréole qui se ressoude : un anneau rouge au-dessus de lui, et son éclat.
	vec2 h = vec2(p.x, (p.y + 0.62) * 2.6);
	float halo = smoothstep(0.05, 0.0, abs(length(h) - 0.32)) * smoothstep(0.0, 0.2, t) * life;
	color = f_over(vec4(F_EMBER, halo), color);
	float flash = (1.0 - smoothstep(0.0, 0.2, abs(t - 0.22))) * f_glow(length(p - vec2(0.0, -0.62)), 0.7);
	color = f_over(vec4(F_CORE, flash * 0.8), color);
	COLOR = color;
}
