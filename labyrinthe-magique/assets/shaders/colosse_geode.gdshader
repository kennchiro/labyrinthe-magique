shader_type canvas_item;
render_mode blend_mix;

// LA TOUR DE CRISTAL, plantée tout le temps du sort (demande du joueur, 2026-11-07 : « une tour magique
// en cristal ») : elle sort du sol sur un socle de roche, un fût de blocs de cristal cerclé d'or, une
// fenêtre qui luit, une couronne de pointes, et au sommet un grand cristal qui flotte, entouré de trois
// éclats en orbite. Quand elle tire (`shot` à 1, que le jeu fait retomber), le cristal du sommet éclate
// de lumière. À la fin, elle rentre dans le sol.
//
// Le quad est HAUT : le pied est en bas. On dessine en CASES : x de -0,65 à 0,65, y de 0 à 2,4 vers le
// haut, le pied à y = 0,12 (voir `TOWER_SIZE` dans le Level).

#include "res://assets/shaders/colosse.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;
uniform float shot = 0.0;

const vec3 GOLD = vec3(0.878, 0.69, 0.251);
const vec3 GOLD_DARK = vec3(0.573, 0.39, 0.11);
const float WIDTH = 0.65;
const float HEIGHT = 2.4;
const float FOOT = 0.12;
const float SHAFT_TOP = 1.35;
const float SPIRE = 1.66;

// Un petit éclat en orbite autour du sommet, > 0 dedans.
float shard(vec2 q, float size) {
	return c_gem(vec2(q.x, -q.y), size * 1.8, size * 0.6);
}

void fragment() {
	float x = (UV.x - 0.5) * 2.0 * WIDTH;
	float y = (1.0 - UV.y) * HEIGHT - FOOT;
	float t = progress;
	vec3 color = C_ROCK;
	float a = 0.0;
	float grow = smoothstep(0.0, 0.06, t) * (1.0 - smoothstep(0.93, 1.0, t));
	// La tour sort du sol : on la dessine décalée vers le bas, et le sol la coupe.
	float yt = y + (1.0 - grow) * 2.3;
	float beat = 0.5 + 0.5 * sin(TIME * 4.0);

	// Le socle de roche, au ras du sol.
	vec2 bq = vec2(x, -y * 2.6);
	float base = c_rock(bq, 0.62 * smoothstep(0.0, 0.03, t) * (1.0 - smoothstep(0.96, 1.0, t)) + 0.001, 5.0 + seed);
	if (base > -0.03) {
		a = 1.0;
		color = base <= 0.0 ? C_RIM : c_rock_shade(bq, base, 0.62);
		vec2 cq = c_rot(bq + vec2(0.5, 0.0), 0.1);
		float crack = c_crack(cq, 1.0, 0.05, 0.18, seed * 3.0);
		if (crack > 0.0) {
			color = c_lava(crack / 0.05, 0.75 + 0.25 * beat);
		}
	}

	if (y > -0.02) {
		// Le fût : des blocs de cristal, plus large au pied.
		if (yt > 0.0 && yt < SHAFT_TOP) {
			float k = yt / SHAFT_TOP;
			float w = mix(0.34, 0.25, k) + 0.07 * (1.0 - smoothstep(0.0, 0.18, yt));
			float inside = w - abs(x);
			if (inside > -0.03) {
				a = 1.0;
				if (inside <= 0.0) {
					color = C_RIM;
				} else {
					color = x < -w * 0.35 ? C_GLOW : (x < w * 0.3 ? C_CRYSTAL : C_CRYSTAL_DARK);
					// Les joints des blocs, décalés d'une assise à l'autre.
					float row = floor(yt / 0.24);
					float seam_y = abs(fract(yt / 0.24) - 0.5);
					float seam_x = abs(fract((x + w + mod(row, 2.0) * 0.12) / 0.24) - 0.5);
					if (seam_y > 0.44 || seam_x > 0.46) {
						color = C_CRYSTAL_DARK;
					}
					// Un reflet qui monte le long du fût.
					float glint = fract(TIME * 0.35 + seed) * (SHAFT_TOP + 0.4) - 0.2;
					if (abs(yt - glint - x * 0.4) < 0.03 && x < 0.0) {
						color = C_WHITE;
					}
					// Les cerclages : roche au pied, or à mi-hauteur, or au sommet.
					if (yt < 0.1) {
						color = inside < 0.04 ? C_RIM : C_ROCK;
					} else if (abs(yt - 0.62) < 0.045 || yt > SHAFT_TOP - 0.08) {
						color = inside < 0.035 ? GOLD_DARK : (x < 0.0 ? GOLD : GOLD_DARK);
					}
					// La fenêtre en arc, qui luit et bat.
					vec2 wq = vec2(x, yt - 0.95);
					float arch = wq.y < 0.0 ? 0.075 - abs(wq.x) : 0.075 - length(wq);
					if (wq.y > -0.14 && arch > -0.025) {
						color = arch <= 0.0 ? C_RIM : mix(C_GLOW, C_WHITE, beat * 0.6 + shot * 0.4);
					}
				}
			}
		}
		// La couronne : cinq pointes de cristal au-dessus du dernier cerclage.
		for (int i = 0; i < 5; i++) {
			float f = float(i);
			vec2 cq = vec2(x - (f - 2.0) * 0.12, -(yt - SHAFT_TOP + 0.02));
			float spike = c_gem(cq, f == 2.0 ? 0.0 : 0.17 - abs(f - 2.0) * 0.02, 0.055);
			if (spike > -0.02 && yt > 0.0) {
				a = 1.0;
				color = spike <= 0.0 ? C_RIM : c_gem_shade(cq, spike, 0.055);
			}
		}
		// Le sommet : le grand cristal qui flotte, et ses trois éclats en orbite.
		float bob = 0.04 * sin(TIME * 2.0);
		vec2 top = vec2(x, yt - SPIRE - bob);
		for (int pass = 0; pass < 2; pass++) {
			if (pass == 1) {
				vec2 gq = vec2(top.x, -top.y);
				float gem = c_gem(gq, 0.48, 0.19);
				if (gem > -0.03 && yt > 0.0) {
					a = 1.0;
					color = gem <= 0.0 ? C_RIM : mix(c_gem_shade(gq, gem, 0.19), C_WHITE, shot * 0.8);
				}
			}
			for (int i = 0; i < 3; i++) {
				float ang = TIME * 1.8 + float(i) * TAU / 3.0 + seed;
				float depth = sin(ang);
				// Derrière le cristal au premier passage, devant au second.
				if ((pass == 0) != (depth < 0.0)) {
					continue;
				}
				vec2 c = vec2(cos(ang) * 0.42, depth * 0.08 - 0.05);
				float s = shard(top - c, 0.07 + 0.015 * depth);
				if (s > -0.015 && yt > 0.0) {
					a = 1.0;
					color = s <= 0.0 ? C_RIM : (depth < 0.0 ? C_CRYSTAL_DARK : C_GLOW);
				}
			}
		}
		// Le tir : une étoile de lumière autour du sommet, qui s'éteint avec `shot`.
		float star = (0.08 + 0.32 * pow(abs(cos(atan(top.y, top.x) * 3.0)), 8.0)) * shot - length(top);
		if (star > 0.0 && yt > 0.0) {
			a = 1.0;
			color = star > 0.06 ? C_WHITE : C_GLOW;
		}
	}
	COLOR = vec4(color, a);
}
