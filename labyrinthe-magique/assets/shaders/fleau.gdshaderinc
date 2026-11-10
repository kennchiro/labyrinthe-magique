// LE SEIGNEUR DU FLÉAU (l'Éveil du Mage de la Peste) : la matière commune de ses effets. Du VERT ACIDE qui tire
// sur le jaune, un cœur presque blanc, l'ombre du venin, le NOIR BLEUTÉ de ses corbeaux et le BRONZE de son
// encensoir, cernés de vert très sombre. Le motif commun est la GOUTTE QUI ÉCLATE EN COURONNE. Des formes
// nettes, des volutes à bord franc, jamais de violet : la nuit du poison est noire et bleutée.

const vec3 F_RIM = vec3(0.047, 0.078, 0.039);
const vec3 F_NIGHT = vec3(0.078, 0.086, 0.11);
const vec3 F_SHADE = vec3(0.306, 0.541, 0.071);
const vec3 F_VENOM = vec3(0.706, 0.941, 0.165);
const vec3 F_BRIGHT = vec3(0.847, 1.0, 0.353);
const vec3 F_CORE = vec3(0.949, 1.0, 0.62);
const vec3 F_BRONZE = vec3(0.66, 0.455, 0.227);
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
