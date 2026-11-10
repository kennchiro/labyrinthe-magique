// LE SEIGNEUR DES HEURES (l'Éveil du Chronomancien) : la matière commune de ses effets. Du SARCELLE profond,
// du sarcelle VIF qui brille, de l'OR et du CUIVRE, un blanc d'émail, cernés de brun très sombre. Le motif
// commun est le CADRAN : un anneau d'or gravé de douze heures, et des AIGUILLES de cuivre à pointe en losange.
// Des formes nettes, jamais de fumée floue. Aucun rose, aucun violet.

const vec3 H_RIM = vec3(0.10, 0.055, 0.03);
const vec3 H_DEEP = vec3(0.03, 0.16, 0.16);
const vec3 H_TEAL = vec3(0.078, 0.376, 0.369);
const vec3 H_BRIGHT = vec3(0.247, 0.878, 0.816);
const vec3 H_PALE = vec3(0.8, 1.0, 0.96);
const vec3 H_GOLD = vec3(0.878, 0.69, 0.29);
const vec3 H_LIGHT = vec3(1.0, 0.9, 0.6);
const vec3 H_COPPER = vec3(0.784, 0.455, 0.173);
const vec3 H_WHITE = vec3(0.957, 0.945, 0.91);

float h_hash(float x, float s) {
	return fract(sin(x * 12.9898 + s * 78.233) * 43758.5453);
}

vec2 h_rot(vec2 q, float a) {
	float c = cos(a);
	float s = sin(a);
	return vec2(c * q.x - s * q.y, s * q.x + c * q.y);
}

// LE CADRAN : un anneau de rayon `r` et de demi-épaisseur `w`, bordé d'or, gravé de douze heures qui tournent
// de `turn` (les quatre quarts plus grands, en or vif) et de soixante points de minutes. Vrai si le point est dessus.
bool h_dial(vec2 p, float r, float w, float turn, inout vec3 color) {
	float d = length(p);
	float band = w - abs(d - r);
	if (band < -0.012 || r <= 0.0) {
		return false;
	}
	if (band <= 0.0) {
		color = H_RIM;
		return true;
	}
	if (band < w * 0.24) {
		color = H_GOLD;
		return true;
	}
	color = H_TEAL;
	float ang = atan(p.y, p.x) + turn;
	float hours = fract(ang / TAU * 12.0 + 0.5) - 0.5;
	float hour = floor(ang / TAU * 12.0 + 0.5);
	bool quarter = mod(hour, 3.0) < 0.5;
	float across = (d - r) / w;
	float thick = quarter ? 0.16 : 0.08;
	if (abs(hours) < thick && abs(across) < (quarter ? 0.62 : 0.45)) {
		color = quarter ? H_LIGHT : H_COPPER;
		return true;
	}
	float minutes = fract(ang / TAU * 60.0 + 0.5) - 0.5;
	if (abs(minutes) < 0.18 && abs(across + 0.35) < 0.12) {
		color = H_BRIGHT;
	}
	return true;
}

// UNE AIGUILLE partie du centre vers l'angle `a` (0 = droite, -PI/2 = midi à l'écran), longue de `len`,
// large de `w`, à pointe en losange et contrepoids rond. > 0 dedans.
float h_hand(vec2 p, float a, float len, float w) {
	vec2 q = h_rot(p, -a);
	if (len <= 0.0) {
		return -1.0;
	}
	float k = q.x / len;
	float shaft = w * 0.45 - abs(q.y);
	float lozenge = w * 1.5 * (1.0 - abs(k - 0.78) / 0.22) - abs(q.y);
	// Le fût s'arrête avant la pointe : au-delà, `shaft` vaudrait une bande sans fin en travers.
	float body = (k > -0.12 && k < 1.0) ? max(k < 0.95 ? shaft : -1.0, lozenge) : -1.0;
	float weight = w * 1.1 - length(q + vec2(len * 0.12, 0.0));
	return max(body, weight);
}

// L'aiguille peinte : cernée de brun, or au cœur, éclat clair au fil. Vrai si le point est dessus.
bool h_paint_hand(float v, float w, inout vec3 color) {
	if (v < -0.012) {
		return false;
	}
	color = v <= 0.0 ? H_RIM : (v > w * 0.32 ? H_LIGHT : H_GOLD);
	return true;
}
