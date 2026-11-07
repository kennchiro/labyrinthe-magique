shader_type canvas_item;
render_mode blend_mix;

// UN BRASIER TOUCHE : l'ennemi s'embrase un instant, trois langues de flamme qui montent et
// retombent.

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
	float rise = smoothstep(0.0, 0.3, t) * (1.0 - smoothstep(0.5, 1.0, t));
	float y = 0.7 - p.y;
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		float x0 = (f - 1.0) * 0.3;
		float h = (0.9 + hash(f) * 0.5 - abs(f - 1.0) * 0.25) * rise;
		float k = clamp(y / max(h, 0.001), 0.0, 1.0);
		float hw = 0.2 * (1.0 - k * k);
		float inside = hw - abs(p.x - x0 - sin(t * 25.0 + f + y * 5.0) * 0.06 * k);
		if (y > 0.0 && y < h && inside > -0.03) {
			color = inside <= 0.0 ? RIM : (inside > hw * 0.55 ? WHITE : (k > 0.6 ? RED : GOLD));
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
