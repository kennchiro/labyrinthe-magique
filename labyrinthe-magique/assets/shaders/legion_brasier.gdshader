shader_type canvas_item;
render_mode blend_mix;

// L'IMPACT DE LA BOULE DE FEU : un éclair blanc, une couronne de douze langues de flamme qui jaillissent,
// une onde de feu qui part au sol, et des braises qui volent.

#include "res://assets/shaders/legion.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

const vec3 WHITE_HOT = vec3(1.0, 0.97, 0.82);
const vec3 SCORCH = vec3(0.29, 0.04, 0.02);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = L_EMBER;
	float a = 0.0;
	// L'onde de feu au sol.
	vec2 g = p * vec2(1.0, 1.7);
	float front = 0.15 + smoothstep(0.0, 0.7, t) * 0.8;
	float width = 0.09 * (1.0 - smoothstep(0.45, 0.9, t));
	float ring = width - abs(length(g) - front);
	if (ring > -0.02 && width > 0.0) {
		color = ring <= 0.0 ? SCORCH : (ring > width * 0.5 ? L_FLAME : L_EMBER);
		a = 1.0;
	}
	// La couronne de flammes.
	float grow = smoothstep(0.0, 0.25, t);
	float fall = 1.0 - smoothstep(0.45, 0.95, t);
	for (int i = 0; i < 12; i++) {
		float f = float(i);
		float ang = f / 12.0 * TAU + seed * 2.0;
		vec2 q = l_rot(p, -ang + 1.5708);
		float h = (0.55 + 0.3 * l_hash(f, seed)) * grow * fall;
		float tongue = l_flame(q - vec2(0.0, 0.1), 0.17, h);
		if (tongue > -0.02 && h > 0.02) {
			float k = q.y / max(0.01, h + 0.1);
			color = tongue <= 0.0 ? SCORCH : (tongue > 0.08 ? WHITE_HOT : (k > 0.6 ? L_BLOOD : (k > 0.35 ? L_EMBER : L_FLAME)));
			a = 1.0;
		}
	}
	// Le pied de la couronne reste en feu : les cernes des langues s'y croisaient en point noir.
	if (length(p) < 0.16 * grow * fall) {
		color = length(p) < 0.08 ? WHITE_HOT : L_FLAME;
		a = 1.0;
	}
	// Le cœur, éclair blanc qui retombe en braise.
	float core_r = 0.42 * (1.0 - smoothstep(0.0, 0.55, t));
	float core = core_r - length(p);
	// Un cœur presque éteint ne laisse pas son cerne en point noir.
	if (core > -0.025 && core_r > 0.06) {
		color = core <= 0.0 ? SCORCH : (core > 0.15 ? WHITE_HOT : L_FLAME);
		a = 1.0;
	}
	// Les braises qui volent.
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float dir = f / 10.0 * TAU + l_hash(f, seed + 1.0);
		vec2 c = vec2(cos(dir), sin(dir) * 0.7) * (0.2 + t * 0.75) - vec2(0.0, sin(t * 3.14) * 0.2);
		vec2 q = l_rot(p - c, t * 10.0 + f);
		float ember = 0.05 * (1.0 - t) - (abs(q.x) + abs(q.y));
		if (ember > -0.01) {
			color = ember <= 0.0 ? SCORCH : L_FLAME;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
