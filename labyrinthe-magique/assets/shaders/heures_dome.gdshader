shader_type canvas_item;
render_mode blend_mix;

// LE DÔME DE STASE, la zone : un dôme de verre sarcelle cerclé d'un cadran d'or. Une trotteuse y balaie le sol
// au ralenti, des éclats de temps figé y scintillent sans bouger, un reflet blanc court sur le verre. Le bord
// tombe sur le rayon du sort. Il clignote à la fin, pour dire qu'il va céder.

#include "res://assets/shaders/heures.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float radius_tiles = 3.0;
uniform float seed = 0.0;
uniform float phase = 0.0;
uniform float life = 1.0;
uniform float aura = 0.0;

const float EDGE = 0.8;

float hash2(vec2 c) {
	return fract(sin(dot(c, vec2(12.9898, 78.233)) + seed * 37.7) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float grow = 1.0 - pow(1.0 - clamp(phase / 0.35, 0.0, 1.0), 3.0);
	float reach = EDGE * grow;
	float inside = (d > reach + 0.1 || reach <= 0.0) ? 0.0 : 1.0;
	float k = d / max(reach, 0.001);
	// Le verre : clair au milieu, plus dense vers le bord.
	vec3 color = mix(H_TEAL, H_BRIGHT, pow(k, 3.0) * 0.6);
	float a = d < reach ? 0.14 + pow(k, 4.0) * 0.32 : 0.0;
	// Les anneaux d'heures intérieurs, très pâles.
	float inner = 0.012 - abs(d - reach * 0.55);
	if (inner > 0.0) {
		color = H_BRIGHT;
		a = 0.35;
	}
	// La trotteuse : un éventail de lumière qui balaie le sol, lentement.
	float sweep = fract((atan(p.y, p.x) - phase * 0.5 + seed) / TAU);
	if (d < reach * 0.95 && sweep > 0.88) {
		color = mix(color, H_PALE, (sweep - 0.88) / 0.12 * 0.8);
		a = max(a, (sweep - 0.88) / 0.12 * 0.45);
	}
	float hand = h_hand(p, phase * 0.5 + seed + PI, reach * 0.9, 0.028);
	if (h_paint_hand(hand, 0.028, color)) {
		a = 0.95;
	}
	// Les éclats de temps figé : ils brillent sur place, ils ne bougent pas.
	vec2 at = p * radius_tiles * 2.2 + seed;
	vec2 cell = floor(at);
	vec2 centre = vec2(hash2(cell), hash2(cell + 7.0)) * 0.6 + 0.2;
	float lit = step(0.84, hash2(cell + 13.0)) * step(d, reach * 0.92);
	vec2 off = abs(fract(at) - centre);
	float star = 0.16 - (off.x + off.y) * 1.6 - min(off.x, off.y) * 6.0;
	if (lit > 0.0 && star > 0.0) {
		float twinkle = 0.6 + 0.4 * sin(phase * 2.5 + hash2(cell + 3.0) * 6.28);
		color = mix(H_BRIGHT, H_WHITE, twinkle);
		a = max(a, twinkle);
	}
	// Le reflet du verre, en haut à gauche.
	float glint = 0.035 - abs(d - reach * 0.78);
	float side = atan(p.y, p.x);
	if (glint > 0.0 && side < -1.9 && side > -2.8) {
		color = H_WHITE;
		a = max(a, 0.6);
	}
	// Le cadran d'or du bord.
	vec3 dial = color;
	if (h_dial(p, reach - 0.05, 0.05, 0.0, dial)) {
		color = dial;
		a = 1.0;
	}
	float blink = life < 0.15 ? 0.55 + 0.45 * step(0.5, fract(phase * 4.0)) : 1.0;
	COLOR = vec4(color, a * blink * smoothstep(0.0, 0.04, life) * inside);
}
