// LE GARDIEN DE L'ABÎME (l'Éveil du Geôlier) : la matière commune de ses effets. Le PÂLE glacé au cœur, le CYAN de sa
// flamme froide, le PROFOND, le gris-bleu de ses MAILLONS, l'OBSIDIENNE qui cerne et le NOIR D'ABÎME de son Extra.
// Net, à plages franches : un maillon est un anneau oblong cerné, une serrure un trou noir cerclé de fer.
// Jamais de rose ni de violet : le froid fonce vers le bleu-noir.

const vec3 A_PALE = vec3(0.9, 0.99, 1.0);
const vec3 A_CYAN = vec3(0.086, 0.878, 0.91);
const vec3 A_DEEP = vec3(0.04, 0.435, 0.478);
const vec3 A_LINK = vec3(0.56, 0.72, 0.75);
const vec3 A_OBSIDIAN = vec3(0.078, 0.094, 0.12);
const vec3 A_VOID = vec3(0.012, 0.02, 0.035);

float a_hash(float x, float s) {
	return fract(sin(x * 12.9898 + s * 78.233) * 43758.5453);
}

vec2 a_rot(vec2 q, float a) {
	float c = cos(a);
	float s = sin(a);
	return vec2(c * q.x - s * q.y, s * q.x + c * q.y);
}

// UN MAILLON couché le long de x, de demi-longueur `l` et de demi-largeur `w` : > 0 sur l'anneau.
float a_link(vec2 q, float l, float w) {
	vec2 d = vec2(max(abs(q.x) - (l - w), 0.0), q.y);
	return w * 0.32 - abs(length(d) - w * 0.68);
}

// Le maillon peint : liseré clair, cerne d'obsidienne. Vrai si dessus.
bool a_paint_link(vec2 q, float l, float w, inout vec3 color) {
	float v = a_link(q, l, w);
	if (v < -0.012) {
		return false;
	}
	color = v <= 0.0 ? A_OBSIDIAN : (v > w * 0.16 ? A_PALE : A_LINK);
	return true;
}

// UNE CHAÎNE de maillons alternés sur [a, b], de pas `step`. Vrai si dessus.
bool a_paint_chain(vec2 q, vec2 a, vec2 b, float w, inout vec3 color) {
	vec2 ab = b - a;
	float len = length(ab);
	if (len < 1e-4) {
		return false;
	}
	vec2 dir = ab / len;
	vec2 local = vec2(dot(q - a, dir), dot(q - a, vec2(-dir.y, dir.x)));
	if (local.x < -w || local.x > len + w || abs(local.y) > w * 1.2) {
		return false;
	}
	float step_len = w * 2.6;
	float k = floor(local.x / step_len + 0.5);
	vec2 c = vec2(local.x - k * step_len, local.y);
	if (mod(k, 2.0) > 0.5) {
		c = vec2(c.x, c.y * 2.2);
	}
	return a_paint_link(c, w * 1.5, w, color);
}

// LE TROU DE SERRURE, de taille `s` : > 0 dedans.
float a_keyhole(vec2 q, float s) {
	float head = s * 0.45 - length(q + vec2(0.0, s * 0.35));
	float foot = min(s * (0.22 + 0.3 * clamp((q.y + s * 0.2) / s, 0.0, 1.0)) - abs(q.x),
		min(q.y + s * 0.3, s * 0.75 - q.y));
	return max(head, foot);
}

// UN CRISTAL DE GLACE en losange étiré : > 0 dedans.
float a_shard(vec2 q, float w, float h) {
	return 1.0 - abs(q.x) / w - abs(q.y) / h;
}
