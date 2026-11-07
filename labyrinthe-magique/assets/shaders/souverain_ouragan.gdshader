shader_type canvas_item;
render_mode blend_mix;

// L'ŒIL DE L'OURAGAN, la zone qui le suit : une immense spirale à cinq bras tourne au sol autour de lui,
// l'œil calme au centre cerclé d'or. Elle s'enroule vers lui : ce qui approche est aspiré.

#include "res://assets/shaders/souverain.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float radius_tiles = 3.0;
uniform float aura = 0.0;
uniform float seed = 0.0;
uniform float phase = 0.0;
uniform float life = 1.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float open = smoothstep(0.0, 0.5, phase) * smoothstep(0.0, 0.12, life);
	float d = length(p);
	vec3 color = S_SKY;
	float a = 0.0;
	// Mince et translucide : elle tient dix secondes sur lui, elle ne doit pas cacher le couloir.
	float spin = s_spiral(p, 0.3, 5.0, 0.12, -phase * 3.0, 0.95 * open);
	if (spin > 0.0 && d > 0.2) {
		color = d < 0.5 ? S_WHITE : (d < 0.75 ? S_PALE : S_SKY);
		a = 0.5 * (1.0 - smoothstep(0.6, 0.95, d) * 0.5);
	}
	float eye = 0.035 - abs(d - 0.2 * open);
	if (eye > -0.015 && open > 0.0) {
		color = eye <= 0.0 ? S_RIM : S_GOLD;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
