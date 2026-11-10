shader_type canvas_item;
render_mode blend_mix;

// LA COURONNE DE RAYONS à ses pieds, toute la minute : un anneau fin d'où battent de courts rayons, couché au sol.

#include "res://assets/shaders/aurore.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	p.y *= 2.2;
	float d = length(p);
	float ang = atan(p.y, p.x);
	float born = smoothstep(0.0, 0.03, progress);
	float ring = smoothstep(0.04, 0.0, abs(d - 0.62));
	float spikes = pow(abs(cos(ang * 8.0 - TIME * 0.8)), 20.0) * step(0.62, d) * smoothstep(0.85 + 0.08 * sin(TIME * 3.0), 0.62, d);
	vec4 color = vec4(A_GOLD, ring * 0.8);
	color = a_over(vec4(A_GOLD_LIGHT, spikes * 0.7), color);
	color.a *= born;
	COLOR = color;
}
