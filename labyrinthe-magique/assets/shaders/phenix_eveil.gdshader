shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLOSION DU PHÉNIX : deux immenses ailes de flammes s'ouvrent d'un coup, plume par plume, une
// colonne de feu monte derrière lui, puis les ailes se replient en se consumant.

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
	float open = smoothstep(0.0, 0.22, t);
	float fold = 1.0 - smoothstep(0.6, 1.0, t);
	// La colonne, derrière.
	float column = (0.22 * fold * open - abs(p.x + sin(p.y * 10.0 + t * 30.0) * 0.03));
	if (column > -0.03 && p.y < 0.3 && p.y > -1.0 + 0.0 * t) {
		color = column <= 0.0 ? RED : (column > 0.1 ? WHITE : GOLD);
		a = 1.0;
	}
	// Deux ailes de sept plumes chacune.
	vec2 shoulder = vec2(0.0, 0.05);
	for (int s = 0; s < 2; s++) {
		float sgn = s == 0 ? 1.0 : -1.0;
		for (int i = 0; i < 7; i++) {
			float f = float(i);
			float angle = mix(1.8, -1.25 + f * 0.36, open);
			vec2 dir = vec2(cos(angle) * sgn, sin(angle));
			float len = (0.92 - abs(f - 2.0) * 0.06) * fold * smoothstep(0.0, 0.18, t);
			vec2 q = p - shoulder;
			vec2 l = vec2(dot(q, dir) - len * 0.5, dot(q, vec2(-dir.y, dir.x)));
			float fl = feather(l, len * 0.5, 0.11 * fold);
			if (fl > -0.03 && fold > 0.0 && len > 0.02) {
				float k = dot(q, dir) / max(len, 0.001);
				color = fl <= 0.0 ? RIM : (k < 0.35 ? WHITE : (k < 0.7 ? GOLD : (fl > 0.03 ? ORANGE : RED)));
				a = 1.0;
			}
		}
	}
	// L'anneau d'or au sol.
	vec2 g = vec2(p.x, (p.y - 0.62) * 3.0);
	float ring = 0.06 * (1.0 - smoothstep(0.4, 1.0, t)) - abs(length(g) - (0.2 + 0.75 * smoothstep(0.0, 0.5, t)));
	if (ring > -0.02) {
		color = ring <= 0.0 ? RIM : GOLD;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
