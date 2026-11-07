shader_type canvas_item;
render_mode blend_mix;

// LE GESTE D'ÉVEIL : l'eau monte du sol en spirale autour de lui, deux rubans qui s'enroulent de
// plus en plus vite et se resserrent.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 FOAM = vec3(0.914, 1.0, 1.0);
const vec3 TEAL = vec3(0.329, 0.918, 0.859);
const vec3 BLUE = vec3(0.216, 0.776, 1.0);
const vec3 ABYSS = vec3(0.027, 0.345, 0.741);
const vec3 SILVER = vec3(0.784, 0.839, 0.898);
const vec3 RIM = vec3(0.024, 0.169, 0.384);

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = TEAL;
	float a = 0.0;
	for (int s = 0; s < 2; s++) {
		for (int i = 0; i < 18; i++) {
			float f = float(i) / 18.0;
			float at = f * 9.0 + t * 16.0 * (1.0 + t) + float(s) * 3.1416;
			float r = mix(0.9, 0.25, t) * (1.0 - f * 0.25);
			vec2 c = vec2(cos(at) * r, sin(at) * r * 0.4 + 0.6 - f * 1.4 * smoothstep(0.0, 0.5, t));
			float blob = 0.09 * (1.0 - f * 0.5) - length(p - c);
			if (blob > -0.02) {
				color = blob <= 0.0 ? RIM : (blob > 0.05 ? FOAM : (s == 0 ? TEAL : BLUE));
				a = 1.0;
			}
		}
	}
	COLOR = vec4(color, a);
}
