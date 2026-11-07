shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLOSION DU COLOSSE : les rochers arrivent de partout et se plaquent sur lui dans un grand choc,
// les cristaux s'allument, puis l'onde de poussière et de fissures part au sol.

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
	float impact = smoothstep(0.22, 0.3, t);
	// L'onde au sol, après le choc.
	float wave = smoothstep(0.28, 0.8, t);
	float front = 0.25 + wave * 0.7;
	vec2 g = p * vec2(1.0, 1.4);
	float gd = length(g);
	float puffs = 0.5 + 0.5 * cos(atan(g.y, g.x) * 9.0);
	float width = 0.1 * (1.0 - smoothstep(0.6, 1.0, t)) * impact * smoothstep(0.2, 0.7, puffs);
	float ring = width - abs(gd - front);
	if (ring > -0.02 && width > 0.01) {
		color = ring <= 0.0 ? C_RIM : (ring > width * 0.5 ? C_DUST : C_ROCK_LIGHT);
		a = 1.0;
	}
	// Les fissures que l'onde laisse.
	float heat = 1.0 - smoothstep(0.6, 1.0, t);
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		vec2 q = c_rot(g, -(f / 8.0 * TAU + seed));
		float crack = c_crack(q, front * impact, 0.08 * heat, 0.18, f + 4.0);
		if (crack > -0.025 && heat > 0.0 && impact > 0.0) {
			color = crack <= 0.0 ? C_RIM : c_lava(crack / 0.08, heat);
			a = 1.0;
		}
	}
	// Les rochers qui convergent sur lui, puis disparaissent au choc.
	float come = smoothstep(0.0, 0.25, t);
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float ang = f / 10.0 * TAU + c_hash(f, seed);
		vec2 c = vec2(cos(ang), sin(ang)) * mix(0.95, 0.12, come) + vec2(0.0, -0.15);
		float r = (0.1 + 0.05 * c_hash(f + 3.0, seed)) * (1.0 - impact);
		float rock = c_rock(p - c, r, f + seed * 4.0);
		if (rock > -0.02 && r > 0.0) {
			a = 1.0;
			color = rock <= 0.0 ? C_RIM : c_rock_shade(p - c, rock, r);
		}
	}
	// L'éclair vert du choc : une étoile de cristal à huit branches, brève.
	float burst = impact * (1.0 - smoothstep(0.3, 0.42, t));
	float star = (0.12 + 0.3 * pow(abs(cos(atan(p.y, p.x) * 4.0)), 6.0)) * burst - d;
	if (star > -0.02 && burst > 0.0) {
		color = star <= 0.0 ? C_RIM : (star > 0.08 ? C_WHITE : C_GLOW);
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
