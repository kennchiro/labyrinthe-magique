// LE MAÎTRE DU CASINO (l'Éveil du Croupier des Enfers) : la matière commune de ses effets. L'OR des jetons, l'or
// sombre qui les cerne, le BORDEAUX de son habit, le ROUGE VIF des cases, le NOIR et le BLANC des cartes, et le VERT du
// tapis. Net, à plages franches : un jeton est un disque d'or cranté, une carte un rectangle blanc cerné de noir.
// Jamais de rose : le rouge reste franc.

const vec3 K_GOLD = vec3(0.91, 0.76, 0.35);
const vec3 K_GOLD_DARK = vec3(0.6, 0.455, 0.125);
const vec3 K_WINE = vec3(0.48, 0.06, 0.08);
const vec3 K_RED = vec3(0.85, 0.12, 0.12);
const vec3 K_BLACK = vec3(0.08, 0.063, 0.07);
const vec3 K_WHITE = vec3(0.965, 0.94, 0.886);
const vec3 K_FELT = vec3(0.06, 0.36, 0.2);

float k_hash(float x, float s) {
	return fract(sin(x * 12.9898 + s * 78.233) * 43758.5453);
}

vec2 k_rot(vec2 q, float a) {
	float c = cos(a);
	float s = sin(a);
	return vec2(c * q.x - s * q.y, s * q.x + c * q.y);
}

// UN JETON d'or vu de face, de rayon `r`, cranté sur le bord. Vrai si dessus.
bool k_paint_chip(vec2 q, float r, inout vec3 color) {
	float d = length(q);
	if (d > r + 0.012) {
		return false;
	}
	if (d > r) {
		color = K_BLACK;
		return true;
	}
	float notch = step(0.5, fract(atan(q.y, q.x) * 8.0 / TAU));
	color = d > r * 0.72 ? (notch > 0.5 ? K_WHITE : K_GOLD) : (d > r * 0.6 ? K_GOLD_DARK : K_GOLD);
	return true;
}

// UNE CARTE vue de face, demi-largeur `w`, demi-hauteur `h`, dos rouge si `back`. Vrai si dessus.
bool k_paint_card(vec2 q, float w, float h, bool back, inout vec3 color) {
	float v = min(w - abs(q.x), h - abs(q.y));
	if (v < -0.012) {
		return false;
	}
	if (v <= 0.0) {
		color = K_BLACK;
		return true;
	}
	if (back) {
		color = v < w * 0.18 ? K_WHITE : (step(0.5, fract((q.x + q.y) * 18.0)) > 0.5 ? K_RED : K_WINE);
	} else {
		color = K_WHITE;
		float pip = 0.3 * w - length(q * vec2(1.0, 0.8));
		if (pip > 0.0) {
			color = K_RED;
		}
	}
	return true;
}
