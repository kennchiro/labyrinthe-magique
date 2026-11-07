shader_type canvas_item;
render_mode blend_mix;

// L'ÉRUPTION, à l'arrivée : un jet de roche et de lave monte du sol fendu en étoile, des rochers sont
// projetés tout autour, et l'onde de choc court au sol jusqu'au bout de son rayon.

#include "res://assets/shaders/colosse.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float t = progress;
	vec3 color = C_ROCK;
	float a = 0.0;
	float heat = 1.0 - smoothstep(0.5, 1.0, t);
	// L'onde de choc, jusqu'au rayon du sort (0,8 du quad).
	float front = 0.1 + smoothstep(0.0, 0.45, t) * 0.7;
	float width = 0.07 * (1.0 - smoothstep(0.35, 0.65, t));
	float ring = width - abs(d - front);
	if (ring > -0.02 && width > 0.0) {
		color = ring <= 0.0 ? C_RIM : (ring > width * 0.5 ? C_LAVA_HOT : C_LAVA);
		a = 1.0;
	}
	// L'étoile de fissures.
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		vec2 q = c_rot(p, -(f / 6.0 * TAU + seed));
		float crack = c_crack(q, 0.7 * smoothstep(0.0, 0.2, t), 0.07 * heat, 0.15, f + seed * 3.0);
		if (crack > -0.02 && heat > 0.0) {
			color = crack <= 0.0 ? C_RIM : c_lava(crack / 0.07, heat);
			a = 1.0;
		}
	}
	// Les rochers projetés : ils montent puis retombent loin.
	float fly = smoothstep(0.0, 0.8, t);
	float shrink = 1.0 - smoothstep(0.7, 1.0, t);
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float ang = f / 8.0 * TAU + c_hash(f, seed) * 0.5;
		vec2 c = vec2(cos(ang), sin(ang)) * fly * (0.5 + 0.2 * c_hash(f + 1.0, seed))
			- vec2(0.0, sin(fly * PI) * (0.3 + 0.2 * c_hash(f + 3.0, seed)));
		float r = (0.09 + 0.05 * c_hash(f + 6.0, seed)) * shrink;
		float rock = c_rock(p - c, r, f + seed * 2.0);
		if (rock > -0.02 && r > 0.0) {
			a = 1.0;
			color = rock <= 0.0 ? C_RIM : c_rock_shade(p - c, rock, r);
			if (rock > r * 0.5 && c_hash(f + 9.0, seed) > 0.5) {
				color = C_LAVA;
			}
		}
	}
	// Le jet : une colonne de lave qui monte de son pied et retombe en gouttes.
	float jet = smoothstep(0.0, 0.18, t) * (1.0 - smoothstep(0.45, 0.75, t));
	float top = -0.85 * jet;
	if (p.y < 0.08 && p.y > top) {
		float u = (p.y - 0.08) / min(top - 0.08, -0.001);
		float half_width = mix(0.2, 0.1, u) + 0.03 * sin(p.y * 25.0 + TIME * 20.0);
		float inside = half_width - abs(p.x);
		if (inside > -0.025) {
			color = inside <= 0.0 ? C_RIM : c_lava(inside / half_width, 1.0);
			a = 1.0;
		}
	}
	float flash = 0.35 * (1.0 - smoothstep(0.0, 0.14, t)) - d;
	if (flash > 0.0) {
		color = flash > 0.15 ? C_WHITE : C_LAVA_HOT;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
