shader_type canvas_item;
render_mode blend_mix;

// LE SOUFFLE, vers la droite du quad : un cône de langues de flamme qui jaillit, couches
// nettes du cœur blanc au rouge, puis des braises qui montent.

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
	float reach = smoothstep(0.0, 0.3, t) * 1.7 - 0.85;
	float fade = 1.0 - smoothstep(0.5, 0.85, t);
	float x = p.x + 0.85;
	if (p.x < reach && x > 0.0 && fade > 0.0) {
		float lick = sin(x * 9.0 - TIME * 14.0 + seed * 6.0) * 0.06 + sin(x * 17.0 + TIME * 9.0) * 0.03;
		float wide = x * 0.5 * fade + 0.04;
		float edge = wide - abs(p.y + lick * x);
		if (edge > 0.0) {
			float depth = edge / wide;
			color = depth > 0.62 ? light : (depth > 0.28 ? mid : deep);
			a = 1.0;
		}
	}
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float born = 0.2 + hash(f) * 0.35;
		float life = clamp((t - born) / (1.0 - born), 0.0, 1.0);
		vec2 at = vec2(-0.2 + hash(f + 1.0) * 1.0, (hash(f + 2.0) - 0.5) * 0.6 - life * 0.55);
		float s = 0.045 * (1.0 - life) * step(born, t) - length(p - at);
		if (s > 0.0) {
			color = mod(f, 2.0) < 1.0 ? light : mid;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
