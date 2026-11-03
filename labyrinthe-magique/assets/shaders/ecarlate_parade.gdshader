shader_type canvas_item;
render_mode blend_mix;

// LA PARADE : l'étincelle sur la lame, un éclair à quatre branches très long, puis la riposte, un
// grand cercle de coupe qui part de lui et se brise en arcs.

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
	float d = length(p);
	float angle = atan(p.y, p.x);
	float t = progress;
	vec3 color = WHITE;
	float a = 0.0;
	float size = (1.0 - smoothstep(0.0, 0.4, t)) * smoothstep(0.0, 0.05, t);
	float star = size - (abs(p.x) + abs(p.y)) * (1.0 + 14.0 * min(abs(p.x), abs(p.y)) / max(d, 0.01));
	if (star > 0.0) {
		color = star > size * 0.3 ? WHITE : RED;
		a = 1.0;
	}
	float front = smoothstep(0.1, 0.8, t) * 0.92;
	float width = 0.075 * (1.0 - smoothstep(0.2, 1.0, t));
	float broken = t > 0.5 ? step(0.3 * (t - 0.5) * 2.0, abs(fract(angle / 6.2832 * 6.0 + seed) - 0.5)) : 1.0;
	if (width - abs(d - front) > 0.0 && broken > 0.5) {
		color = width - abs(d - front) > width * 0.45 ? WHITE : RED;
		a = 1.0;
	}
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float dir = hash(f) * 6.283;
		vec2 at = vec2(cos(dir), sin(dir)) * front * (0.6 + hash(f + 2.0) * 0.5);
		if (petal(p, at, dir, 0.1 * (1.0 - t)) > 0.0 && t > 0.15) {
			color = WHITE;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
