// LE SÉRAPHIN (l'Éveil de l'Archange du Ciel) : sa palette, L'AILE DE LUMIÈRE et LA LAME QUI TOMBE DU CIEL, les deux
// motifs de tous ses sorts. Blanc, or et émeraude. Jamais de rose ni de violet.

const vec3 S_WHITE = vec3(0.957, 0.969, 0.949);
const vec3 S_SHADE = vec3(0.788, 0.839, 0.8);
const vec3 S_GOLD = vec3(0.949, 0.757, 0.306);
const vec3 S_EMERALD = vec3(0.204, 0.878, 0.478);
const vec3 S_DEEP = vec3(0.122, 0.62, 0.353);
const vec3 S_CORE = vec3(1.0, 0.965, 0.847);
const vec3 S_RIM = vec3(0.063, 0.149, 0.11);

float s_hash(float a, float b) {
	return fract(sin(a * 127.1 + b * 311.7) * 43758.5453);
}

float s_glow(float d, float r) {
	return clamp(1.0 - d / max(0.001, r), 0.0, 1.0);
}

vec4 s_over(vec4 top, vec4 under) {
	float a = top.a + under.a * (1.0 - top.a);
	vec3 c = a > 0.0 ? (top.rgb * top.a + under.rgb * under.a * (1.0 - top.a)) / a : vec3(0.0);
	return vec4(c, a);
}

// L'AILE DE LUMIÈRE : un éventail de `n` plumes longues partant de `root`, tourné vers `dir` (radians), ouvert de
// `spread`, long de `len`. Retourne l'intensité (bord doré, cœur blanc).
vec4 s_wing(vec2 p, vec2 root, float dir, float spread, float len, int n, float alpha) {
	vec4 color = vec4(0.0);
	for (int i = 0; i < 6; i++) {
		if (i >= n) {
			break;
		}
		float f = float(i) / max(1.0, float(n - 1));
		float a = dir + (f - 0.5) * spread;
		vec2 d = vec2(cos(a), sin(a));
		vec2 q = p - root;
		float along = dot(q, d);
		float across = abs(dot(q, vec2(-d.y, d.x)));
		float l = len * (0.75 + 0.25 * sin(f * 3.14));
		float w = l * 0.13 * (1.0 - along / l) * smoothstep(0.0, l * 0.15, along);
		if (along > 0.0 && along < l && across < w + 0.01) {
			vec3 c = across > w ? S_RIM : (across > w * 0.55 ? S_GOLD : mix(S_WHITE, S_CORE, along / l));
			color = s_over(vec4(c, alpha), color);
		}
	}
	return color;
}

// LA LAME QUI TOMBE : une épée d'or, pointe en bas, centrée en `at`, longue de `len`.
vec4 s_sword(vec2 p, vec2 at, float len, float alpha) {
	vec2 q = p - at;
	float half_w = len * 0.12 * clamp((len * 0.5 - q.y) / len, 0.0, 1.0) + len * 0.01;
	float blade = step(-len * 0.3, q.y) * step(q.y, len * 0.5) * step(abs(q.x), half_w);
	float edge = step(-len * 0.31, q.y) * step(q.y, len * 0.51) * step(abs(q.x), half_w + len * 0.02);
	float guard = step(abs(q.y + len * 0.32), len * 0.03) * step(abs(q.x), len * 0.16);
	float grip = step(-len * 0.5, q.y) * step(q.y, -len * 0.33) * step(abs(q.x), len * 0.03);
	vec4 color = vec4(S_RIM, max(edge, max(guard, grip)) * alpha);
	color = s_over(vec4(mix(S_CORE, S_WHITE, abs(q.x) / max(0.001, half_w)), blade * alpha), color);
	color = s_over(vec4(S_GOLD, guard * alpha), color);
	color = s_over(vec4(S_GOLD, grip * alpha * 0.9), color);
	float gem = step(length(q - vec2(0.0, -len * 0.32)), len * 0.035);
	color = s_over(vec4(S_EMERALD, gem * alpha), color);
	return color;
}
