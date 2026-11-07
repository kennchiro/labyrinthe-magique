shader_type canvas_item;
render_mode blend_mix;

// LE DARD, vers la droite du quad : un trait fin qui file, une étoile longue à quatre branches
// au point touché, et des paillettes qui flottent.

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
	float tip = mix(-0.8, 0.45, smoothstep(0.0, 0.25, t));
	float tail = mix(-0.8, 0.45, smoothstep(0.15, 0.45, t));
	if (p.x < tip && p.x > tail && abs(p.y) < 0.035 * (1.0 - smoothstep(0.3, 0.5, t))) {
		color = light;
		a = 1.0;
	}
	vec2 c = p - vec2(0.45, 0.0);
	float size = smoothstep(0.18, 0.28, t) * (1.0 - smoothstep(0.3, 0.7, t));
	float star = size * 0.75 - (abs(c.x) * 0.55 + abs(c.y) * 1.3) * (1.0 + 6.0 * min(abs(c.x), abs(c.y)) / max(length(c), 0.01));
	if (star > 0.0) {
		color = star > size * 0.3 ? light : mid;
		a = 1.0;
	}
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float life = clamp((t - 0.3) / 0.7, 0.0, 1.0);
		float dir = hash(f) * 6.2832;
		vec2 at = vec2(0.45, 0.0) + vec2(cos(dir), sin(dir)) * life * (0.25 + hash(f + 3.0) * 0.4);
		vec2 o = abs(p - at);
		float s = 0.05 * (1.0 - life) * step(0.3, t) - (o.x + o.y);
		if (s > 0.0) {
			color = mod(f, 2.0) < 1.0 ? light : deep;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
