// LE GARDIEN DU TRÔNE (l'Éveil du Chérubin) : sa palette, L'ŒIL D'OR à iris saphir et LA FLAMME SAPHIR, les deux
// motifs de tous ses sorts. Le saphir reste un bleu franc : jamais de violet, de rose ni de vert.

const vec3 E_SAPPHIRE = vec3(0.239, 0.42, 1.0);
const vec3 E_DEEP = vec3(0.165, 0.31, 0.84);
const vec3 E_CORE = vec3(0.863, 0.902, 1.0);
const vec3 E_GOLD = vec3(0.949, 0.757, 0.306);
const vec3 E_BRONZE = vec3(0.788, 0.51, 0.18);
const vec3 E_RIM = vec3(0.078, 0.102, 0.18);

float e_hash(float a, float b) {
	return fract(sin(a * 127.1 + b * 311.7) * 43758.5453);
}

float e_glow(float d, float r) {
	return clamp(1.0 - d / max(0.001, r), 0.0, 1.0);
}

vec4 e_over(vec4 top, vec4 under) {
	float a = top.a + under.a * (1.0 - top.a);
	vec3 c = a > 0.0 ? (top.rgb * top.a + under.rgb * under.a * (1.0 - top.a)) / a : vec3(0.0);
	return vec4(c, a);
}

// LA FLAMME : du bleu profond au cœur presque blanc, selon `h` (0 bord, 1 cœur).
vec3 e_flame(float h) {
	vec3 c = mix(E_DEEP, E_SAPPHIRE, smoothstep(0.1, 0.5, h));
	return mix(c, E_CORE, smoothstep(0.6, 0.95, h));
}

// L'ŒIL : une amande d'or cernée, à iris saphir et pupille sombre, ouverte de `open` (0 fermé, 1 ouvert), large de
// `size`. Calme, jamais inquiétant.
vec4 e_eye(vec2 p, float size, float open, float alpha) {
	vec2 q = p / size;
	float lid = max(0.02, open * 0.55);
	float almond = abs(q.y) - lid * (1.0 - q.x * q.x);
	if (abs(q.x) > 1.05 || almond > 0.09) {
		return vec4(0.0);
	}
	vec3 c = almond > 0.0 ? E_RIM : E_GOLD;
	if (almond <= 0.0) {
		float iris = length(q);
		c = iris < 0.4 * open ? (iris < 0.17 * open ? E_RIM : E_SAPPHIRE) : vec3(1.0, 0.97, 0.88);
	}
	return vec4(c, alpha);
}

// LA LANGUE DE FLAMME debout en `p`, haute de `h`, qui ondule avec `t`.
float e_tongue(vec2 p, float h, float t, float seed) {
	float y = clamp(-p.y / h, 0.0, 1.0);
	float sway = sin(y * 6.0 + t * 7.0 + seed) * 0.06 * y * h;
	float width = h * 0.28 * (1.0 - y) * (0.4 + 0.6 * sqrt(y + 0.1));
	return step(-h, p.y) * step(p.y, 0.0) * smoothstep(width, width * 0.6, abs(p.x - sway));
}
