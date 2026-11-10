shader_type canvas_item;
render_mode blend_mix;

// UN COUP RENVOYÉ PAR L'ÉGIDE : un rayon net part de lui vers celui qui a frappé. x de lui vers sa cible.

#include "res://assets/shaders/aurore.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	float x = UV.x;
	float y = abs(UV.y - 0.5) * 2.0;
	float t = progress;
	float reach = smoothstep(0.0, 0.3, t);
	vec4 color = a_beam(y, mix(0.7, 0.2, t), step(x, reach) * (1.0 - smoothstep(0.6, 1.0, t)));
	vec2 tip = vec2((x - reach) * 6.0, (UV.y - 0.5) * 2.0);
	color = a_over(a_star_paint(tip, 0.7, t * 6.0, step(0.05, reach) * (1.0 - t)), color);
	COLOR = color;
}
