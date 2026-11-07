shader_type canvas_item;
render_mode blend_mix;

// L'AURA DU PHÉNIX, pendant la minute : un lit de braises palpite sous ses pieds, et des plumes de
// feu retombent de ses ailes en se consumant. Elle s'éteint à la fin.

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
	float live = smoothstep(0.0, 0.02, progress) * (1.0 - smoothstep(0.98, 1.0, progress));
	vec3 color = ORANGE;
	float a = 0.0;
	// Le lit de braises, aplati, sous les pieds.
	vec2 g = vec2(p.x, (p.y - 0.62) * 3.2);
	float bed = 0.55 * live * (0.9 + 0.1 * sin(TIME * 5.0)) - length(g);
	if (bed > 0.0) {
		float n = fract(sin(dot(floor(g * 7.0), vec2(12.9, 78.2)) + seed) * 43758.5);
		color = bed > 0.3 ? GOLD : (n > 0.6 ? ORANGE : RED);
		a = bed > 0.08 ? 0.8 : 0.55;
	}
	// Les plumes qui tombent.
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		float k = fract(TIME * (0.35 + hash(f) * 0.2) + hash(f + 1.0));
		vec2 c = vec2((hash(f + 2.0) - 0.5) * 1.3 + sin(TIME * 2.0 + f) * 0.1, -0.7 + k * 1.3);
		float spin = TIME * 3.0 + f;
		vec2 dir = vec2(cos(spin), sin(spin));
		vec2 q = vec2(dot(p - c, dir), dot(p - c, vec2(-dir.y, dir.x)));
		float size = 1.0 - k;
		float fl = feather(q, 0.09 * size, 0.035 * size);
		if (fl > -0.012 && live > 0.0 && size > 0.05) {
			color = fl <= 0.0 ? RED : (hash(f + 4.0) > 0.5 ? GOLD : ORANGE);
			a = 1.0;
		}
	}
	COLOR = vec4(color, a * live);
}
