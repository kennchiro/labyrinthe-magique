shader_type canvas_item;
render_mode blend_mix;

// LE GESTE D'ÉVEIL : une spirale de plumes de feu monte autour de lui et se resserre, de plus en
// plus vite, jusqu'à l'éclosion.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 WHITE = vec3(1.0, 0.957, 0.839);
const vec3 GOLD = vec3(1.0, 0.761, 0.227);
const vec3 ORANGE = vec3(1.0, 0.416, 0.165);
const vec3 RED = vec3(0.702, 0.125, 0.059);
const vec3 RIM = vec3(0.165, 0.039, 0.02);

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

float feather(vec2 q, float len, float wid) {
	// Hors de sa longueur, ce n'est plus la plume : sans ce bord, son contour filait à l'infini.
	if (abs(q.x) > len) {
		return -1.0;
	}
	float s = q.x / len;
	float half_width = wid * pow(max(0.0, 1.0 - s * s), 0.6) * (s > 0.0 ? 1.0 - s * 0.4 : 1.0);
	return half_width - abs(q.y);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = GOLD;
	float a = 0.0;
	for (int i = 0; i < 12; i++) {
		float f = float(i);
		float k = fract(f / 12.0 + t * 1.6);
		float at = f * 2.399 + t * 14.0 * (1.0 + t);
		float r = mix(0.95, 0.15, t) * (1.0 - k * 0.3);
		vec2 c = vec2(cos(at) * r, sin(at) * r * 0.45 + 0.6 - k * 1.3);
		vec2 dir = vec2(-sin(at), cos(at) * 0.45);
		dir = normalize(dir + vec2(0.0, -0.6));
		vec2 q = vec2(dot(p - c, dir), dot(p - c, vec2(-dir.y, dir.x)));
		float fl = feather(q, 0.17, 0.065);
		if (fl > -0.025) {
			color = fl <= 0.0 ? RIM : (fl > 0.035 ? WHITE : (hash(f) > 0.5 ? GOLD : ORANGE));
			a = 1.0;
		}
	}
	float glow = 0.25 * t - length(p - vec2(0.0, 0.15));
	if (glow > 0.0) {
		color = glow > 0.1 ? WHITE : GOLD;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
