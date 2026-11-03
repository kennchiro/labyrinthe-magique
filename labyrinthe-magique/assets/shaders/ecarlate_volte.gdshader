shader_type canvas_item;
render_mode blend_mix;

// LA VOLTE-FACE : une gerbe de pétales blancs tourne, s'ouvre, puis tombe en se réduisant.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 WHITE = vec3(1.0, 0.965, 0.933);
const vec3 STEEL = vec3(0.851, 0.871, 0.89);
const vec3 RED = vec3(0.722, 0.078, 0.078);
const vec3 DEEP = vec3(0.369, 0.039, 0.039);
const vec3 BLACK = vec3(0.09, 0.09, 0.102);
float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

// Un pétale : deux arcs qui se rejoignent, fendu à son bout.
float petal(vec2 p, vec2 at, float angle, float size) {
	vec2 q = p - at;
	float c = cos(angle);
	float s = sin(angle);
	q = vec2(q.x * c + q.y * s, q.y * c - q.x * s) / max(size, 0.001);
	if (abs(q.x) >= 1.0) {
		return -1.0;
	}
	return 1.0 - (abs(q.y) / (0.55 * (1.0 - q.x * q.x) + 0.001) + q.x * q.x);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = WHITE;
	float a = 0.0;
	for (int i = 0; i < 14; i++) {
		float f = float(i);
		float dir = f / 14.0 * 6.283 + t * 2.4 + hash(f) * 0.4;
		float reach = 0.12 + smoothstep(0.0, 0.6, t) * (0.4 + hash(f + 3.0) * 0.45);
		vec2 at = vec2(cos(dir), sin(dir) * 0.8) * reach;
		at.y += t * t * 0.45;
		float blade = petal(p, at, dir + t * 7.0, 0.17 * (1.0 - smoothstep(0.55, 1.0, t)));
		if (blade > 0.0) {
			color = blade > 0.3 ? WHITE : RED;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
