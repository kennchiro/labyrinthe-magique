shader_type canvas_item;
render_mode blend_mix;

// UNE PLUME SE PLANTE : elle se consume en une petite gerbe d'or et trois flammèches qui montent.

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
	float t = progress;
	vec3 color = GOLD;
	float a = 0.0;
	float grow = smoothstep(0.0, 0.2, t) * (1.0 - smoothstep(0.4, 1.0, t));
	float d = length(p);
	float angle = atan(p.y, p.x);
	float star = 0.6 * grow * (0.6 + 0.4 * abs(sin(angle * 3.0 + seed * 4.0))) - d;
	if (star > -0.05 && grow > 0.0) {
		color = star <= 0.0 ? RIM : (star > 0.25 ? WHITE : (star > 0.1 ? GOLD : ORANGE));
		a = 1.0;
	}
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		vec2 c = vec2((f - 1.0) * 0.4, -0.2 - t * 0.7);
		vec2 q = vec2(-(p.y - c.y), p.x - c.x);
		float flame = feather(q, 0.18 * (1.0 - t), 0.09 * (1.0 - t));
		if (flame > -0.02 && t > 0.15 && t < 0.95) {
			color = flame <= 0.0 ? RED : ORANGE;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
