shader_type canvas_item;
render_mode blend_mix;

// LA LANCE DE L'AURORE RESTÉE ALLUMÉE : un rayon épais qui pulse le long du couloir, puis se fend en poussière d'or.
// x le long du couloir.

#include "res://assets/shaders/aurore.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	float x = UV.x;
	float y = abs(UV.y - 0.5) * 2.0;
	float t = progress;
	float reach = smoothstep(0.0, 0.08, t);
	float pulse = 0.8 + 0.2 * sin(TIME * 8.0 - x * 12.0);
	float fade = 1.0 - smoothstep(0.82, 1.0, t);
	vec4 color = a_beam(y, 0.7 * pulse, step(x, reach) * fade);
	float dust = step(0.82, texture(noise, vec2(x * 3.0, UV.y * 2.0 + TIME * 0.5 + seed)).r);
	float crumble = smoothstep(0.75, 1.0, t);
	color = a_over(vec4(A_GOLD, dust * crumble * (1.0 - smoothstep(0.95, 1.0, t)) * step(y, 0.9)), color);
	COLOR = color;
}
