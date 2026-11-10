// L'ARCHIDÉMON DU PACTE (l'Éveil du Démon du Pacte) : la matière commune de ses effets. La palette du Démon du
// Pacte : le ROUGE SANG, un rouge plus vif pour ce qui brûle, le pâle au cœur, le sang sombre, l'OR VIEILLI de ses
// sceaux et le noir qui cerne. Les fonctions viennent du Fléau, dont les gouttes et les gerbes servent au sang :
// mêmes formes, nettes, à bord franc. Les noms `F_*` sont gardés pour que ses shaders se recopient tels quels.
// Jamais de rose : le rouge fonce vers le brun, jamais vers le framboise.

const vec3 F_RIM = vec3(0.078, 0.039, 0.055);
const vec3 F_NIGHT = vec3(0.12, 0.04, 0.06);
const vec3 F_SHADE = vec3(0.42, 0.039, 0.122);
const vec3 F_VENOM = vec3(0.784, 0.078, 0.235);
const vec3 F_BRIGHT = vec3(1.0, 0.23, 0.16);
const vec3 F_CORE = vec3(1.0, 0.914, 0.659);
const vec3 F_BRONZE = vec3(0.847, 0.663, 0.227);
const vec3 F_BLOOD = vec3(0.75, 0.1, 0.08);

float f_hash(float x, float s) {
	return fract(sin(x * 12.9898 + s * 78.233) * 43758.5453);
}

vec2 f_rot(vec2 q, float a) {
	float c = cos(a);
	float s = sin(a);
	return vec2(c * q.x - s * q.y, s * q.x + c * q.y);
}

// UNE GOUTTE en larme, pointe vers -y local (vers le haut à l'écran), de rayon `r`. > 0 dedans.
float f_drop(vec2 q, float r) {
	float round_part = r - length(q);
	float tip = r * 1.9;
	float cone = (q.y < 0.0 && q.y > -tip) ? (r * (1.0 + q.y / tip) * 0.95 - abs(q.x)) : -1.0;
	return max(round_part, cone);
}

// La goutte peinte : cernée, venin, ombre en bas, reflet clair en haut à gauche. Vrai si dessus.
bool f_paint_drop(vec2 q, float r, inout vec3 color) {
	float v = f_drop(q, r);
	if (v < -0.012 || r <= 0.0) {
		return false;
	}
	if (v <= 0.0) {
		color = F_RIM;
		return true;
	}
	color = mix(F_VENOM, F_SHADE, smoothstep(0.0, r, q.y + r * 0.2) * 0.7);
	if (length(q - vec2(-r * 0.35, -r * 0.3)) < r * 0.28) {
		color = F_CORE;
	}
	return true;
}
