shader_type canvas_item;
render_mode blend_mix;

// LA LAME AFFÛTÉE : un ennemi arrivé à huit entailles les ouvre toutes à la fois, en ÉTOILE ROUGE à huit branches
// barrée d'une croix blanche, avec des pétales qui jaillissent.

#include "res://assets/shaders/seigneur.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	float grow = smoothstep(0.0, 0.2, t);
	float fade = 1.0 - smoothstep(0.55, 1.0, t);
	float d = length(p);
	float ang = atan(p.y, p.x);
	float star = (0.85 * grow * fade) * (0.35 + 0.65 * pow(abs(cos(ang * 4.0)), 6.0)) - d;
	if (star > -0.02) {
		color = star <= 0.0 ? S_BLACK : (star > 0.18 ? S_BRIGHT : S_RED);
		a = 1.0;
	}
	for (int i = 0; i < 2; i++) {
		float an = 0.785 + float(i) * 1.5708;
		vec2 dir = vec2(cos(an), sin(an)) * 0.8 * grow;
		vec3 c = color;
		if (fade > 0.0 && s_paint_cut(p, -dir, dir, 0.08 * fade, c)) {
			color = c;
			a = 1.0;
		}
	}
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		float an = f * TAU / 6.0 + seed;
		vec2 at = vec2(cos(an), sin(an)) * (0.3 + t * 0.6);
		vec3 c = color;
		if (t > 0.15 && fade > 0.0 && s_paint_petal(s_rot(p - at, an + t * 8.0), 0.07 * fade, true, c)) {
			color = c;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
