shader_type canvas_item;
render_mode blend_mix;

// LA DANSE DES PÉTALES : à sa place reste un tourbillon de pétales-lames qui se resserre en tournant de plus en plus
// vite, puis éclate à la fin en quatre coupes. L'ennemi qui s'en approche se fait entailler.

#include "res://assets/shaders/seigneur.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	float burst = smoothstep(0.8, 0.9, t);
	float r = mix(0.8, 0.3, smoothstep(0.0, 0.8, t));
	for (int i = 0; i < 14; i++) {
		float f = float(i);
		float ang = f * TAU / 14.0 + t * t * 16.0;
		float rr = r * (0.7 + 0.3 * s_hash(f, seed)) + burst * 0.6;
		vec2 at = vec2(cos(ang) * rr, sin(ang) * rr * 0.6 - 0.15 - s_hash(f + 2.0, seed) * 0.3);
		vec3 c = color;
		if (burst < 0.99 && s_paint_petal(s_rot(p - at, ang), 0.07 * (1.0 - burst), mod(f, 2.0) < 1.0, c)) {
			color = c;
			a = 1.0;
		}
	}
	for (int i = 0; i < 4; i++) {
		float an = float(i) * 0.785 + 0.39;
		vec2 dir = vec2(cos(an), sin(an)) * 0.9 * burst;
		vec3 c = color;
		if (burst > 0.0 && t < 0.98 && s_paint_cut(p, -dir, dir, 0.07, c)) {
			color = c;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
