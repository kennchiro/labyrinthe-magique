shader_type canvas_item;
render_mode blend_mix;

// L'ARMEMENT D'UN ENNEMI : des éclats qui convergent vers lui et un anneau qui se resserre.
// C'est l'avertissement du coup : on le voit venir, et qui s'écarte à temps l'esquive.

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
	float d = length(p);
	vec3 color = mid;
	float a = 0.0;
	float radius = mix(0.95, 0.35, t);
	float ring = 0.05 * (0.4 + t) - abs(d - radius);
	if (ring > 0.0) {
		color = ring > 0.025 * (0.4 + t) ? light : mid;
		a = 1.0;
	}
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float dir = f / 8.0 * 6.2832 + seed;
		float r = mix(1.0, 0.3, fract(t * 1.4 + hash(f)));
		vec2 at = vec2(cos(dir), sin(dir)) * r;
		vec2 o = p - at;
		float along = abs(dot(o, normalize(at)));
		float across = abs(dot(o, vec2(-at.y, at.x) / max(length(at), 0.01)));
		float s = 0.05 - across * 1.2 - along * 0.35;
		if (s > 0.0) {
			color = mod(f, 2.0) < 1.0 ? light : deep;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a * (0.55 + 0.45 * t));
}
