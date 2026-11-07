shader_type canvas_item;
render_mode blend_mix;

// LE SOLEIL CAPTIF, le projectile : une grosse boule de feu à cœur blanc, cerclée de plumes de
// flamme qui tournent autour d'elle, et une traînée derrière. UV.x : queue (0), tête (1).

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
	vec2 c = vec2(0.35, 0.0);
	vec2 q = p - c;
	float d = length(q * vec2(1.4, 1.0));
	float angle = atan(q.y, q.x);
	vec3 color = ORANGE;
	float a = 0.0;
	// La traînée.
	float trail = (p.x < 0.3) ? (0.55 * (p.x + 1.0) / 1.3) - abs(p.y + sin(p.x * 7.0 + TIME * 18.0) * 0.06) : -1.0;
	if (trail > -0.04) {
		color = trail <= 0.0 ? RED : (trail > 0.25 ? GOLD : ORANGE);
		a = 1.0;
	}
	// Les plumes en couronne.
	for (int i = 0; i < 6; i++) {
		float at = float(i) * 1.047 + TIME * 4.0 + seed;
		vec2 dir = vec2(cos(at), sin(at));
		vec2 local = vec2(dot(q * vec2(1.4, 1.0) - dir * 0.62, dir), dot(q * vec2(1.4, 1.0), vec2(-dir.y, dir.x)));
		float f = feather(local, 0.22, 0.12);
		if (f > -0.03) {
			color = f <= 0.0 ? RIM : (f > 0.05 ? GOLD : ORANGE);
			a = 1.0;
		}
	}
	// Le soleil.
	float sun = 0.55 + 0.04 * sin(angle * 9.0 + TIME * 12.0) - d;
	if (sun > -0.05) {
		color = sun <= 0.0 ? RIM : (sun > 0.3 ? WHITE : (sun > 0.15 ? GOLD : ORANGE));
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
