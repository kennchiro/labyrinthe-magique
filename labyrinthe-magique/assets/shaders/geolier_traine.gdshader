shader_type canvas_item;
render_mode blend_mix;

// LE POING EN VOL : trois langues de flamme froide à plages nettes, qui claquent derrière lui.

uniform float seed = 0.0;
uniform sampler2D noise;

const vec3 PALE = vec3(0.902, 0.992, 1.0);
const vec3 EMBER = vec3(0.086, 0.878, 0.91);
const vec3 LAVA = vec3(0.4, 0.94, 0.97);
const vec3 DEEP = vec3(0.039, 0.435, 0.478);
const vec3 BLACK = vec3(0.078, 0.094, 0.122);

void fragment() {
	vec2 p = UV;
	float t = TIME * 5.0 + seed * 9.0;
	float a = 0.0;
	vec3 color = EMBER;
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		float y = 0.5 + (f - 1.0) * 0.22 * (1.0 - p.x);
		float wave = sin(p.x * 11.0 - t * 2.0 + f * 2.1) * 0.05 * (1.0 - p.x);
		float width = 0.2 * p.x * p.x * (1.0 - f * 0.12);
		float d = width - abs(p.y - y - wave);
		if (d > 0.0) {
			a = 1.0;
			color = d > width * 0.55 ? PALE : (d > width * 0.25 ? EMBER : LAVA);
		}
	}
	if (a > 0.0 && p.x < 0.25) {
		color = DEEP;
	}
	COLOR = vec4(color, a);
}
