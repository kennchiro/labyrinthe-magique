// LE COLOSSE (l'Éveil du Mage de la Terre) : la matière commune de ses effets. Roche brune à facettes,
// cristal vert, lave orange dans les fissures, cerne brun-noir. Le motif commun est la FISSURE DE LAVE.
// Tout est en aplats opaques et nets, comme ses sprites : aucune lueur floue.

const vec3 C_RIM = vec3(0.118, 0.078, 0.031);
const vec3 C_ROCK_DARK = vec3(0.259, 0.2, 0.125);
const vec3 C_ROCK = vec3(0.42, 0.337, 0.22);
const vec3 C_ROCK_LIGHT = vec3(0.604, 0.502, 0.345);
const vec3 C_DUST = vec3(0.741, 0.639, 0.475);
const vec3 C_CRYSTAL_DARK = vec3(0.157, 0.42, 0.09);
const vec3 C_CRYSTAL = vec3(0.435, 0.878, 0.227);
const vec3 C_GLOW = vec3(0.616, 1.0, 0.361);
const vec3 C_LAVA_DEEP = vec3(0.761, 0.255, 0.047);
const vec3 C_LAVA = vec3(1.0, 0.541, 0.118);
const vec3 C_LAVA_HOT = vec3(1.0, 0.827, 0.353);
const vec3 C_WHITE = vec3(1.0, 0.973, 0.855);

float c_hash(float x, float s) {
	return fract(sin(x * 12.9898 + s * 78.233) * 43758.5453);
}

vec2 c_rot(vec2 q, float a) {
	float c = cos(a);
	float s = sin(a);
	return vec2(c * q.x - s * q.y, s * q.x + c * q.y);
}

// Un rocher : un polygone irrégulier à sept facettes, > 0 dedans (distance au bord le plus proche).
float c_rock(vec2 q, float r, float s) {
	if (r <= 0.0) {
		return -1.0;
	}
	float k = 7.0;
	float a = atan(q.y, q.x);
	float sector = floor((a + PI) / TAU * k);
	float a0 = sector / k * TAU - PI;
	float a1 = (sector + 1.0) / k * TAU - PI;
	float r0 = r * (0.74 + 0.26 * c_hash(sector, s));
	float r1 = r * (0.74 + 0.26 * c_hash(mod(sector + 1.0, k), s));
	vec2 p0 = vec2(cos(a0), sin(a0)) * r0;
	vec2 p1 = vec2(cos(a1), sin(a1)) * r1;
	vec2 e = p1 - p0;
	vec2 n = normalize(vec2(e.y, -e.x));
	return -dot(q - p0, n);
}

// La teinte d'une facette de rocher : éclairée en haut à gauche, sombre en bas à droite.
vec3 c_rock_shade(vec2 q, float inside, float r) {
	float light = dot(normalize(q + vec2(0.0001)), vec2(-0.6, -0.8));
	vec3 color = light > 0.35 ? C_ROCK_LIGHT : (light > -0.3 ? C_ROCK : C_ROCK_DARK);
	// Le cœur garde la teinte moyenne : la facette ne se lit qu'au bord.
	if (inside > r * 0.45) {
		color = C_ROCK;
	}
	return color;
}

// Une fissure en zigzag, le long de +x à partir de l'origine. > 0 dedans.
float c_crack(vec2 q, float len, float w, float amp, float s) {
	if (q.x < 0.0 || q.x > len || len <= 0.0) {
		return -1.0;
	}
	float seg = len / 5.0;
	float i = floor(q.x / seg);
	float f = fract(q.x / seg);
	float y0 = (c_hash(i, s) - 0.5) * amp * (i == 0.0 ? 0.0 : 1.0);
	float y1 = (c_hash(i + 1.0, s) - 0.5) * amp;
	float centre = mix(y0, y1, f);
	float width = w * (1.0 - 0.75 * q.x / len);
	return width - abs(q.y - centre);
}

// Un pic de roche dressé : base sur y = 0, pointe vers le haut de l'écran (-y). > 0 dedans.
float c_spike(vec2 q, float h, float w) {
	if (h <= 0.0 || q.y > 0.0 || q.y < -h) {
		return -1.0;
	}
	return w * (1.0 + q.y / h) - abs(q.x);
}

// Un cristal taillé : pointe en haut (-y) à `h`, pied à `h * 0.35`. > 0 dedans.
float c_gem(vec2 q, float h, float w) {
	if (h <= 0.0 || q.y < -h || q.y > h * 0.35) {
		return -1.0;
	}
	float half_width = q.y < 0.0 ? w * (1.0 + q.y / h) : w * (1.0 - q.y / (h * 0.35));
	return half_width - abs(q.x);
}

// Les facettes d'un cristal : clair à gauche, vert au milieu, sombre à droite, un filet vif au centre.
vec3 c_gem_shade(vec2 q, float inside, float w) {
	vec3 color = q.x < -w * 0.15 ? C_GLOW : (q.x < w * 0.25 ? C_CRYSTAL : C_CRYSTAL_DARK);
	if (abs(q.x + w * 0.05) < w * 0.07 && q.y < 0.0) {
		color = C_WHITE;
	}
	return color;
}

// La couleur de la lave d'une fissure selon la profondeur dans le trait (`inside / width`).
vec3 c_lava(float depth, float heat) {
	vec3 color = depth > 0.55 ? C_LAVA_HOT : (depth > 0.25 ? C_LAVA : C_LAVA_DEEP);
	return mix(C_LAVA_DEEP * 0.6, color, heat);
}
