// LE SEIGNEUR ÉCARLATE (l'Éveil du Chevalier Écarlate) : la matière commune de ses effets. Le BLANC chaud de ses
// coupes, l'ACIER, l'ÉCARLATE franc qui borde chaque trait, le rouge SOMBRE et le noir qui cerne. Une coupe est un
// trait blanc cerné de rouge puis de noir ; un pétale, une amande fendue. Jamais de rose : le rouge reste sans bleu.

const vec3 S_WHITE = vec3(1.0, 0.965, 0.933);
const vec3 S_STEEL = vec3(0.85, 0.87, 0.89);
const vec3 S_RED = vec3(0.722, 0.078, 0.078);
const vec3 S_BRIGHT = vec3(0.9, 0.1, 0.08);
const vec3 S_DARK = vec3(0.37, 0.04, 0.04);
const vec3 S_BLACK = vec3(0.09, 0.09, 0.1);

float s_hash(float x, float s) {
	return fract(sin(x * 12.9898 + s * 78.233) * 43758.5453);
}

vec2 s_rot(vec2 q, float a) {
	float c = cos(a);
	float s = sin(a);
	return vec2(c * q.x - s * q.y, s * q.x + c * q.y);
}

vec2 s_seg(vec2 q, vec2 a, vec2 b) {
	vec2 ab = b - a;
	float h = clamp(dot(q - a, ab) / max(dot(ab, ab), 1e-5), 0.0, 1.0);
	return vec2(length(q - a - ab * h), h);
}

// UNE COUPE peinte sur [a, b], effilée aux deux bouts : blanc, filet rouge, cerne noir. Vrai si dessus.
bool s_paint_cut(vec2 q, vec2 a, vec2 b, float w, inout vec3 color) {
	vec2 d = s_seg(q, a, b);
	float width = w * sin(clamp(d.y, 0.0, 1.0) * 3.14159);
	if (d.x > width + 0.016) {
		return false;
	}
	color = d.x > width + 0.008 ? S_BLACK : (d.x > width * 0.55 ? S_RED : S_WHITE);
	return true;
}

// UN PÉTALE en amande, fendu au bout, de taille `r`. Vrai si dessus : blanc bordé de rouge, ou rouge si `red`.
bool s_paint_petal(vec2 q, float r, bool red, inout vec3 color) {
	vec2 k = q / r;
	float body = 1.0 - length(vec2(k.x * 1.9, k.y));
	float notch = 0.18 - length(k - vec2(0.0, -1.0));
	float v = notch > 0.0 ? -1.0 : body;
	if (v < -0.18) {
		return false;
	}
	color = v <= 0.0 ? S_BLACK : (v < 0.3 ? S_RED : (red ? S_BRIGHT : S_WHITE));
	return true;
}
