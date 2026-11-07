shader_type canvas_item;
render_mode blend_mix;

// UN PAS DU SOUVERAIN : une petite volute de vent se soulève sous son pied et s'efface.

#include "res://assets/shaders/souverain.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	p.y *= 1.6;
	float t = progress;
	vec3 color = S_PALE;
	float a = 0.0;
	float fade = 1.0 - smoothstep(0.3, 1.0, t);
	float spin = s_spiral(p, 0.22, 1.0, 0.3 * fade, t * 6.0 + seed * 5.0, 0.7 * smoothstep(0.0, 0.3, t));
	if (spin > 0.0) {
		color = S_PALE;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
