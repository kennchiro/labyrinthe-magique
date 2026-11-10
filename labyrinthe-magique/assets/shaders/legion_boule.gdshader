shader_type canvas_item;
render_mode blend_mix;

// LA BOULE DE FEU DU ROI-DRAGON, le projectile : un cœur blanc-jaune qui bouillonne, cerné d'orange et de
// rouge, et une crinière de sept langues de flamme qui fouettent derrière lui. UV.x va de la queue (0)
// à la pointe (1).

#include "res://assets/shaders/legion.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;

const float LENGTH = 1.9;
const vec3 WHITE_HOT = vec3(1.0, 0.97, 0.82);
const vec3 SCORCH = vec3(0.29, 0.04, 0.02);

vec3 heat(float k) {
	// k = 0 au cœur, 1 au bord.
	return k < 0.3 ? WHITE_HOT : (k < 0.55 ? L_FLAME : (k < 0.8 ? L_EMBER : L_BLOOD));
}

void fragment() {
	vec2 p = vec2((UV.x - 0.72) * LENGTH, UV.y - 0.5);
	vec3 color = L_BLOOD;
	float a = 0.0;
	// La crinière : sept langues qui partent vers l'arrière en ondulant.
	for (int i = 0; i < 7; i++) {
		float f = float(i);
		float y0 = (f - 3.0) * 0.07;
		float len = 0.95 - abs(f - 3.0) * 0.14 + 0.08 * sin(TIME * 11.0 + f * 1.7 + seed * 5.0);
		float x = -p.x;
		if (x > -0.05 && x < len) {
			float k = clamp(x / len, 0.0, 1.0);
			float centre = y0 * (1.0 + k * 1.6) + sin(k * 7.0 - TIME * 16.0 + f) * 0.05 * k;
			float w = 0.16 * (1.0 - k) * (1.0 - abs(f - 3.0) * 0.12);
			float d = w - abs(p.y - centre);
			if (d > -0.014) {
				float layer = 1.0 - d / max(0.001, w);
				color = d <= 0.0 ? SCORCH : heat(clamp(layer * 0.6 + k * 0.6, 0.0, 1.0));
				a = 1.0;
			}
		}
	}
	// Des braises qui s'arrachent derrière.
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		float x = -0.35 - fract(TIME * 2.2 + f * 0.19 + seed) * 0.6;
		vec2 c = vec2(x, (l_hash(f, seed) - 0.5) * 0.55);
		vec2 q = l_rot(p - c, TIME * 6.0 + f);
		float ember = 0.035 - (abs(q.x) + abs(q.y));
		if (ember > -0.008) {
			color = ember <= 0.0 ? SCORCH : L_FLAME;
			a = 1.0;
		}
	}
	// Le cœur, au bord qui bouillonne.
	float ang = atan(p.y, p.x);
	float r = 0.31 + 0.035 * sin(ang * 7.0 + TIME * 14.0 + seed * 9.0) + 0.02 * sin(ang * 13.0 - TIME * 9.0);
	float d = length(p * vec2(0.92, 1.0));
	if (d < r + 0.02) {
		color = d > r ? SCORCH : heat(d / r);
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
