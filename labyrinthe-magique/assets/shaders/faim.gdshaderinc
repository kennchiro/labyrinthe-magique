// FAIM SANS FOND (l'Éveil de l'Avide) : la matière commune de ses effets. La BILE vert vif, la bile pâle, le VERT
// PROFOND, l'IVOIRE des crocs, l'ENCRE et la CHAIR SOMBRE des gorges. Net, à plages franches : un croc est un triangle
// ivoire cerné d'encre, une gueule un anneau de crocs autour d'une gorge sombre. Jamais de rose : la chair fonce vers
// le brun-noir.

const vec3 G_BILE = vec3(0.784, 0.91, 0.188);
const vec3 G_PALE = vec3(0.933, 0.969, 0.627);
const vec3 G_DEEP = vec3(0.29, 0.416, 0.063);
const vec3 G_IVORY = vec3(0.914, 0.886, 0.812);
const vec3 G_INK = vec3(0.067, 0.063, 0.078);
const vec3 G_FLESH = vec3(0.227, 0.078, 0.094);

float g_hash(float x, float s) {
	return fract(sin(x * 12.9898 + s * 78.233) * 43758.5453);
}

vec2 g_rot(vec2 q, float a) {
	float c = cos(a);
	float s = sin(a);
	return vec2(c * q.x - s * q.y, s * q.x + c * q.y);
}

// UNE GUEULE RONDE vue de dessus, de rayon `r`, ouverte à `open` (0 fermée, 1 béante) : un anneau d'encre bordé de
// `n` crocs ivoire pointés vers le centre, la gorge sombre au milieu. Vrai si dessus.
bool g_paint_maw(vec2 q, float r, float open, float n, inout vec3 color) {
	float d = length(q);
	if (d > r * 1.08) {
		return false;
	}
	float hole = r * mix(0.15, 0.72, open);
	float ang = atan(q.y, q.x);
	float tooth_t = abs(fract(ang * n / TAU) - 0.5) * 2.0;
	float tooth = (r * 0.86 - d) - (r * 0.86 - hole) * tooth_t;
	if (d > r) {
		color = G_INK;
		return true;
	}
	if (d > r * 0.86) {
		color = G_DEEP;
		return true;
	}
	if (tooth > 0.0) {
		color = tooth < r * 0.03 ? G_INK : G_IVORY;
		return true;
	}
	if (d < hole) {
		color = d < hole * 0.45 ? G_BILE : G_FLESH;
		return true;
	}
	color = G_INK;
	return true;
}

// UNE GOUTTE de bile, pointe vers le haut, de rayon `r` : > 0 dedans.
float g_drop(vec2 q, float r) {
	float round_part = r - length(q);
	float tip = r * 1.9;
	float cone = (q.y < 0.0 && q.y > -tip) ? (r * (1.0 + q.y / tip) * 0.95 - abs(q.x)) : -1.0;
	return max(round_part, cone);
}
