shader_type canvas_item;
render_mode blend_mix;

// L'IMPACT DU GROS MÉTÉORE : un éclair d'or et de blanc, une onde d'argent qui court au sol, huit éclats d'étoiles
// qui partent en couronne, et un anneau de poussière bleue qui retombe.

#include "res://assets/shaders/firmament.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec2 g = vec2(p.x, p.y * 2.0);
	float d = length(g);
	vec4 color = vec4(0.0);
	// L'onde au sol.
	float wave = smoothstep(0.06, 0.0, abs(d - t * 0.95)) * (1.0 - t);
	color = r_over(vec4(R_SILVER, wave), color);
	float dust = smoothstep(0.18, 0.0, abs(d - t * 0.7)) * (1.0 - t) * 0.5;
	color = r_over(vec4(R_BLUE, dust), color);
	// Les éclats.
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float a = f * TAU / 8.0 + r_hash(f, seed) * 0.4;
		vec2 at = vec2(cos(a), sin(a) * 0.55) * (0.1 + t * 0.8);
		color = r_over(r_star(p - at, 0.1 * (1.0 - t * 0.6), a + t * 7.0, 1.0 - smoothstep(0.6, 1.0, t)), color);
	}
	// L'éclair.
	float flash = 1.0 - smoothstep(0.0, 0.35, t);
	color = r_over(vec4(R_SHINE, r_glow(length(p), 0.7) * flash), color);
	color = r_over(vec4(R_GOLD, r_glow(length(p), 0.35) * flash), color);
	color = r_over(r_star(p, 0.55 * flash, t * 3.0, flash), color);
	COLOR = color;
}
