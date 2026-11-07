shader_type canvas_item;
render_mode blend_mix;

// AUX DEUX BOUTS DE LA PLONGÉE : un éventail de plumes de feu jaillit, et un anneau d'or court
// au sol.

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
	float d = length(p);
	float t = progress;
	vec3 color = GOLD;
	float a = 0.0;
	float front = 0.15 + smoothstep(0.0, 0.6, t) * 0.7;
	float width = 0.07 * (1.0 - smoothstep(0.35, 0.9, t));
	float ring = width - abs(d - front);
	if (ring > -0.025 && width > 0.0) {
		color = ring <= 0.0 ? RIM : (ring > width * 0.5 ? WHITE : GOLD);
		a = 1.0;
	}
	for (int i = 0; i < 9; i++) {
		float f = float(i);
		float at = -3.1416 + f / 8.0 * 3.1416;
		vec2 dir = vec2(cos(at), sin(at));
		float reach = 0.15 + smoothstep(0.0, 0.5, t) * 0.5;
		vec2 q = vec2(dot(p - dir * reach, dir), dot(p, vec2(-dir.y, dir.x)));
		float size = 1.0 - smoothstep(0.45, 1.0, t);
		float fl = feather(q, 0.28 * size, 0.1 * size);
		if (fl > -0.03 && size > 0.0) {
			color = fl <= 0.0 ? RIM : (fl > 0.05 ? WHITE : (fl > 0.02 ? GOLD : ORANGE));
			a = 1.0;
		}
	}
	float flash = 0.4 * (1.0 - smoothstep(0.0, 0.18, t)) - d;
	if (flash > 0.0) {
		color = WHITE;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
