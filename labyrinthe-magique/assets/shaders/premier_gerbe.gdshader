shader_type canvas_item;
render_mode blend_mix;

// LE FEU PRIMORDIAL : un ennemi mort dans le feu éclate en gerbe de flammes, une couronne de langues qui jaillit de
// son cœur et lèche les cases voisines, avec des éclats d'obsidienne.

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
	float rise = smoothstep(0.0, 0.25, t) * (1.0 - smoothstep(0.55, 1.0, t));
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float an = f * TAU / 8.0 + seed;
		vec2 dir = vec2(cos(an), sin(an));
		vec2 q = p_rot(p - dir * 0.15, -an - 1.5708);
		vec3 c = color;
		if (rise > 0.02 && p_paint_tongue(q, 0.11 * rise, 0.65 * rise, c)) {
			color = c;
			a = 1.0;
		}
	}
	float flash = 0.4 * (1.0 - smoothstep(0.0, 0.3, t)) - length(p);
	if (flash > 0.0) {
		color = flash > 0.15 ? P_CORE : P_YELLOW;
		a = 1.0;
	}
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		float an = f * TAU / 6.0 + seed + 0.4;
		vec2 at = vec2(cos(an), sin(an)) * (0.2 + t * 0.7);
		float s = p_shard(p_rot(p - at, an), 0.04, 0.08);
		if (s > 0.0 && t < 0.9) {
			color = P_OBSIDIAN;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
