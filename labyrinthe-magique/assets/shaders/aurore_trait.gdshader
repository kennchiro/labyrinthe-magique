shader_type canvas_item;
render_mode blend_mix;

// LE TRAIT SOLAIRE en vol : un rayon blanc à cœur d'or, une étoile à sa pointe. x le long du tir.

#include "res://assets/shaders/aurore.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	float x = UV.x;
	float y = abs(UV.y - 0.5) * 2.0;
	float body = smoothstep(0.0, 0.5, x) * smoothstep(1.0, 0.8, x);
	vec4 color = a_beam(y, 0.45 * body + 0.05, body);
	float sparkle = texture(noise, vec2(x * 2.0 - TIME * 3.0, UV.y + seed)).r;
	color.rgb = mix(color.rgb, A_WHITE, sparkle * 0.3);
	vec2 tip = vec2((x - 0.78) * 2.6, (UV.y - 0.5) * 2.0);
	color = a_over(a_star_paint(tip, 0.75, TIME * 4.0, 1.0), color);
	COLOR = color;
}
