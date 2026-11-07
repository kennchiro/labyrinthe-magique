shader_type canvas_item;
render_mode blend_mix;

// LE CHOC DE LA FOUDRE : une étoile blanche, quatre éclairs qui partent en étoile, et un anneau bleu.

#include "res://assets/shaders/tempete.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float t = progress;
	vec3 color = T_BLUE;
	float a = 0.0;
	float front = 0.2 + smoothstep(0.0, 0.6, t) * 0.6;
	float width = 0.05 * (1.0 - smoothstep(0.3, 0.9, t));
	float ring = width - abs(d - front);
	if (ring > -0.015 && width > 0.0) {
		color = ring <= 0.0 ? T_RIM : T_BLUE;
		a = 1.0;
	}
	float reach = smoothstep(0.0, 0.25, t) * 0.85;
	float fade = 1.0 - smoothstep(0.35, 0.8, t);
	for (int i = 0; i < 5; i++) {
		float f = float(i);
		vec2 q = t_rot(p, -(f / 5.0 * TAU + seed * 4.0));
		float bolt = t_bolt(q, reach, 0.05 * fade, 0.3, f + seed * 9.0, floor(TIME * 14.0));
		if (bolt > -0.02 && fade > 0.0) {
			color = bolt <= 0.0 ? T_RIM : t_bolt_color(bolt / 0.05);
			a = 1.0;
		}
	}
	float star = t_star(p, 0.45 * (1.0 - smoothstep(0.0, 0.35, t)), 8.0, 6.0);
	if (star > -0.02 && t < 0.35) {
		color = star <= 0.0 ? T_RIM : (star > 0.06 ? T_WHITE : T_BLUE);
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
