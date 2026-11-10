shader_type canvas_item;
render_mode blend_mix;

// L'ANNEAU DE LUNE, à la fin de l'Éclipse, couché au sol : un anneau d'argent s'élargit depuis elle, bordé d'un
// croissant clair, semé de petites étoiles, et laisse une ombre bleu nuit derrière lui.

#include "res://assets/shaders/firmament.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	p.y *= 2.0;
	float t = progress;
	float r = mix(0.12, 0.95, sqrt(t));
	float d = length(p);
	float fade = 1.0 - smoothstep(0.55, 1.0, t);
	vec4 color = vec4(R_NIGHT, smoothstep(r, r - 0.25, d) * step(r - 0.4, d) * 0.45 * fade);
	float a = atan(p.y, p.x);
	float crescent = 0.5 + 0.5 * cos(a - 1.2);
	color = r_over(vec4(R_SILVER, smoothstep(0.05, 0.0, abs(d - r)) * fade), color);
	color = r_over(vec4(R_SHINE, smoothstep(0.03, 0.0, abs(d - r + 0.04)) * crescent * fade), color);
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float b = f * TAU / 8.0 + t * 1.5;
		vec2 at = vec2(cos(b), sin(b)) * r;
		color = r_over(r_star(vec2(p.x - at.x, (p.y - at.y) * 0.6), 0.07, b, fade), color);
	}
	COLOR = color;
}
