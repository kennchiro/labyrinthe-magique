// LE SEIGNEUR DU NÉANT (l'Éveil du Sorcier des Ténèbres) : la matière commune de ses effets. Du noir
// profond, cerné d'un liseré VIOLET VIF : sans lui, une forme noire disparaît sur un sol sombre. L'éclipse
// (un disque noir cerclé de violet) est le motif commun. Des formes nettes, jamais de fumée floue.

const vec3 N_RIM = vec3(0.04, 0.02, 0.07);
const vec3 N_VOID = vec3(0.07, 0.04, 0.11);
const vec3 N_DEEP = vec3(0.231, 0.114, 0.361);
const vec3 N_VIOLET = vec3(0.78, 0.49, 1.0);
const vec3 N_PALE = vec3(0.96, 0.925, 1.0);
const vec3 N_SILVER = vec3(0.79, 0.8, 0.84);

float n_hash(float x, float s) {
	return fract(sin(x * 12.9898 + s * 78.233) * 43758.5453);
}

vec2 n_rot(vec2 q, float a) {
	float c = cos(a);
	float s = sin(a);
	return vec2(c * q.x - s * q.y, s * q.x + c * q.y);
}

// Une spirale à `arms` bras, au pas `gap`, épaisse de `w` (en part du pas), jusqu'au rayon `reach`.
float n_spiral(vec2 q, float gap, float arms, float w, float turn, float reach) {
	float r = length(q);
	if (r > reach) {
		return -1.0;
	}
	float a = (atan(q.y, q.x) + turn) / TAU;
	float f = fract(r / gap - a * arms);
	return w * 0.5 - abs(f - 0.5);
}

// Une vrille : un ruban qui ondule le long de +x, de 0 à `len`, effilé vers sa pointe. > 0 dedans.
float n_tendril(vec2 q, float len, float w, float wave, float s) {
	if (q.x < 0.0 || q.x > len || len <= 0.0) {
		return -1.0;
	}
	float k = q.x / len;
	float centre = sin(k * 6.0 + s * 4.0) * wave * k;
	return w * (1.0 - k * 0.85) - abs(q.y - centre);
}

// L'ÉCLIPSE : un disque noir cerclé d'un anneau violet, cœur pâle sur le bord intérieur. Renvoie la
// couleur dans `color` et vrai si le point est dessus.
bool n_eclipse(vec2 q, float r, inout vec3 color) {
	float d = length(q);
	if (d > r * 1.22) {
		return false;
	}
	if (d > r * 1.15) {
		color = N_RIM;
	} else if (d > r) {
		color = d < r * 1.05 ? N_PALE : N_VIOLET;
	} else {
		color = N_VOID;
	}
	return true;
}
