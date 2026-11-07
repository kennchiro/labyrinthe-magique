shader_type canvas_item;
render_mode blend_mix;

// PLUMES DU PHÉNIX, le projectile : une plume de feu à cœur blanc, pointe devant, qui se déchire
// en langues vers l'arrière. UV.x va de la queue (0) à la pointe (1).

uniform sampler2D noise : repeat_enable, filter_linear;
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
	vec2 p = vec2(UV.x * 2.0 - 1.0, (UV.y - 0.5) * 2.0);
	vec3 color = ORANGE;
	float a = 0.0;
	// La plume, poussée vers l'avant du quad.
	vec2 q = vec2(p.x - 0.25, p.y);
	float body = feather(q, 0.72, 0.62);
	if (body > -0.08) {
		a = 1.0;
		color = body <= 0.0 ? RIM : (abs(q.y) < 0.07 ? RED : (body > 0.32 ? WHITE : (body > 0.15 ? GOLD : ORANGE)));
	}
	// Les langues qui traînent derrière.
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		float y0 = (f - 1.0) * 0.32;
		float wave = sin(p.x * 9.0 + TIME * 22.0 + f * 2.0 + seed * 5.0) * 0.08;
		float tail = (p.x < -0.3 && p.x > -1.0) ? (0.14 * (p.x + 1.0) / 0.7) - abs(p.y - y0 - wave) : -1.0;
		if (tail > -0.04 && a < 0.5) {
			color = tail <= 0.0 ? RED : (tail > 0.05 ? GOLD : ORANGE);
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
