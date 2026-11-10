// L'ÉTOILE DU MATIN (l'Éveil du Porte-Lumière) : sa palette, et L'ÉTOILE À HUIT BRANCHES, le motif commun de tous
// ses sorts. Tout ce qui frappe est une ligne de lumière nette : jamais de rose ni de violet, et le blanc garde des
// reflets bleu ciel pour ne pas virer au jaune.

uniform sampler2D noise : repeat_enable, filter_linear;

const vec3 A_WHITE = vec3(1.0, 0.98, 0.94);
const vec3 A_GOLD = vec3(0.91, 0.72, 0.29);
const vec3 A_GOLD_LIGHT = vec3(1.0, 0.945, 0.72);
const vec3 A_SUN = vec3(1.0, 0.83, 0.47);
const vec3 A_SKY = vec3(0.875, 0.953, 1.0);
const vec3 A_RIM = vec3(0.23, 0.14, 0.06);

float a_hash(float a, float b) {
	return fract(sin(a * 127.1 + b * 311.7) * 43758.5453);
}

float a_glow(float d, float r) {
	return clamp(1.0 - d / max(0.001, r), 0.0, 1.0);
}

vec4 a_over(vec4 top, vec4 under) {
	float a = top.a + under.a * (1.0 - top.a);
	vec3 c = a > 0.0 ? (top.rgb * top.a + under.rgb * under.a * (1.0 - top.a)) / a : vec3(0.0);
	return vec4(c, a);
}

// L'ÉTOILE À HUIT BRANCHES de rayon `r`, tournée de `turn` : 1 dedans, 0 dehors, bord net. Les quatre grandes
// branches portent le rayon entier, les quatre petites la moitié.
float a_star(vec2 p, float r, float turn) {
	// Une ROSE DES VENTS : seize secteurs, une pointe tous les deux, un creux entre deux pointes. Le rayon passe en
	// ligne droite de l'une à l'autre : des branches pointues, jamais des pétales.
	float d = length(p);
	float s = fract((atan(p.y, p.x) - turn) / TAU) * 16.0;
	float i = floor(s);
	float f = s - i;
	float here = mod(i, 2.0) < 0.5 ? (mod(i, 4.0) < 0.5 ? 1.0 : 0.55) : 0.24;
	float next_i = mod(i + 1.0, 16.0);
	float there = mod(next_i, 2.0) < 0.5 ? (mod(next_i, 4.0) < 0.5 ? 1.0 : 0.55) : 0.24;
	float reach = r * mix(here, there, f);
	return smoothstep(reach, reach * 0.93, d);
}

// L'étoile peinte : bord or foncé, corps or, cœur blanc.
vec4 a_star_paint(vec2 p, float r, float turn, float alpha) {
	float body = a_star(p, r, turn);
	float core = a_star(p, r * 0.6, turn);
	vec3 c = mix(A_GOLD, A_WHITE, core);
	float rim = body - a_star(p, r * 0.92, turn);
	c = mix(c, A_RIM, clamp(rim, 0.0, 1.0) * 0.8);
	return vec4(c, body * alpha);
}

// Un rayon droit le long de x : cœur blanc, frange d'or. `y` est la distance au fil, entre 0 et 1.
vec4 a_beam(float y, float width, float alpha) {
	float core = clamp(1.0 - y / max(0.01, width * 0.35), 0.0, 1.0);
	float body = clamp(1.0 - y / max(0.01, width), 0.0, 1.0);
	vec3 c = mix(A_SUN, mix(A_WHITE, A_SKY, 0.15), core);
	return vec4(c, smoothstep(0.0, 0.25, body) * alpha);
}
