// LE MAÎTRE DES LÉGIONS (l'Éveil de l'Invocateur) : la matière commune de ses effets. Du violet sombre
// cerné de noir, des runes VIOLET VIF, un liseré d'OR, et le FEU du Roi-Dragon. Le motif commun est le
// SCEAU DE RUNES : un anneau violet gravé, bordé d'or. Des formes nettes, jamais de fumée floue.

const vec3 L_RIM = vec3(0.04, 0.02, 0.07);
const vec3 L_VOID = vec3(0.08, 0.04, 0.13);
const vec3 L_DEEP = vec3(0.18, 0.08, 0.31);
const vec3 L_VIOLET = vec3(0.78, 0.49, 1.0);
const vec3 L_PALE = vec3(0.95, 0.9, 1.0);
const vec3 L_GOLD = vec3(0.86, 0.67, 0.27);
const vec3 L_BONE = vec3(0.94, 0.9, 0.84);
const vec3 L_BLOOD = vec3(0.72, 0.08, 0.1);
const vec3 L_EMBER = vec3(1.0, 0.48, 0.1);
const vec3 L_FLAME = vec3(1.0, 0.84, 0.3);

float l_hash(float x, float s) {
	return fract(sin(x * 12.9898 + s * 78.233) * 43758.5453);
}

vec2 l_rot(vec2 q, float a) {
	float c = cos(a);
	float s = sin(a);
	return vec2(c * q.x - s * q.y, s * q.x + c * q.y);
}

// LE SCEAU : un anneau de rayon `r` et de demi-épaisseur `w`, bordé d'or, gravé de `slots` runes qui
// tournent de `turn`. Renvoie vrai et la couleur si le point est dessus.
bool l_seal(vec2 p, float r, float w, float turn, float slots, inout vec3 color) {
	float d = length(p);
	float band = w - abs(d - r);
	if (band < -0.012 || r <= 0.0) {
		return false;
	}
	if (band <= 0.0) {
		color = L_RIM;
		return true;
	}
	if (band < w * 0.22) {
		color = L_GOLD;
		return true;
	}
	color = L_DEEP;
	float ang = atan(p.y, p.x) + turn;
	float s = fract(ang / TAU * slots);
	float across = (d - r) / w;
	// Une rune : une barre verticale, et un trait qui la croise, différent d'une case à l'autre.
	float cell = floor(ang / TAU * slots);
	float kind = l_hash(cell, 3.1);
	bool bar = abs(s - 0.5) < 0.09 && abs(across) < 0.5;
	bool cross = abs(across - (kind - 0.5) * 0.6) < 0.12 && abs(s - 0.5) < 0.28;
	bool hook = kind > 0.5 && abs(s - 0.32) < 0.07 && across > 0.0 && across < 0.5;
	if (bar || cross || hook) {
		color = L_VIOLET;
	}
	return true;
}

// Une langue de flamme pointue vers +y local, de hauteur `h` et de base `w`. > 0 dedans.
float l_flame(vec2 q, float w, float h) {
	if (q.y < 0.0 || q.y > h || h <= 0.0) {
		return -1.0;
	}
	float k = q.y / h;
	return w * (1.0 - k) * (0.6 + 0.4 * sin(k * 3.14)) - abs(q.x + sin(k * 5.0) * w * 0.3 * k);
}
