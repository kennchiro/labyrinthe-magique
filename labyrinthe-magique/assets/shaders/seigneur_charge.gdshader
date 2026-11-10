shader_type canvas_item;
render_mode blend_mix;

// LE GESTE D'ÉVEIL DU SEIGNEUR : des pétales blancs tourbillonnent autour de lui en se resserrant, rougissent un à un,
// puis une coupe verticale fend l'air au-dessus de lui : la lame fantôme en sort.

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
	float r = mix(0.85, 0.35, smoothstep(0.0, 0.75, t));
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float ang = f * TAU / 10.0 + t * 7.0;
		vec2 at = vec2(cos(ang) * r, sin(ang) * r * 0.45 - 0.1 - f * 0.02);
		vec2 q = s_rot(p - at, ang + t * 4.0);
		vec3 c = color;
		if (s_paint_petal(q, 0.075, f / 10.0 < t * 1.3, c)) {
			color = c;
			a = 1.0;
		}
	}
	// La coupe verticale au-dessus de lui.
	float k = smoothstep(0.62, 0.8, t);
	float fade = 1.0 - smoothstep(0.88, 1.0, t);
	vec3 c = color;
	if (k > 0.0 && fade > 0.0 && s_paint_cut(p, vec2(0.0, -0.95), vec2(0.0, mix(-0.95, 0.3, k)), 0.07 * fade, c)) {
		color = c;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
