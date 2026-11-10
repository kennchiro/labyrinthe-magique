// LA REINE DU FIRMAMENT (l'Éveil de l'Ange des Étoiles) : sa palette, L'ÉTOILE À QUATRE BRANCHES et LE RAYON
// D'ARGENT qui relie deux étoiles, les deux motifs de tous ses sorts. Bleu nuit, argent, blanc, or pâle en touches.
// Jamais de violet, de rose ni de vert.

const vec3 R_NIGHT = vec3(0.078, 0.114, 0.29);
const vec3 R_DEEP = vec3(0.047, 0.071, 0.212);
const vec3 R_SILVER = vec3(0.784, 0.831, 0.91);
const vec3 R_SHINE = vec3(0.957, 0.969, 1.0);
const vec3 R_BLUE = vec3(0.616, 0.722, 1.0);
const vec3 R_GOLD = vec3(1.0, 0.886, 0.627);
const vec3 R_RIM = vec3(0.027, 0.039, 0.11);

float r_hash(float a, float b) {
	return fract(sin(a * 127.1 + b * 311.7) * 43758.5453);
}

float r_glow(float d, float r) {
	return clamp(1.0 - d / max(0.001, r), 0.0, 1.0);
}

vec4 r_over(vec4 top, vec4 under) {
	float a = top.a + under.a * (1.0 - top.a);
	vec3 c = a > 0.0 ? (top.rgb * top.a + under.rgb * under.a * (1.0 - top.a)) / a : vec3(0.0);
	return vec4(c, a);
}

vec2 r_turn(vec2 v, float a) {
	return vec2(v.x * cos(a) - v.y * sin(a), v.x * sin(a) + v.y * cos(a));
}

// Positif dans l'étoile à quatre branches de taille `size` (même dessin que l'Ange des Étoiles).
float r_star_field(vec2 v, float size) {
	return size - pow(pow(abs(v.x), 0.6) + pow(abs(v.y), 0.6), 1.67);
}

// L'ÉTOILE : blanche à cœur d'or pâle, cernée de nuit, tournée de `turn`.
vec4 r_star(vec2 p, float size, float turn, float alpha) {
	float heat = r_star_field(r_turn(p, turn), size);
	if (heat < -size * 0.08) {
		return vec4(0.0);
	}
	vec3 c = mix(R_BLUE, R_SHINE, smoothstep(0.0, size * 0.12, heat));
	c = mix(c, R_GOLD, smoothstep(size * 0.25, size * 0.6, heat));
	c = mix(R_RIM, c, smoothstep(-size * 0.08, 0.0, heat));
	return vec4(c, alpha);
}

float r_segment(vec2 p, vec2 a, vec2 b) {
	vec2 ab = b - a;
	return length(p - a - ab * clamp(dot(p - a, ab) / max(0.0001, dot(ab, ab)), 0.0, 1.0));
}

// LE RAYON D'ARGENT entre `a` et `b`, épais de `w`, à cœur blanc.
vec4 r_ray(vec2 p, vec2 a, vec2 b, float w, float alpha) {
	float d = r_segment(p, a, b);
	if (d > w * 1.6) {
		return vec4(0.0);
	}
	vec3 c = d < w * 0.4 ? R_SHINE : (d < w ? R_SILVER : R_BLUE);
	return vec4(c, alpha * (d < w ? 1.0 : 0.5));
}

// Les cinq sommets d'une étoile tracée au sol, de rayon `r`, tournée de `turn`.
vec2 r_point(int i, float r, float turn) {
	float a = turn - PI * 0.5 + float(i) * TAU / 5.0;
	return vec2(cos(a), sin(a)) * r;
}
