// LE DRAGON PRIMORDIAL (l'Éveil du Dragon des Abysses) : la matière commune de ses effets. Le CŒUR blanc chaud, le
// magma JAUNE, le MAGMA orange, le ROUGE SANG, l'OBSIDIENNE qui cerne et la FUMÉE. Net, à plages franches : une flamme
// est une langue cernée d'obsidienne, une coulée un trait jaune à bord orange. Jamais d'or ni de blanc froid : ce
// n'est pas le Dragon d'or d'Aël, et jamais de rose.

const vec3 P_CORE = vec3(1.0, 0.945, 0.75);
const vec3 P_YELLOW = vec3(1.0, 0.89, 0.416);
const vec3 P_MAGMA = vec3(1.0, 0.353, 0.063);
const vec3 P_BLOOD = vec3(0.54, 0.086, 0.047);
const vec3 P_OBSIDIAN = vec3(0.11, 0.07, 0.063);
const vec3 P_SMOKE = vec3(0.227, 0.18, 0.165);

float p_hash(float x, float s) {
	return fract(sin(x * 12.9898 + s * 78.233) * 43758.5453);
}

vec2 p_rot(vec2 q, float a) {
	float c = cos(a);
	float s = sin(a);
	return vec2(c * q.x - s * q.y, s * q.x + c * q.y);
}

// UNE LANGUE DE FLAMME qui monte (vers -y), base en (0,0), largeur `w`, hauteur `h`. > 0 dedans.
float p_tongue(vec2 q, float w, float h) {
	if (q.y > w * 0.6 || q.y < -h) {
		return -1.0;
	}
	float k = clamp(-q.y / h, 0.0, 1.0);
	float width = w * (1.0 - k * k) * (0.75 + 0.25 * sin(k * 3.14159));
	float bottom = w * 0.6 - length(vec2(q.x, max(q.y, 0.0)));
	return max(width - abs(q.x + sin(k * 5.0 + TIME * 8.0) * w * 0.3 * k), q.y > 0.0 ? bottom : -1.0);
}

// La flamme peinte : cernée d'obsidienne, rouge sang au bord, magma, jaune, cœur blanc chaud. Vrai si dessus.
bool p_paint_tongue(vec2 q, float w, float h, inout vec3 color) {
	float v = p_tongue(q, w, h);
	if (v < -0.014) {
		return false;
	}
	color = v <= 0.0 ? P_OBSIDIAN : (v > w * 0.62 ? P_CORE : (v > w * 0.38 ? P_YELLOW : (v > w * 0.14 ? P_MAGMA : P_BLOOD)));
	return true;
}

// UNE ÉCLAT D'OBSIDIENNE en losange : > 0 dedans.
float p_shard(vec2 q, float w, float h) {
	return 1.0 - abs(q.x) / w - abs(q.y) / h;
}
