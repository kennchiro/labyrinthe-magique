shader_type canvas_item;
render_mode blend_mix;

// LE TRAIT ÉLÉMENTAIRE : une pointe de lumière, et un corps qui change de matière à chaque tir.

#include "res://assets/shaders/elements.gdshaderinc"

uniform float seed = 0.0;
// 0 feu, 1 eau, 2 terre, 3 air.
uniform int kind = 0;

void fragment() {
	float x = UV.x;
	float y = abs(UV.y - 0.5) * 2.0;
	float body = smoothstep(1.0, 0.76, x) * pow(x, 0.75);
	vec4 matter = paint_element(kind, vec2(x * 1.3, (UV.y - 0.5) * 0.9 + seed), TIME + seed, (body - y) * 1.15);
	float tip = (0.46 * smoothstep(1.0, 0.8, x) * smoothstep(0.55, 0.8, x) - y) * 3.0;
	vec3 color = mix(matter.rgb, vec3(1.0, 0.98, 0.84), smoothstep(0.0, 0.3, tip));
	COLOR = vec4(color, max(matter.a, smoothstep(0.0, 0.2, tip)) * COLOR.a);
}
