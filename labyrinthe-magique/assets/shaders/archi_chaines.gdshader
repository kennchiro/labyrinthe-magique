shader_type canvas_item;
render_mode blend_mix;

// LES CHAÎNES DU PACTE, au geste d'Éveil : un anneau de maillons d'or se resserre autour de lui comme un
// contrat qui étrangle, puis CÈDE : les maillons volent en éclats vers l'extérieur en tournoyant, dans un
// éclair pâle. Le pacte est brisé, le démon sort.

#include "res://assets/shaders/archi.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

const float LINKS = 16.0;
const float SNAP = 0.45;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec2 g = vec2(p.x, p.y * 1.25);
	float ang = atan(g.y, g.x);
	float k = floor(ang / TAU * LINKS + 0.5);
	float ca = k / LINKS * TAU;
	float burst = smoothstep(SNAP, SNAP + 0.18, t);
	float radius = t < SNAP ? mix(0.8, 0.4, smoothstep(0.0, SNAP, t))
		: mix(0.4, 1.05 + f_hash(k, seed) * 0.2, smoothstep(SNAP, 1.0, t));
	vec2 centre = vec2(cos(ca), sin(ca)) * radius;
	float spin = burst * (f_hash(k + 5.0, seed) - 0.5) * 6.0;
	vec2 q = f_rot(g - centre, -ca - 1.5708 + spin);
	float flat_link = mod(k, 2.0) < 0.5 ? 1.0 : 0.42;
	float shrink = 1.0 - smoothstep(0.72, 1.0, t);
	float e = length(vec2(q.x / (0.11 * shrink + 0.001), q.y / (0.06 * flat_link * shrink + 0.001)));
	float link = 0.2 - abs(e - 1.0);
	vec3 color = F_BRONZE;
	float a = 0.0;
	if (link > 0.0 && shrink > 0.02) {
		color = link > 0.13 ? F_CORE : F_BRONZE;
		a = 1.0;
	} else if (link > -0.08 && shrink > 0.02) {
		color = F_RIM;
		a = 1.0;
	}
	// L'éclair de la rupture : un anneau pâle qui part.
	float flash_t = clamp((t - SNAP) / 0.3, 0.0, 1.0);
	float wave = 0.05 * (1.0 - flash_t) - abs(length(g) - mix(0.4, 1.0, flash_t));
	if (flash_t > 0.0 && flash_t < 1.0 && wave > 0.0) {
		color = wave > 0.025 ? F_CORE : F_BRIGHT;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
