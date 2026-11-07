shader_type canvas_item;
render_mode blend_mix;

// LA COURONNE DE BRASIERS : trois braises tournent autour de lui, reliées par un arc de flamme
// qui tourne avec elles. Elle se resserre et s'éteint à la fin.

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
uniform float seconds = 10.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	p.y *= 1.35;
	float d = length(p);
	float angle = atan(p.y, p.x);
	float t = progress;
	float live = smoothstep(0.0, 0.05, t) * (1.0 - smoothstep(0.95, 1.0, t));
	float spin = t * seconds * 3.2;
	vec3 color = ORANGE;
	float a = 0.0;
	float r = 0.7 * live;
	// L'arc : il relie les braises, plus épais près de chacune.
	float around = mod(angle - spin, 2.0944) / 2.0944;
	float width = (0.03 + 0.05 * (1.0 - around)) * live;
	float arc = width - abs(d - r - 0.03 * sin(angle * 12.0 + t * 60.0));
	if (arc > -0.02 && live > 0.0) {
		color = arc <= 0.0 ? RED : (arc > width * 0.5 ? GOLD : ORANGE);
		a = 1.0;
	}
	for (int i = 0; i < 3; i++) {
		float at = spin + float(i) * 2.0944;
		vec2 c = vec2(cos(at), sin(at)) * r;
		float q = length(p - c);
		float ember = 0.17 * live * (0.9 + 0.1 * sin(t * 80.0 + float(i))) - q;
		if (ember > -0.035 && live > 0.0) {
			color = ember <= 0.0 ? RIM : (ember > 0.09 ? WHITE : (ember > 0.04 ? GOLD : ORANGE));
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
