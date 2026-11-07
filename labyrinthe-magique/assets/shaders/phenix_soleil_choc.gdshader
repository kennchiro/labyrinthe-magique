shader_type canvas_item;
render_mode blend_mix;

// LE SOLEIL ÉCLATE : une fleur de flammes à huit pétales, cœur blanc, qui s'ouvre puis se referme
// en se consumant ; des plumes d'or sont projetées tout autour.

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

// Une plume : x le long (pointe en +1), y en travers ; > 0 dedans.
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
	float d = length(p);
	float angle = atan(p.y, p.x);
	float t = progress;
	vec3 color = ORANGE;
	float a = 0.0;
	float bloom = smoothstep(0.0, 0.18, t) * (1.0 - smoothstep(0.45, 1.0, t));
	float petals = 0.72 * bloom * (0.62 + 0.38 * pow(abs(cos(angle * 4.0 + seed)), 0.6));
	float inside = petals - d;
	if (inside > -0.05 && bloom > 0.0) {
		color = inside <= 0.0 ? RIM : (inside > petals * 0.6 ? WHITE : (inside > petals * 0.3 ? GOLD : (inside > 0.06 ? ORANGE : RED)));
		a = 1.0;
	}
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float at = f / 10.0 * 6.2832 + hash(f) * 0.4;
		vec2 dir = vec2(cos(at), sin(at));
		float reach = 0.25 + smoothstep(0.05, 0.9, t) * 0.7;
		vec2 q = vec2(dot(p - dir * reach, dir), dot(p, vec2(-dir.y, dir.x)));
		float fl = feather(q, 0.1 * (1.0 - t * 0.7), 0.05 * (1.0 - t * 0.7));
		if (fl > -0.02 && t > 0.08) {
			color = fl <= 0.0 ? RIM : GOLD;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
