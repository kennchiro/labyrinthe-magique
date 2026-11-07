shader_type canvas_item;
render_mode blend_mix;

// UNE BRAISE DE SA TRAÎNÉE : deux ou trois petites flammes posées au sol, qui baissent jusqu'à
// s'éteindre en un point rouge.

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
	vec3 color = ORANGE;
	float a = 0.0;
	float size = (1.0 - smoothstep(0.3, 1.0, t)) * smoothstep(0.0, 0.08, t);
	float y = 0.5 - p.y;
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		float x0 = (hash(f) - 0.5) * 0.9;
		float h = (0.4 + hash(f + 3.0) * 0.45) * size;
		float k = clamp(y / max(h, 0.001), 0.0, 1.0);
		float hw = 0.14 * (1.0 - k * k) * (0.5 + 0.5 * size);
		float inside = hw - abs(p.x - x0 - sin(TIME * 14.0 + f * 2.0 + y * 6.0) * 0.04 * k);
		if (y > 0.0 && y < h && inside > -0.025) {
			color = inside <= 0.0 ? RIM : (inside > hw * 0.5 ? GOLD : (k > 0.6 ? RED : ORANGE));
			a = 1.0;
		}
	}
	float coal = 0.12 * (1.0 - t) - length(vec2(p.x, (p.y - 0.5) * 2.5));
	if (coal > 0.0 && a < 0.5) {
		color = RED;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
