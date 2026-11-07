shader_type canvas_item;
render_mode blend_mix;

// RENAISSANCE : un tas de cendres rougeoyantes, puis un phénix de feu en jaillit, ailes grandes
// ouvertes, et l'onde part en anneau. Le mage reprend forme au centre.

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
	vec3 color = ORANGE;
	float a = 0.0;
	// Les cendres, d'abord.
	float ash = (1.0 - smoothstep(0.15, 0.3, t));
	vec2 g = vec2(p.x, (p.y - 0.45) * 2.6);
	float pile = 0.35 * ash - length(g);
	if (pile > -0.03 && ash > 0.0) {
		float n = fract(sin(dot(floor(g * 9.0), vec2(12.9, 78.2)) + seed) * 43758.5);
		color = pile <= 0.0 ? RIM : (n > 0.7 ? GOLD : (n > 0.4 ? RED : vec3(0.3, 0.27, 0.26)));
		a = 1.0;
	}
	// Le phénix qui jaillit.
	float rise = smoothstep(0.18, 0.45, t) * (1.0 - smoothstep(0.75, 1.0, t));
	vec2 b = p - vec2(0.0, 0.3 - rise * 0.55);
	float body = feather(vec2(-b.y, b.x), 0.38 * rise, 0.16 * rise);
	float wings = -1.0;
	for (int s = 0; s < 2; s++) {
		float sgn = s == 0 ? 1.0 : -1.0;
		for (int i = 0; i < 5; i++) {
			float angle = -1.15 + float(i) * 0.28;
			vec2 dir = vec2(cos(angle) * sgn, sin(angle));
			float len = 0.85 * rise;
			vec2 l = vec2(dot(b, dir) - len * 0.5, dot(b, vec2(-dir.y, dir.x)));
			wings = max(wings, feather(l, len * 0.5, 0.1 * rise));
		}
	}
	float bird = max(body, wings);
	if (bird > -0.035 && rise > 0.0) {
		color = bird <= 0.0 ? RIM : (body > 0.06 ? WHITE : (bird > 0.05 ? GOLD : ORANGE));
		a = 1.0;
	}
	// L'onde.
	float front = smoothstep(0.25, 0.8, t) * 0.85;
	float width = 0.08 * (1.0 - smoothstep(0.5, 1.0, t));
	float ring = width - abs(d - front);
	if (ring > -0.025 && t > 0.25 && width > 0.0) {
		color = ring <= 0.0 ? RIM : (ring > width * 0.5 ? WHITE : GOLD);
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
