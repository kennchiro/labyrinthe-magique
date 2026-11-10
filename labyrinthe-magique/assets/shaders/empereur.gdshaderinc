// L'EMPEREUR DES CENDRES (l'Éveil du Roi de Braise) : la matière commune de ses effets. La BRAISE orange, la LAVE plus
// rouge, le PÂLE au cœur, l'OR VIEILLI de sa couronne, la CENDRE grise et le noir qui cerne. Net, à plages franches :
// une flamme est une langue cernée, une cendre un éclat gris qui tombe. Jamais de rose : la lave fonce vers le brun.

const vec3 E_BLACK = vec3(0.07, 0.05, 0.035);
const vec3 E_DEEP = vec3(0.55, 0.12, 0.03);
const vec3 E_LAVA = vec3(1.0, 0.35, 0.06);
const vec3 E_EMBER = vec3(1.0, 0.6, 0.12);
const vec3 E_PALE = vec3(1.0, 0.85, 0.63);
const vec3 E_GOLD = vec3(0.72, 0.525, 0.17);
const vec3 E_ASH = vec3(0.29, 0.25, 0.22);
const vec3 E_ASH_LIGHT = vec3(0.55, 0.5, 0.45);

float e_hash(float x, float s) {
	return fract(sin(x * 12.9898 + s * 78.233) * 43758.5453);
}

vec2 e_rot(vec2 q, float a) {
	float c = cos(a);
	float s = sin(a);
	return vec2(c * q.x - s * q.y, s * q.x + c * q.y);
}

vec2 e_seg(vec2 q, vec2 a, vec2 b) {
	vec2 ab = b - a;
	float h = clamp(dot(q - a, ab) / max(dot(ab, ab), 1e-5), 0.0, 1.0);
	return vec2(length(q - a - ab * h), h);
}

// UNE LANGUE DE FLAMME qui monte (vers -y), base en (0,0), largeur `w`, hauteur `h`. > 0 dedans.
float e_tongue(vec2 q, float w, float h) {
	if (q.y > w * 0.6 || q.y < -h) {
		return -1.0;
	}
	float k = clamp(-q.y / h, 0.0, 1.0);
	float width = w * (1.0 - k * k) * (0.7 + 0.3 * sin(k * 3.14159));
	float bottom = w * 0.6 - length(vec2(q.x, max(q.y, 0.0)));
	return max(width - abs(q.x + sin(k * 6.0 + TIME * 9.0) * w * 0.25 * k), q.y > 0.0 ? bottom : -1.0);
}

// La flamme peinte : cernée de noir, lave au bord, braise, cœur pâle. Vrai si dessus.
bool e_paint_tongue(vec2 q, float w, float h, inout vec3 color) {
	float v = e_tongue(q, w, h);
	if (v < -0.014) {
		return false;
	}
	color = v <= 0.0 ? E_BLACK : (v > w * 0.55 ? E_PALE : (v > w * 0.25 ? E_EMBER : E_LAVA));
	return true;
}

// UN ÉCLAT EN LOSANGE, comme les pointes de son anneau : > 0 dedans.
float e_spike(vec2 q, float w, float h) {
	return 1.0 - abs(q.x) / w - abs(q.y) / h;
}
