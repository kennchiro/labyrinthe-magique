shader_type canvas_item;
render_mode blend_mix;

// LA FIN DE L'ÉVEIL : ses ailes se défont en cendres, un nuage de flocons gris et de braises qui
// montent un instant, puis retombent et s'éteignent.

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
	vec3 color = vec3(0.35, 0.32, 0.3);
	float a = 0.0;
	for (int i = 0; i < 18; i++) {
		float f = float(i);
		float side = hash(f) > 0.5 ? 1.0 : -1.0;
		vec2 start = vec2(side * (0.2 + hash(f + 1.0) * 0.6), -0.4 + hash(f + 2.0) * 0.6);
		vec2 c = start + vec2(side * t * 0.25, -t * 0.4 + t * t * 1.2);
		float size = 0.06 * (1.0 - t) * (0.6 + hash(f + 3.0));
		float flake = size - length((p - c) * vec2(1.0, 1.6));
		if (flake > -0.015 && size > 0.0) {
			bool ember = hash(f + 5.0) > 0.7;
			color = flake <= 0.0 ? RIM : (ember ? (t < 0.5 ? GOLD : RED) : vec3(0.42, 0.38, 0.36));
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
