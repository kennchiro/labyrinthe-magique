shader_type canvas_item;
render_mode blend_mix;

// L'ÉCRASEMENT : ce que touche le Colosse (la Météorite, le Piétinement, un éclat de la Géode) part
// dans une gerbe de cailloux, et une petite fissure de lave s'ouvre au sol.

#include "res://assets/shaders/colosse.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float t = progress;
	vec3 color = C_DUST;
	float a = 0.0;
	// L'anneau de poussière, qui s'étale et s'amincit.
	float front = 0.2 + smoothstep(0.0, 0.7, t) * 0.6;
	// En bouffées séparées : un anneau plein se lisait comme une roue de charrette.
	float puffs = 0.5 + 0.5 * cos(atan(p.y, p.x) * 7.0 + seed * 9.0);
	float width = 0.08 * (1.0 - smoothstep(0.3, 0.95, t)) * smoothstep(0.25, 0.7, puffs);
	float ring = width - abs(d - front);
	if (ring > -0.015 && width > 0.01) {
		color = ring <= 0.0 ? C_RIM : (ring > width * 0.5 ? C_DUST : C_ROCK_LIGHT);
		a = 1.0;
	}
	// L'étoile de fissures, qui s'ouvre vite puis refroidit.
	float open = smoothstep(0.0, 0.2, t);
	float heat = 1.0 - smoothstep(0.45, 1.0, t);
	for (int i = 0; i < 5; i++) {
		float f = float(i);
		float ang = f / 5.0 * TAU + seed * 3.0;
		vec2 q = c_rot(p, -ang);
		float crack = c_crack(q, 0.62 * open, 0.06 * heat, 0.16, f + seed * 11.0);
		if (crack > -0.02 && heat > 0.0) {
			color = crack <= 0.0 ? C_RIM : c_lava(crack / 0.06, heat);
			a = 1.0;
		}
	}
	// Les cailloux, projetés vers l'extérieur.
	float fly = smoothstep(0.0, 0.75, t);
	float shrink = 1.0 - smoothstep(0.55, 1.0, t);
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float ang = f / 8.0 * TAU + c_hash(f, seed) * 0.6;
		vec2 c = vec2(cos(ang), sin(ang)) * (0.12 + fly * (0.5 + 0.25 * c_hash(f + 2.0, seed)));
		float r = (0.07 + 0.05 * c_hash(f + 5.0, seed)) * shrink;
		float rock = c_rock(p - c, r, f + seed * 5.0);
		if (rock > -0.015 && r > 0.0) {
			color = rock <= 0.0 ? C_RIM : c_rock_shade(p - c, rock, r);
			a = 1.0;
		}
	}
	// L'éclair de l'impact.
	float flash = 0.32 * (1.0 - smoothstep(0.0, 0.14, t)) - d;
	if (flash > 0.0) {
		color = flash > 0.12 ? C_WHITE : C_LAVA_HOT;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
