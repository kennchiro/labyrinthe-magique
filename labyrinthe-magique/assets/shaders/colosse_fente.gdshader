shader_type canvas_item;
render_mode blend_mix;

// LE DÉPART DE LA FAILLE, sous ses pieds : le sol éclate en croix, quatre crevasses de lave partent
// vers les quatre couloirs, et des blocs sautent du centre.

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
	float open = smoothstep(0.0, 0.25, t);
	float heat = 1.0 - smoothstep(0.5, 1.0, t);
	// Les quatre crevasses, sur les axes du labyrinthe.
	for (int i = 0; i < 4; i++) {
		float f = float(i);
		vec2 q = c_rot(p, -f * PI * 0.5);
		float crack = c_crack(q, 0.95 * open, 0.12 * (0.4 + 0.6 * heat), 0.2, f + seed * 13.0);
		if (crack > -0.035) {
			color = crack <= 0.0 ? C_RIM : c_lava(crack / 0.12, max(heat, 0.2));
			a = 1.0;
		}
	}
	// L'anneau de choc, qui court au sol.
	float front = 0.15 + smoothstep(0.0, 0.5, t) * 0.7;
	float puffs = 0.5 + 0.5 * cos(atan(p.y, p.x) * 8.0 + 0.4);
	float width = 0.05 * (1.0 - smoothstep(0.3, 0.7, t)) * smoothstep(0.25, 0.7, puffs);
	float ring = width - abs(d - front);
	if (ring > -0.015 && width > 0.01) {
		color = ring <= 0.0 ? C_RIM : C_DUST;
		a = 1.0;
	}
	// Les blocs qui sautent du centre, en diagonale, entre les crevasses.
	float fly = smoothstep(0.0, 0.6, t);
	float shrink = 1.0 - smoothstep(0.5, 0.95, t);
	for (int i = 0; i < 4; i++) {
		float f = float(i);
		float ang = PI * 0.25 + f * PI * 0.5;
		vec2 c = vec2(cos(ang), sin(ang)) * (0.1 + fly * 0.45) - vec2(0.0, sin(fly * PI) * 0.18);
		float r = 0.14 * shrink;
		float rock = c_rock(p - c, r, f + seed * 3.0);
		if (rock > -0.02 && r > 0.0) {
			color = rock <= 0.0 ? C_RIM : c_rock_shade(p - c, rock, r);
			a = 1.0;
		}
	}
	float flash = 0.4 * (1.0 - smoothstep(0.0, 0.15, t)) - d;
	if (flash > 0.0) {
		color = flash > 0.15 ? C_WHITE : C_LAVA_HOT;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
