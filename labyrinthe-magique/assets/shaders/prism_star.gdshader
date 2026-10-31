shader_type canvas_item;
render_mode blend_mix;

// L'IMPACT DU TRAIT : un éclat court, tout entier de la matière qui vient de frapper.

#include "res://assets/shaders/elements.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform int kind = 0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x);
	float front = (1.0 - pow(1.0 - progress, 2.6)) * 0.86;
	float spikes = 0.68 + 0.32 * pow(abs(cos(a * 2.5 + seed * 3.0)), 3.0);
	float h = (front * spikes - d) * 2.2 - progress * progress * 1.3;
	vec4 matter = paint_element(kind, vec2(d * 1.1, a * 0.3 + seed), TIME + seed, h);
	float flash = (1.0 - smoothstep(0.0, 0.22, progress)) * smoothstep(0.3, 0.2, d);
	COLOR = vec4(mix(matter.rgb, vec3(1.0, 0.98, 0.88), flash), max(matter.a, flash) * COLOR.a);
}
