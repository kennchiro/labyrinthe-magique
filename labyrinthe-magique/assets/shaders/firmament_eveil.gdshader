shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLOSION : la grande étoile à cinq branches se trace au sol autour d'elle, éclate en lumière ; des rayons
// blancs partent en couronne, et des éclats d'étoiles s'envolent.

#include "res://assets/shaders/firmament.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float life = 1.0 - smoothstep(0.65, 1.0, t);
	vec4 color = vec4(0.0);
	// L'étoile à cinq branches, couchée au sol sous elle.
	vec2 g = vec2(p.x, (p.y - 0.22) * 2.2);
	float drawn = smoothstep(0.02, 0.24, t) * 5.0;
	for (int i = 0; i < 5; i++) {
		float part = clamp(drawn - float(i), 0.0, 1.0);
		vec2 a = r_point(i * 2, 0.86, t * 0.6);
		vec2 b = r_point(i * 2 + 2, 0.86, t * 0.6);
		color = r_over(r_ray(g, a, mix(a, b, part), 0.035, part * life), color);
	}
	float ring = smoothstep(0.04, 0.0, abs(length(g) - 0.9)) * smoothstep(0.3, 0.45, t) * life;
	color = r_over(vec4(R_SILVER, ring), color);
	// L'éclat : la figure s'allume, une couronne de rayons blancs part du centre de son corps.
	vec2 c = p - vec2(0.0, -0.1);
	float burst = smoothstep(0.38, 0.48, t) * (1.0 - smoothstep(0.5, 0.95, t));
	float spokes = pow(abs(cos(atan(c.y, c.x) * 4.0 + t * 2.0)), 18.0) * r_glow(length(c), 0.95);
	color = r_over(vec4(R_SHINE, spokes * burst), color);
	color = r_over(vec4(R_GOLD, r_glow(length(c), 0.42) * burst), color);
	// Les éclats d'étoiles qui s'envolent.
	for (int i = 0; i < 9; i++) {
		float f = float(i);
		float a = f * TAU / 9.0 + r_hash(f, seed);
		float fly = smoothstep(0.42, 1.0, t);
		vec2 at = vec2(cos(a), sin(a) * 0.8 - 0.3) * (0.2 + fly * 0.7);
		float seen = step(0.42, t) * (1.0 - fly);
		color = r_over(r_star(c - at, 0.08, a + t * 6.0, seen), color);
	}
	COLOR = color;
}
