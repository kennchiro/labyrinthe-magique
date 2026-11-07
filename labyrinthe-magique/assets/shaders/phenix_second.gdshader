shader_type canvas_item;
render_mode blend_mix;

// LA SECONDE EXPLOSION du Soleil captif : plus blanche, plus sèche, un anneau qui claque et se
// resserre en un point.

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
	float t = progress;
	vec3 color = WHITE;
	float a = 0.0;
	float core = 0.6 * (1.0 - smoothstep(0.0, 0.5, t)) - d;
	if (core > -0.04) {
		color = core <= 0.0 ? ORANGE : (core > 0.2 ? WHITE : GOLD);
		a = 1.0;
	}
	float front = 0.2 + smoothstep(0.0, 0.6, t) * 0.65;
	float width = 0.08 * (1.0 - smoothstep(0.3, 1.0, t));
	float ring = width - abs(d - front);
	if (ring > -0.025 && width > 0.0) {
		color = ring <= 0.0 ? RIM : (ring > width * 0.5 ? WHITE : GOLD);
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
