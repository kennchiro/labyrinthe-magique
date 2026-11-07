shader_type canvas_item;
render_mode blend_mix;

// UNE COLONNE DE FEU : un cercle d'or se dessine au sol en un battement, puis un pilier de flammes
// jaillit, haut de deux cases, aux langues qui montent, et retombe en cendres. UV.y : ciel (0),
// sol (1) ; le pied tombe à 0,95.

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
	float x = (UV.x - 0.5) * 2.0;
	float y = UV.y;
	float t = progress;
	vec3 color = ORANGE;
	float a = 0.0;
	// Le cercle au sol, aplati par la vue.
	vec2 e = vec2(x / 0.9, (y - 0.95) / 0.04);
	float ring = 0.18 - abs(length(e) - 0.8 * smoothstep(0.0, 0.15, t));
	if (ring > -0.1 && y > 0.88 && t < 0.85) {
		color = ring > 0.0 ? GOLD : RIM;
		a = 1.0;
	}
	// Le pilier : il jaillit (0,15 → 0,3), tient, puis s'affaisse en langues qui raccourcissent.
	float rise = smoothstep(0.15, 0.3, t);
	float fall = 1.0 - smoothstep(0.6, 1.0, t);
	float top = 0.95 - 0.88 * rise * fall;
	float h = (0.95 - y) / max(0.95 - top, 0.001);
	float width = 0.55 * (1.0 - h * h * 0.6) + 0.1 * sin(y * 25.0 - t * 40.0 + seed * 6.0) * h;
	float inside = width - abs(x);
	if (y < 0.95 && y > top && inside > -0.06 && rise > 0.0) {
		a = 1.0;
		color = inside <= 0.0 ? RIM : (inside > width * 0.6 ? WHITE : (inside > width * 0.3 ? GOLD : (h > 0.75 ? RED : ORANGE)));
	}
	// Les langues du sommet.
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		float x0 = (f - 1.0) * 0.32;
		float tip = top - (0.08 + hash(f) * 0.06) * fall;
		float k = clamp((y - tip) / max(top - tip, 0.001) , 0.0, 1.0);
		float tongue = 0.16 * (1.0 - (1.0 - k) * (1.0 - k)) - abs(x - x0 - sin(t * 30.0 + f) * 0.05);
		if (y > tip && y <= top + 0.01 && tongue > -0.04 && rise > 0.5) {
			color = tongue <= 0.0 ? RED : ORANGE;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
