shader_type canvas_item;
render_mode blend_mix;

// CE QUE LE SANG LUI REND : des gouttes de vie remontent vers lui en spirale de tous côtés, puis une bouffée
// de lumière pâle l'enveloppe.

#include "res://assets/shaders/archi.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = F_VENOM;
	float a = 0.0;
	for (int i = 0; i < 12; i++) {
		float f = float(i);
		float k = clamp(t * 1.6 - f * 0.04, 0.0, 1.0);
		float ca = f / 12.0 * TAU + k * 2.0;
		vec2 at = vec2(cos(ca), sin(ca)) * mix(0.95, 0.05, k);
		vec3 drop = color;
		if (k > 0.0 && k < 1.0 && f_paint_drop(f_rot(p - at, ca + 1.5708), 0.07, drop)) {
			color = i % 3 == 0 ? mix(drop, F_BLOOD, 0.6) : drop;
			a = 1.0;
		}
	}
	float bloom = smoothstep(0.5, 0.75, t) * (1.0 - smoothstep(0.8, 1.0, t));
	float d = length(p);
	if (d < 0.6 * bloom) {
		color = mix(F_CORE, F_BRIGHT, d / max(0.01, 0.6 * bloom));
		a = max(a, bloom * (1.0 - d / max(0.01, 0.6 * bloom)) * 0.9);
	}
	COLOR = vec4(color, a);
}
