shader_type canvas_item;
render_mode blend_mix;

// LES CHAÎNES QUI SE RESSERRENT : la proie est prise dans un BLOC DE GLACE à facettes, cerclé de deux chaînes en
// croix, qui craque puis éclate en éclats à la fin. Quad centré sur son corps.

#include "res://assets/shaders/abime.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	float grow = smoothstep(0.0, 0.12, t);
	float burst = smoothstep(0.85, 1.0, t);
	// Le bloc hexagonal.
	vec2 h = abs(p);
	float hex = (0.62 * grow) - max(h.x * 0.866 + h.y * 0.5, h.y);
	if (hex > -0.03 && burst < 0.5) {
		float facet = step(0.0, sin((p.x + p.y) * 9.0 + seed));
		color = hex <= 0.0 ? A_OBSIDIAN : mix(A_CYAN, A_PALE, facet * 0.5 + step(0.5, hex * 4.0) * 0.2);
		a = hex <= 0.0 ? 1.0 : 0.7;
		// Les fissures qui gagnent.
		float crack = 0.012 - abs(sin(atan(p.y, p.x) * 3.0 + seed) * length(p) - 0.0);
		if (t > 0.6 && crack > 0.0 && length(p) < (t - 0.6) * 2.5) {
			color = A_PALE;
			a = 1.0;
		}
	}
	// Deux chaînes en croix.
	vec3 c = color;
	if (burst < 0.5 && grow > 0.9 && (a_paint_chain(p, vec2(-0.6, -0.4), vec2(0.6, 0.4), 0.05, c)
			|| a_paint_chain(p, vec2(-0.6, 0.4), vec2(0.6, -0.4), 0.05, c))) {
		color = c;
		a = 1.0;
	}
	// Les éclats.
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float an = f * TAU / 8.0 + seed;
		vec2 at = vec2(cos(an), sin(an)) * (0.3 + burst * 0.6);
		float s = a_shard(a_rot(p - at, an), 0.05, 0.1);
		if (burst > 0.0 && t < 0.99 && s > 0.0) {
			color = A_PALE;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
