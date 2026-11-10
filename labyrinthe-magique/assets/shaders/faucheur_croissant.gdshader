shader_type canvas_item;
render_mode blend_mix;

// LE CROISSANT DE L'AU-DELÀ en vol : une lame noire au tranchant de braise qui tourne sur elle-même, et un filet de
// cendres. Le quad est carré, centré sur la lame.

#include "res://assets/shaders/faucheur.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float spin = TIME * 14.0 + seed * 6.0;
	vec2 q = mat2(vec2(cos(spin), sin(spin)), vec2(-sin(spin), cos(spin))) * p;
	vec4 color = vec4(F_ASH, f_glow(length(p), 0.95) * 0.25);
	color = f_over(f_blade(q, 0.8, 0.45, 0.0, 1.0), color);
	COLOR = color;
}
