// LE SOUVERAIN DES VENTS (l'Éveil du Mage de l'Air) : la matière commune de ses effets. Du vent en formes
// nettes et cernées, jamais une brume floue : des croissants, des rubans, des spirales. Blanc au cœur,
// bleu ciel au bord, or pour ce qui marque le sol. JAMAIS de violet, et le blanc s'ombre de bleu-gris.

const vec3 S_RIM = vec3(0.106, 0.165, 0.227);
const vec3 S_DEEP = vec3(0.24, 0.55, 0.8);
const vec3 S_SKY = vec3(0.498, 0.827, 1.0);
const vec3 S_PALE = vec3(0.749, 0.89, 0.961);
const vec3 S_WHITE = vec3(0.965, 0.973, 0.984);
const vec3 S_SILVER = vec3(0.875, 0.906, 0.933);
const vec3 S_GOLD = vec3(0.878, 0.69, 0.251);

float s_hash(float x, float s) {
	return fract(sin(x * 12.9898 + s * 78.233) * 43758.5453);
}

vec2 s_rot(vec2 q, float a) {
	float c = cos(a);
	float s = sin(a);
	return vec2(c * q.x - s * q.y, s * q.x + c * q.y);
}

// Un ruban de vent : un arc de cercle de rayon `r`, de l'angle `a0` sur `span` radians, plus épais au
// milieu et effilé aux deux bouts. > 0 dedans. `rel` reçoit où l'on est le long de l'arc (0 à 1).
float s_arc(vec2 q, float r, float a0, float span, float w, out float rel) {
	float a = atan(q.y, q.x) - a0;
	a = mod(a + TAU, TAU);
	rel = a / max(span, 0.001);
	if (rel < 0.0 || rel > 1.0 || span <= 0.0) {
		return -1.0;
	}
	float taper = sin(rel * PI);
	return w * taper - abs(length(q) - r);
}

// Une spirale d'Archimède à `arms` bras, au pas `gap` : > 0 sur ses bras, épaisse de `w` (en part du
// pas), et seulement jusqu'au rayon `reach`.
float s_spiral(vec2 q, float gap, float arms, float w, float turn, float reach) {
	float r = length(q);
	if (r > reach) {
		return -1.0;
	}
	float a = (atan(q.y, q.x) + turn) / TAU;
	float f = fract(r / gap - a * arms);
	return w * 0.5 - abs(f - 0.5);
}

// Un croissant : le disque de centre 0 et de rayon `r`, moins un disque décalé de `bite` vers l'arrière.
float s_crescent(vec2 q, float r, float bite) {
	return min(r - length(q), length(q + vec2(bite, 0.0)) - r * 0.92);
}

// La teinte d'une forme de vent selon sa profondeur (inside / épaisseur).
vec3 s_wind(float depth) {
	return depth > 0.55 ? S_WHITE : (depth > 0.25 ? S_PALE : S_SKY);
}
