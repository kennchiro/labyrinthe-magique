shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLABOUSSURE DE LA GELÉE : une couronne d'eau qui se dresse, l'anneau qui s'étale au sol
// et des gouttes lancées en gerbe qui retombent.

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec3 light = vec3(1.0);
uniform vec3 mid = vec3(0.8);
uniform vec3 deep = vec3(0.2);

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = mid;
	float a = 0.0;
	vec2 q = vec2(p.x, p.y * 2.2 - 0.5);
	float front = 0.15 + smoothstep(0.0, 0.6, t) * 0.7;
	float ring = 0.12 * (1.0 - t) - abs(length(q) - front);
	if (ring > 0.0 && t < 0.85) {
		color = ring > 0.06 * (1.0 - t) ? light : mid;
		a = 1.0;
	}
	float rise = sin(min(t * 1.8, 1.0) * 3.1416);
	for (int i = 0; i < 7; i++) {
		float f = float(i);
		float x = (f / 6.0 - 0.5) * 1.1;
		float top = 0.25 - rise * (0.45 + hash(f) * 0.3) * (1.0 - abs(x) * 0.6);
		float w = 0.06 * (1.0 - t);
		if (abs(p.x - x) < w && p.y > top && p.y < 0.28) {
			color = abs(p.x - x) < w * 0.45 ? light : mid;
			a = 1.0;
		}
		float drop = 0.07 * (1.0 - t) - length(p - vec2(x * 1.3, top - 0.08 + t * t * 0.6));
		if (drop > 0.0 && t > 0.15) {
			color = deep;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
