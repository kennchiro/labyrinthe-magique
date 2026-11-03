shader_type canvas_item;
render_mode blend_mix;

// LA TRAVERSÉE : l'armure se défait en une flamme froide haute, qui s'amincit et passe.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(0.902, 0.992, 1.0);
const vec3 EMBER = vec3(0.086, 0.878, 0.91);
const vec3 LAVA = vec3(0.4, 0.94, 0.97);
const vec3 DEEP = vec3(0.039, 0.435, 0.478);
const vec3 BLACK = vec3(0.078, 0.094, 0.122);
float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = EMBER;
	float a = 0.0;
	float height = 0.25 + smoothstep(0.0, 0.6, t) * 0.65;
	float y = clamp((0.72 - p.y) / (height * 1.6), 0.0, 1.0);
	float wave = sin(p.y * 9.0 - TIME * 14.0 + seed * 5.0) * 0.06 * y;
	float width = 0.34 * pow(1.0 - y, 0.8) * (1.0 - smoothstep(0.55, 1.0, t));
	float d = width - abs(p.x - wave);
	if (d > 0.0 && p.y < 0.72) {
		color = d > width * 0.6 ? PALE : (d > width * 0.3 ? EMBER : DEEP);
		a = 1.0;
	}
	vec2 ground = vec2(p.x, (p.y - 0.72) * 3.0);
	float front = 0.15 + t * 0.75;
	float ring = 0.1 * (1.0 - t) - abs(length(ground) - front);
	if (ring > 0.0) {
		color = LAVA;
		a = 1.0;
	}
	for (int i = 0; i < 7; i++) {
		float f = float(i);
		vec2 at = vec2((hash(f) - 0.5) * 0.9, 0.6 - t * (0.7 + hash(f + 2.0) * 0.9));
		if (0.045 * (1.0 - t) - length(p - at) > 0.0) {
			color = PALE;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
