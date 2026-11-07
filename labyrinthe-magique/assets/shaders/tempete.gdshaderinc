// L'AVATAR DE LA TEMPÊTE (l'Éveil du Mage de la Foudre) : la matière commune de ses effets. Des éclairs
// en zigzag, nets et opaques : cœur blanc, bord bleu électrique, cerne bleu nuit. Le jaune est le sien
// (la Surtension, ses charges), l'or marque le sol. JAMAIS de violet : le fond des planches est magenta.

const vec3 T_RIM = vec3(0.043, 0.063, 0.133);
const vec3 T_NIGHT = vec3(0.106, 0.141, 0.251);
const vec3 T_BLUE_DEEP = vec3(0.11, 0.33, 0.75);
const vec3 T_BLUE = vec3(0.247, 0.663, 1.0);
const vec3 T_WHITE = vec3(0.957, 0.984, 1.0);
const vec3 T_YELLOW = vec3(0.949, 0.761, 0.188);
const vec3 T_GOLD = vec3(0.878, 0.69, 0.251);

float t_hash(float x, float s) {
	return fract(sin(x * 12.9898 + s * 78.233) * 43758.5453);
}

vec2 t_rot(vec2 q, float a) {
	float c = cos(a);
	float s = sin(a);
	return vec2(c * q.x - s * q.y, s * q.x + c * q.y);
}

// Un éclair en zigzag le long de +x, de 0 à `len`. > 0 dedans. `flick` change son tracé : on y passe
// un compteur qui avance une dizaine de fois par seconde, et l'éclair crépite.
float t_bolt(vec2 q, float len, float w, float amp, float s, float flick) {
	if (q.x < 0.0 || q.x > len || len <= 0.0) {
		return -1.0;
	}
	float seg = len / 7.0;
	float i = floor(q.x / seg);
	float f = fract(q.x / seg);
	float y0 = (t_hash(i + flick * 7.0, s) - 0.5) * amp * (i == 0.0 ? 0.0 : 1.0);
	float y1 = (t_hash(i + 1.0 + flick * 7.0, s) - 0.5) * amp * (i + 1.0 >= 7.0 ? 0.0 : 1.0);
	return w - abs(q.y - mix(y0, y1, f));
}

// La couleur d'un éclair selon la profondeur dans le trait (`inside / width`).
vec3 t_bolt_color(float depth) {
	return depth > 0.5 ? T_WHITE : (depth > 0.2 ? T_BLUE : T_BLUE_DEEP);
}

// Une étoile à `n` branches, > 0 dedans.
float t_star(vec2 q, float r, float n, float sharp) {
	float a = atan(q.y, q.x);
	return r * (0.35 + 0.65 * pow(abs(cos(a * n * 0.5)), sharp)) - length(q);
}
