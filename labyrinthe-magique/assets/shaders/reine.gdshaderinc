// LA REINE DE LA DISCORDE (l'Éveil de la Démone de la Discorde) : la matière commune de ses effets. Le MAGENTA de
// son élément, l'ARGENT de ses fils, l'ÉMERAUDE de son troisième œil, le vert sapin de son manteau et le noir qui
// cerne. Net, à plages franches : un fil est un trait cerné, un œil une amande cernée à pupille fendue.
// ⚠️ Ces couleurs ne vont que dans ses EFFETS : son sprite n'a ni rose ni violet (le détourage les détruit).

const vec3 R_BLACK = vec3(0.086, 0.102, 0.11);
const vec3 R_PINE = vec3(0.071, 0.275, 0.227);
const vec3 R_DEEP = vec3(0.416, 0.059, 0.29);
const vec3 R_MAGENTA = vec3(0.91, 0.188, 0.561);
const vec3 R_SILVER = vec3(0.788, 0.824, 0.839);
const vec3 R_PALE = vec3(0.94, 1.0, 0.97);
const vec3 R_EMERALD = vec3(0.184, 0.878, 0.627);
const vec3 R_JADE = vec3(0.04, 0.45, 0.32);

float r_hash(float x, float s) {
	return fract(sin(x * 12.9898 + s * 78.233) * 43758.5453);
}

vec2 r_rot(vec2 q, float a) {
	float c = cos(a);
	float s = sin(a);
	return vec2(c * q.x - s * q.y, s * q.x + c * q.y);
}

// La distance au segment [a, b] (x), et où l'on en est le long de lui (y : 0 en a, 1 en b).
vec2 r_seg(vec2 q, vec2 a, vec2 b) {
	vec2 ab = b - a;
	float h = clamp(dot(q - a, ab) / max(dot(ab, ab), 1e-5), 0.0, 1.0);
	return vec2(length(q - a - ab * h), h);
}

// Un FIL peint sur le segment [a, b] : cerné de noir, argent, cœur magenta si `core`. Vrai si dessus.
bool r_paint_thread(vec2 q, vec2 a, vec2 b, float w, bool core, inout vec3 color) {
	float d = r_seg(q, a, b).x;
	float rim = min(0.012, w * 0.9);
	if (d > w + rim) {
		return false;
	}
	color = d > w ? R_BLACK : (core && d < w * 0.45 ? R_MAGENTA : R_SILVER);
	return true;
}

// L'ŒIL : une amande de demi-largeur `size.x`, de demi-hauteur `size.y` ouverte à `open` (0 fermé, 1 ouvert).
// Cerné de noir, blanc pâle, iris émeraude, pupille noire fendue à la verticale. Vrai si dessus.
bool r_paint_eye(vec2 q, vec2 size, float open, inout vec3 color) {
	float x = q.x / size.x;
	if (abs(x) > 1.06) {
		return false;
	}
	float h = size.y * open * (1.0 - x * x);
	float v = h - abs(q.y);
	float rim = 0.016 + size.y * 0.06;
	if (v < -rim) {
		return false;
	}
	if (v <= 0.0 || open < 0.08) {
		color = R_BLACK;
		return true;
	}
	float iris = size.y * 0.82 - length(q);
	color = iris > 0.0 ? (iris > size.y * 0.25 ? R_EMERALD : R_JADE) : R_PALE;
	if (abs(q.x) < size.y * 0.13 * (1.0 - abs(q.y) / max(size.y, 0.001)) + 0.008 && iris > 0.0) {
		color = R_BLACK;
	}
	if (length(q - vec2(-size.y * 0.3, -size.y * 0.3)) < size.y * 0.16) {
		color = R_PALE;
	}
	return true;
}

// LA CROIX DE MARIONNETTISTE, de taille `s`, centrée sur son croisement : > 0 dedans.
float r_cross(vec2 q, float s) {
	float upright = min(s * 0.06 - abs(q.x), s * 0.55 - abs(q.y + s * 0.15));
	float bar = min(s * 0.5 - abs(q.x), s * 0.055 - abs(q.y));
	vec2 r = r_rot(q, 0.62);
	float diag = min(s * 0.42 - abs(r.x), s * 0.04 - abs(r.y));
	vec2 l = r_rot(q, -0.62);
	float diag2 = min(s * 0.42 - abs(l.x), s * 0.04 - abs(l.y));
	float knob = s * 0.07 - length(vec2(abs(q.x) - s * 0.5, q.y));
	return max(max(upright, bar), max(max(diag, diag2), knob));
}
