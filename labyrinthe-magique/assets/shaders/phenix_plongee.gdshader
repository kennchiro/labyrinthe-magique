shader_type canvas_item;
render_mode blend_mix;

// LA PLONGÉE DU PHÉNIX : un oiseau de feu, ailes repliées, file le long de sa course en laissant
// une traînée de plumes ; le nœud étire et oriente le quad. UV.x : départ (0), arrivée (1).

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
	vec2 p = vec2(UV.x, (UV.y - 0.5) * 2.0);
	float t = progress;
	float head = mix(0.08, 0.95, smoothstep(0.0, 0.55, t));
	vec3 color = ORANGE;
	float a = 0.0;
	// La traînée : des plumes de flamme, de plus en plus fines vers l'arrière, qui se consument.
	float behind = head - p.x;
	float fade = 1.0 - smoothstep(0.45, 1.0, t);
	float trail = (behind > 0.0 && behind < 0.9) ? (0.38 * (1.0 - behind / 0.9) * fade) - abs(p.y + sin(p.x * 30.0 + t * 30.0) * 0.08) : -1.0;
	if (trail > -0.05 && fade > 0.0) {
		color = trail <= 0.0 ? RIM : (trail > 0.18 ? WHITE : (trail > 0.08 ? GOLD : RED));
		a = 1.0;
	}
	// L'oiseau : un corps en goutte et deux ailes repliées vers l'arrière.
	vec2 q = vec2((p.x - head) * 6.0, p.y);
	float body = feather(vec2(q.x + 0.1, q.y), 0.55, 0.32);
	float wing_up = feather(vec2(q.x + 0.35, q.y + 0.35 + q.x * 0.5), 0.45, 0.16);
	float wing_down = feather(vec2(q.x + 0.35, q.y - 0.35 - q.x * 0.5), 0.45, 0.16);
	float bird = max(body, max(wing_up, wing_down));
	if (bird > -0.05 && t < 0.62) {
		color = bird <= 0.0 ? RIM : (body > 0.12 ? WHITE : (bird > 0.05 ? GOLD : ORANGE));
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
