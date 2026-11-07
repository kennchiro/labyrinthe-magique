shader_type canvas_item;
render_mode blend_mix;

// PENDANT LA MINUTE : de petits arcs crépitent sur lui, trois à la fois, à des endroits qui changent
// une dizaine de fois par seconde. Ils restent collés au corps.

#include "res://assets/shaders/tempete.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec3 color = T_BLUE;
	float a = 0.0;
	float flick = floor(TIME * 11.0);
	float show = smoothstep(0.0, 0.01, progress) * (1.0 - smoothstep(0.98, 1.0, progress));
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		if (t_hash(f + flick * 3.0, seed) < 0.3) {
			continue;
		}
		float ang = t_hash(f * 7.0 + flick, seed) * TAU;
		vec2 start = vec2(cos(ang) * 0.45, sin(ang) * 0.75);
		vec2 q = t_rot(p - start, -(ang + PI * 0.6));
		float arc = t_bolt(q, 0.4, 0.035, 0.25, f + flick, flick);
		if (arc > -0.015 && show > 0.0) {
			color = arc <= 0.0 ? T_RIM : t_bolt_color(arc / 0.035);
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
