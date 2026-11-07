shader_type canvas_item;
render_mode blend_mix;

// LE CATACLYSME, sur toute la carte : le sol craque en un réseau de fissures de lave qui part de lui et
// gagne tout l'écran, bat comme une braise pendant le séisme, puis refroidit.

#include "res://assets/shaders/colosse.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

// En jeu le quad couvre 50 cases : une cellule fait un peu plus de trois cases, et une fissure un
// quart de case. Plus large, le réseau noyait tout l'écran sous la lave (vu en jeu le 2026-11-07).
const float CELLS = 8.0;

vec2 c_point(vec2 cell) {
	return cell + 0.15 + 0.7 * vec2(c_hash(cell.x * 3.1 + cell.y * 17.3, seed),
		c_hash(cell.y * 5.7 + cell.x * 11.9, seed + 1.0));
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float t = progress;
	// Le réseau gagne l'écran pendant la première seconde, puis tient.
	float reach = smoothstep(0.0, 0.22, t) * 1.5;
	float heat = (0.65 + 0.35 * sin(TIME * 7.0 + d * 9.0)) * (1.0 - smoothstep(0.75, 1.0, t));
	vec2 g = p * CELLS;
	vec2 base = floor(g);
	// Voronoï : la fissure passe là où les deux points les plus proches sont à égale distance.
	float f1 = 9.0;
	float f2 = 9.0;
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 cell = base + vec2(float(x), float(y));
			float dist = length(g - c_point(cell));
			if (dist < f1) {
				f2 = f1;
				f1 = dist;
			} else if (dist < f2) {
				f2 = dist;
			}
		}
	}
	float edge = f2 - f1;
	// Plus large près de lui, là où le sol a cédé le premier.
	float width = mix(0.07, 0.035, clamp(d, 0.0, 1.0)) * (1.0 - smoothstep(reach - 0.15, reach, d));
	vec3 color = C_RIM;
	float a = 0.0;
	if (edge < width + 0.02 && width > 0.0) {
		a = 1.0;
		color = edge < width ? c_lava(1.0 - edge / width, max(heat, 0.15)) : C_RIM;
	}
	COLOR = vec4(color, a);
}
