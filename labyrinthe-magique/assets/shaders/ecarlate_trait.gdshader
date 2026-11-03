shader_type canvas_item;
render_mode blend_mix;

// LA COUPE QUI BARRE UN ENNEMI : une ligne jaillit d'un coup, s'ouvre, puis se referme en glissant,
// et deux pétales s'en échappent.

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
	float angle = (hash(1.0) - 0.5) * 1.2 + 0.6;
	float c = cos(angle);
	float s = sin(angle);
	vec2 q = vec2(p.x * c + p.y * s, p.y * c - p.x * s);
	vec3 color = WHITE;
	float a = 0.0;
	float reach = smoothstep(0.0, 0.2, t);
	float back = smoothstep(0.45, 1.0, t);
	float along = (q.x + 1.0) * 0.5;
	float width = 0.09 * (1.0 - t) * (1.0 - abs(q.x));
	if (along < reach && along > back && abs(q.y) < width + 0.018) {
		color = abs(q.y) < width ? WHITE : RED;
		a = 1.0;
	}
	for (int i = 0; i < 4; i++) {
		float f = float(i);
		vec2 at = vec2(hash(f + 2.0) - 0.5, -0.25 + t * (0.3 + hash(f + 4.0) * 0.5)) * vec2(1.3, 1.0);
		float blade = petal(p, at, t * 5.0 + f, 0.15 * (1.0 - t * t));
		if (blade > 0.0 && t > 0.1) {
			color = blade > 0.25 ? WHITE : RED;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
