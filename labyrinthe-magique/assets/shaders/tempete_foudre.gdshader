shader_type canvas_item;
render_mode blend_mix;

// LA FOUDRE QUI TOMBE DU CIEL, dressée sur sa case : un éclair épais tombe d'un coup du haut du quad,
// crépite, puis s'éteint ; au pied, une étoile blanche et un anneau d'or au sol. Le quad est haut, le
// pied en bas (UV.y = 0,95). Sert à la Surtension, aux nuages de l'Œil du cyclone et à la Colère.

#include "res://assets/shaders/tempete.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	float t = progress;
	// x en travers (-1 à 1), h de 0 au pied à 1 en haut.
	vec2 p = vec2((UV.x - 0.5) * 2.0, (0.95 - UV.y) / 0.95);
	vec3 color = T_BLUE;
	float a = 0.0;
	float fall = smoothstep(0.0, 0.08, t);
	float fade = 1.0 - smoothstep(0.35, 0.65, t);
	// L'anneau d'or au sol, aplati par la plongée.
	vec2 g = vec2(p.x, p.y * 7.0);
	float gd = length(g);
	float front = 0.3 + smoothstep(0.05, 0.6, t) * 0.6;
	float width = 0.09 * (1.0 - smoothstep(0.4, 1.0, t));
	float ring = width - abs(gd - front);
	if (ring > -0.03 && width > 0.0) {
		color = ring <= 0.0 ? T_RIM : (ring > width * 0.5 ? T_YELLOW : T_GOLD);
		a = 1.0;
	}
	// L'éclair : du haut vers le pied, deux branches courtes.
	float flick = floor(TIME * 16.0);
	vec2 q = vec2(1.0 - p.y, p.x);
	float trunk = t_bolt(q, fall * 1.0, 0.16 * fade, 0.5, seed * 3.0, flick);
	if (trunk > -0.05 && fade > 0.0) {
		color = trunk <= 0.0 ? T_RIM : t_bolt_color(trunk / 0.16);
		a = 1.0;
	}
	for (int i = 0; i < 2; i++) {
		float f = float(i) * 2.0 - 1.0;
		vec2 b = t_rot(q - vec2(0.3 + 0.2 * float(i), 0.0), f * 0.6);
		float branch = t_bolt(b, 0.3 * fall, 0.04 * fade, 0.3, seed + f * 5.0, flick);
		if (branch > -0.025 && fade > 0.0) {
			color = branch <= 0.0 ? T_RIM : t_bolt_color(branch / 0.04);
			a = 1.0;
		}
	}
	// L'étoile au point d'impact.
	float star = t_star(vec2(p.x, (p.y - 0.02) * 4.0), 0.7 * fall * (1.0 - smoothstep(0.1, 0.45, t)), 8.0, 5.0);
	if (star > -0.04 && t < 0.45) {
		color = star <= 0.0 ? T_RIM : (star > 0.15 ? T_WHITE : T_YELLOW);
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
