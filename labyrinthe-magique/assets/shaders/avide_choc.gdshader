shader_type canvas_item;
// L'Avide : recoloré depuis braise_choc, vert bile, os et noir d'encre.
render_mode blend_mix;

// L'IMPACT D'UN POING : l'éclair à quatre branches, l'anneau qui part et les escarbilles.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(0.949, 1.0, 0.69);
const vec3 EMBER = vec3(0.784, 0.91, 0.188);
const vec3 LAVA = vec3(0.608, 0.761, 0.122);
const vec3 DEEP = vec3(0.353, 0.478, 0.071);
const vec3 BLACK = vec3(0.067, 0.063, 0.078);
float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float d = length(p);
	vec3 color = EMBER;
	float a = 0.0;
	float size = (1.0 - smoothstep(0.0, 0.55, t)) * smoothstep(0.0, 0.08, t);
	float star = size * 0.75 - (abs(p.x) + abs(p.y)) * (1.0 + 7.0 * min(abs(p.x), abs(p.y)) / max(d, 0.01));
	if (star > 0.0) {
		color = star > size * 0.3 ? PALE : EMBER;
		a = 1.0;
	}
	float front = 0.15 + smoothstep(0.0, 0.7, t) * 0.65;
	float ring = 0.06 * (1.0 - t) - abs(d - front);
	if (ring > 0.0 && t < 0.85) {
		color = ring > 0.025 * (1.0 - t) ? PALE : LAVA;
		a = 1.0;
	}
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float angle = hash(f) * 6.283;
		vec2 at = vec2(cos(angle), sin(angle)) * (0.15 + t * (0.5 + hash(f + 3.0) * 0.4));
		at.y += t * t * 0.25;
		float s = 0.055 * (1.0 - t) - length(p - at);
		if (s > 0.0) {
			color = mod(f, 2.0) < 0.5 ? EMBER : PALE;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
