shader_type canvas_item;
render_mode blend_mix;

// LE COUP QUI ÉCRASE LE SOL : l'éclat au point d'impact, des fissures qui partent en étoile,
// l'anneau de poussière qui s'écarte et des éclats projetés qui retombent.

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec3 light = vec3(1.0);
uniform vec3 mid = vec3(0.8);
uniform vec3 deep = vec3(0.2);

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}
uniform float cracks = 6.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float d = length(p);
	float angle = atan(p.y, p.x);
	vec3 color = mid;
	float a = 0.0;
	for (int i = 0; i < 9; i++) {
		float f = float(i);
		if (f >= cracks) {
			break;
		}
		float dir = (f + hash(f) * 0.6) / cracks * 6.2832;
		float gap = abs(mod(angle - dir + 3.1416, 6.2832) - 3.1416);
		float reach = (0.45 + hash(f + 2.0) * 0.4) * smoothstep(0.0, 0.25, t);
		float zig = sin(d * 18.0 + f * 3.0) * 0.04;
		float line = 0.02 * (1.0 - smoothstep(0.6, 1.0, t)) - abs(gap * d - zig) - step(reach, d);
		if (line > 0.0 && d > 0.08) {
			color = deep;
			a = 1.0;
		}
	}
	float size = (1.0 - smoothstep(0.0, 0.4, t)) * smoothstep(0.0, 0.06, t);
	float star = size * 0.62 - (abs(p.x) + abs(p.y)) * (1.0 + 6.0 * min(abs(p.x), abs(p.y)) / max(d, 0.01));
	if (star > 0.0) {
		color = star > size * 0.3 ? light : mid;
		a = 1.0;
	}
	float front = 0.2 + smoothstep(0.0, 0.65, t) * 0.62;
	float ring = 0.07 * (1.0 - t) - abs(d - front);
	if (ring > 0.0 && t < 0.8) {
		color = ring > 0.03 * (1.0 - t) ? light : mid;
		a = 1.0;
	}
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float dir = hash(f + 9.0) * 6.2832;
		vec2 at = vec2(cos(dir), sin(dir)) * (0.12 + t * (0.45 + hash(f + 1.0) * 0.4));
		at.y += t * t * 0.4 - t * 0.2;
		vec2 off = abs(p - at);
		float s = 0.055 * (1.0 - t) - max(off.x, off.y);
		if (s > 0.0) {
			color = mod(f, 2.0) < 1.0 ? mid : deep;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
