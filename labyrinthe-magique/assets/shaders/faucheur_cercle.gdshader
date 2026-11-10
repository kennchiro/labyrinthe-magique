shader_type canvas_item;
render_mode blend_mix;

// LA RÉCOLTE, toute la minute : un cercle de braise fendu bat sous ses pieds, couché au sol.

#include "res://assets/shaders/faucheur.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	p.y *= 2.2;
	float d = length(p);
	float a = atan(p.y, p.x) + TIME * 0.4;
	float born = smoothstep(0.0, 0.03, progress);
	float split = step(0.08, abs(sin(a * 1.5)));
	float beat = 0.7 + 0.3 * sin(TIME * 3.0);
	float ring = smoothstep(0.05, 0.0, abs(d - 0.66)) * split;
	float inner = smoothstep(0.02, 0.0, abs(d - 0.52)) * 0.5;
	vec4 color = vec4(F_EMBER, (ring * beat + inner) * born);
	COLOR = color;
}
