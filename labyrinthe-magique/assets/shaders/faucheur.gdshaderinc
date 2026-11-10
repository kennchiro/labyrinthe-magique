// LE FAUCHEUR DES ÂMES (l'Éveil de l'Ange de la Mort) : sa palette, LA LAME (un croissant noir au tranchant de
// braise) et L'ÂME (une flamme pâle à traînée rouge), les deux motifs de tous ses sorts. Jamais de violet ni de vert.

uniform sampler2D noise : repeat_enable, filter_linear;

const vec3 F_BLACK = vec3(0.078, 0.07, 0.086);
const vec3 F_ASH = vec3(0.23, 0.24, 0.27);
const vec3 F_BONE = vec3(0.91, 0.86, 0.77);
const vec3 F_EMBER = vec3(0.91, 0.25, 0.165);
const vec3 F_CORE = vec3(1.0, 0.69, 0.48);
const vec3 F_SOUL = vec3(0.93, 0.94, 0.95);

float f_hash(float a, float b) {
	return fract(sin(a * 127.1 + b * 311.7) * 43758.5453);
}

float f_glow(float d, float r) {
	return clamp(1.0 - d / max(0.001, r), 0.0, 1.0);
}

vec4 f_over(vec4 top, vec4 under) {
	float a = top.a + under.a * (1.0 - top.a);
	vec3 c = a > 0.0 ? (top.rgb * top.a + under.rgb * under.a * (1.0 - top.a)) / a : vec3(0.0);
	return vec4(c, a);
}

// LA LAME : un croissant noir de rayon `r`, épais de `w`, ouvert vers `facing` (radians), tranchant de braise.
vec4 f_blade(vec2 p, float r, float w, float facing, float alpha) {
	float outer = r - length(p);
	float inner = length(p - vec2(cos(facing), sin(facing)) * w) - r;
	float body = min(outer, inner);
	if (body < -0.01) {
		return vec4(0.0);
	}
	vec3 c = body > 0.0 ? F_BLACK : F_BONE;
	if (body > 0.0 && outer < r * 0.1) {
		c = outer < r * 0.04 ? F_CORE : F_EMBER;
	}
	return vec4(c, alpha);
}

// L'ÂME : une flamme pâle aux deux yeux de braise, sa traînée vers `trail` (vecteur unité).
vec4 f_soul(vec2 p, float size, vec2 trail, float alpha) {
	float d = length(p);
	float along = dot(p, trail);
	float across = length(p - trail * along);
	float tail = step(0.0, along) * f_glow(across, size * 0.7 * (1.0 - along / (size * 3.0))) * step(along, size * 3.0);
	float head = smoothstep(size, size * 0.85, d);
	vec4 c = vec4(F_EMBER, tail * 0.75 * alpha);
	c = f_over(vec4(F_SOUL, head * alpha), c);
	vec2 side = vec2(-trail.y, trail.x) * size * 0.35;
	float eyes = smoothstep(size * 0.16, size * 0.1, length(p + trail * size * 0.25 - side))
		+ smoothstep(size * 0.16, size * 0.1, length(p + trail * size * 0.25 + side));
	c = f_over(vec4(F_EMBER, clamp(eyes, 0.0, 1.0) * alpha), c);
	return c;
}
