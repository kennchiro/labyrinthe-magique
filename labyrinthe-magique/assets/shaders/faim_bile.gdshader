shader_type canvas_item;
render_mode blend_mix;

// LA FLAQUE DE BILE du Déluge : une flaque vert vif, aux bords déchiquetés, qui bouillonne de bulles qui crèvent, et
// qui se rétracte à la fin. Couchée sur le sol ; le centre reste lisible.

#include "res://assets/shaders/faim.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float radius_tiles = 1.5;
uniform float seed = 0.0;
uniform float phase = 0.0;
uniform float life = 1.0;
uniform float aura = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float grow = clamp(phase / 0.25, 0.0, 1.0);
	float dry = smoothstep(0.3, 0.0, life);
	float wobble = texture(noise, p * 0.6 + vec2(seed, phase * 0.05)).r * 0.15;
	float edge = 0.85 * grow * (1.0 - dry * 0.7) - d + wobble;
	vec3 color = vec3(0.0);
	float a = 0.0;
	if (edge > 0.0) {
		color = edge > 0.08 ? mix(G_BILE, G_DEEP, smoothstep(0.0, 0.8, d)) : G_DEEP;
		a = 0.7;
	} else if (edge > -0.03) {
		color = G_INK;
		a = 0.7;
	}
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		float k = fract(phase * 0.7 + g_hash(f, seed));
		vec2 at = vec2(g_hash(f + 2.0, seed) - 0.5, g_hash(f + 4.0, seed) - 0.5) * 1.1 * grow;
		float r = 0.1 * sin(k * 3.14159);
		float ring = 0.018 - abs(length(p - at) - r);
		if (edge > 0.05 && ring > 0.0 && k < 0.92) {
			color = G_PALE;
			a = 0.95;
		}
	}
	COLOR = vec4(color, a * COLOR.a);
}
