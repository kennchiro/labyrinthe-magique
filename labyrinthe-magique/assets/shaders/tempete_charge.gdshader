shader_type canvas_item;
render_mode blend_mix;

// LE GESTE D'ÉVEIL : six éclairs montent du sol et s'enroulent autour de lui, de plus en plus serrés,
// et un anneau jaune se resserre à ses pieds.

#include "res://assets/shaders/tempete.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = T_BLUE;
	float a = 0.0;
	float flick = floor(TIME * 16.0);
	// L'anneau qui se resserre au sol.
	vec2 g = (p - vec2(0.0, 0.5)) * vec2(1.0, 2.2);
	float ring = 0.04 - abs(length(g) - mix(0.95, 0.25, t));
	if (ring > -0.015) {
		color = ring <= 0.0 ? T_RIM : T_YELLOW;
		a = 1.0;
	}
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		float ang = f / 6.0 * TAU + t * 5.0;
		float r = mix(0.85, 0.3, t);
		vec2 foot = vec2(cos(ang) * r, 0.5 + sin(ang) * r * 0.4);
		vec2 q = t_rot(p - foot, PI * 0.5);
		// La rotation d'un quart de tour couche la verticale sur +x : l'éclair monte.
		float bolt = t_bolt(q, 0.4 + 0.5 * t, 0.035, 0.2, f + seed, flick);
		if (bolt > -0.015) {
			color = bolt <= 0.0 ? T_RIM : t_bolt_color(bolt / 0.035);
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
