shader_type canvas_item;
render_mode blend_mix;

// LE DÉPART DE L'ÉRUPTION : il s'enfonce, le sol s'ouvre en trou sombre bordé de roche, des mottes de
// terre sautent, puis le trou se referme dans un nuage de poussière.

#include "res://assets/shaders/colosse.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec2 g = p * vec2(1.0, 1.6);
	float d = length(g);
	float t = progress;
	vec3 color = C_ROCK;
	float a = 0.0;
	float hole = 0.5 * smoothstep(0.0, 0.15, t) * (1.0 - smoothstep(0.5, 0.9, t));
	// La lèvre de roche autour du trou.
	float lip = c_rock(g, hole + 0.17, seed * 7.0);
	if (lip > -0.03 && hole > 0.0) {
		a = 1.0;
		color = lip <= 0.0 ? C_RIM : c_rock_shade(g, lip, hole + 0.17);
	}
	if (d < hole) {
		color = d > hole - 0.04 ? C_RIM : (d < hole * 0.5 ? C_LAVA_DEEP * 0.5 : C_RIM * 1.4);
		a = 1.0;
	}
	// Les mottes, projetées en cercle.
	float fly = smoothstep(0.05, 0.7, t);
	float shrink = 1.0 - smoothstep(0.55, 0.95, t);
	for (int i = 0; i < 7; i++) {
		float f = float(i);
		float ang = f / 7.0 * TAU + seed;
		vec2 c = vec2(cos(ang), sin(ang) * 0.7) * (0.3 + fly * 0.5) - vec2(0.0, sin(fly * PI) * 0.25);
		float r = (0.08 + 0.04 * c_hash(f, seed)) * shrink;
		float rock = c_rock(p - c, r, f + seed);
		if (rock > -0.015 && r > 0.0) {
			color = rock <= 0.0 ? C_RIM : c_rock_shade(p - c, rock, r);
			a = 1.0;
		}
	}
	// La poussière qui retombe à la fin, en bourrelets.
	float puff = smoothstep(0.45, 0.7, t) * (1.0 - smoothstep(0.8, 1.0, t));
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		float ang = f / 6.0 * TAU + 0.4;
		vec2 c = vec2(cos(ang), sin(ang) * 0.6) * 0.42;
		float blob = 0.2 * puff - length(p - c);
		if (blob > 0.0) {
			color = blob < 0.03 ? C_ROCK_LIGHT : C_DUST;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
