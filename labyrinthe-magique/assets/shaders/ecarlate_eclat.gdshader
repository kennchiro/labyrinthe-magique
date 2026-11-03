shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLAT DES ENTAILLES : toutes s'ouvrent à la fois. `count` longues coupes barrent l'ennemi en
// étoile, s'élargissent d'un coup en plaies de lumière, et un vol de pétales part avec elles.

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float count = 5.0;

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
	float t = progress;
	vec3 color = WHITE;
	float a = 0.0;
	float open = smoothstep(0.0, 0.12, t);
	float close = 1.0 - smoothstep(0.3, 0.85, t);
	for (int i = 0; i < int(count); i++) {
		float f = float(i);
		float angle = f / max(count, 1.0) * 3.1416 + (hash(f) - 0.5) * 0.3 + 0.35;
		float c = cos(angle);
		float s = sin(angle);
		vec2 q = vec2(p.x * c + p.y * s, p.y * c - p.x * s);
		float length_cut = 0.95 * open;
		float width = (0.11 * open * close) * (1.0 - min(1.0, abs(q.x) / max(length_cut, 0.01)));
		float blade = width - abs(q.y);
		if (blade > -0.016 && abs(q.x) < length_cut && close > 0.0) {
			color = blade > width * 0.3 && blade > 0.0 ? WHITE : (blade > 0.0 ? RED : BLACK);
			a = 1.0;
		}
	}
	if (t < 0.1 && (1.0 - t / 0.1) * 0.55 - d > 0.0) {
		color = vec3(1.0);
		a = 1.0;
	}
	for (int i = 0; i < 14; i++) {
		float f = float(i);
		float dir = hash(f + 7.0) * 6.283;
		vec2 at = vec2(cos(dir), sin(dir)) * (0.1 + smoothstep(0.05, 0.9, t) * (0.45 + hash(f + 9.0) * 0.5));
		at.y += t * t * 0.3;
		float blade = petal(p, at, dir + t * 8.0, 0.13 * (1.0 - smoothstep(0.5, 1.0, t)));
		if (blade > 0.0 && t > 0.06) {
			color = blade > 0.3 ? WHITE : RED;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
