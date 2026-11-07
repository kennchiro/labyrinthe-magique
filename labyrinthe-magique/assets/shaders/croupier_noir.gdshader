shader_type canvas_item;
// Le Croupier des Enfers : recoloré depuis geolier_nova, or, bordeaux et noir.
render_mode blend_mix;

// LE SOUFFLE GLACÉ : la flamme se rétracte en un point, puis un anneau de flamme froide déferle,
// hérissé de pointes de givre qui restent plantées un instant au sol après son passage.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(0.91, 0.71, 0.29);
const vec3 EMBER = vec3(0.12, 0.09, 0.085);
const vec3 LAVA = vec3(0.3, 0.24, 0.2);
const vec3 DEEP = vec3(0.05, 0.035, 0.03);
const vec3 BLACK = vec3(0.788, 0.635, 0.153);

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float angle = atan(p.y, p.x);
	float t = progress;
	vec3 color = EMBER;
	float a = 0.0;
	if (t < 0.18) {
		float core = 0.3 * (1.0 - t / 0.18) - d;
		if (core > 0.0) {
			color = core > 0.12 ? PALE : EMBER;
			a = 1.0;
		}
	}
	float wave = smoothstep(0.15, 0.7, t);
	float front = 0.08 + wave * 0.86;
	float tongues = 0.05 + 0.04 * sin(angle * 14.0 + seed * 6.0 + t * 9.0);
	float width = tongues * (1.0 - smoothstep(0.6, 1.0, t));
	float ring = width - abs(d - front);
	if (ring > 0.0 && t >= 0.15) {
		color = ring > width * 0.5 ? PALE : (ring > width * 0.2 ? EMBER : DEEP);
		a = 1.0;
	}
	for (int i = 0; i < 12; i++) {
		float f = float(i);
		float dir = f / 12.0 * 6.283 + hash(f) * 0.3;
		float at = 0.25 + hash(f + 3.0) * 0.6;
		float born = smoothstep(0.15, 0.7, t) * 0.94 + 0.08 > at ? 1.0 : 0.0;
		float life = 1.0 - smoothstep(0.75, 1.0, t);
		vec2 c = vec2(cos(dir), sin(dir)) * at;
		vec2 q = p - c;
		float along = dot(q, vec2(cos(dir), sin(dir)));
		float side = abs(dot(q, vec2(-sin(dir), cos(dir))));
		float spike = (0.12 * life - abs(along)) * 0.35 - side;
		if (born > 0.5 && spike > 0.0) {
			color = spike > 0.012 ? PALE : LAVA;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
