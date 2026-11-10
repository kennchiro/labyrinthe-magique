// LE FORGERON CÉLESTE (l'Éveil de l'Archange d'Acier) : sa palette, LA FENTE DE MÉTAL EN FUSION dans l'acier et LA
// GERBE D'ÉTINCELLES, les deux motifs de tous ses sorts. Gris-bleu, or, orange de forge. Jamais de rose ni de violet.

const vec3 G_STEEL = vec3(0.663, 0.714, 0.776);
const vec3 G_SHADE = vec3(0.365, 0.42, 0.49);
const vec3 G_GOLD = vec3(0.91, 0.722, 0.29);
const vec3 G_MOLTEN = vec3(1.0, 0.541, 0.165);
const vec3 G_CORE = vec3(1.0, 0.827, 0.416);
const vec3 G_SPARK = vec3(1.0, 0.957, 0.863);
const vec3 G_RIM = vec3(0.078, 0.094, 0.122);

float g_hash(float a, float b) {
	return fract(sin(a * 127.1 + b * 311.7) * 43758.5453);
}

float g_glow(float d, float r) {
	return clamp(1.0 - d / max(0.001, r), 0.0, 1.0);
}

vec4 g_over(vec4 top, vec4 under) {
	float a = top.a + under.a * (1.0 - top.a);
	vec3 c = a > 0.0 ? (top.rgb * top.a + under.rgb * under.a * (1.0 - top.a)) / a : vec3(0.0);
	return vec4(c, a);
}

vec2 g_turn(vec2 v, float a) {
	return vec2(v.x * cos(a) - v.y * sin(a), v.x * sin(a) + v.y * cos(a));
}

// LA CHALEUR : du noir d'acier au jaune du cœur, selon `h` (0 froid, 1 blanc chaud).
vec3 g_heat(float h) {
	vec3 c = mix(G_SHADE, G_MOLTEN, smoothstep(0.15, 0.55, h));
	c = mix(c, G_CORE, smoothstep(0.55, 0.85, h));
	return mix(c, G_SPARK, smoothstep(0.85, 1.0, h));
}

// LA GERBE : `n` étincelles qui partent du centre en éventail vers le haut (`spread` en radians autour de -y),
// jusqu'à `reach`, à l'instant `t` (0..1). Retourne l'intensité.
float g_sparks(vec2 p, float t, float reach, float spread, float seed, int n) {
	float lit = 0.0;
	for (int i = 0; i < 24; i++) {
		if (i >= n) {
			break;
		}
		float f = float(i);
		float a = -1.5708 + (g_hash(f, seed) - 0.5) * spread;
		float speed = 0.5 + g_hash(f + 7.0, seed) * 0.5;
		float d = t * reach * speed;
		vec2 at = vec2(cos(a), sin(a)) * d + vec2(0.0, t * t * reach * 0.6);
		vec2 dir = normalize(vec2(cos(a), sin(a) + t * 1.2));
		float along = dot(p - at, dir);
		float across = length(p - at - dir * along);
		float streak = step(-0.08, along) * step(along, 0.0) * smoothstep(0.018, 0.0, across);
		lit = max(lit, streak * (1.0 - t));
	}
	return lit;
}

// UNE LAME en losange allongé le long de `dir`, longue de `len`, au tranchant orange.
vec4 g_blade(vec2 p, vec2 dir, float len, float alpha) {
	float along = dot(p, dir);
	float across = abs(dot(p, vec2(-dir.y, dir.x)));
	float half_w = len * 0.18 * (1.0 - abs(along) / len);
	if (abs(along) > len || across > half_w + 0.01) {
		return vec4(0.0);
	}
	vec3 c = across > half_w ? G_RIM : (across > half_w * 0.55 ? G_MOLTEN : G_STEEL);
	return vec4(c, alpha);
}

// LES FISSURES : `n` traits fins et brisés qui partent du centre, jusqu'à `reach`. Retourne l'intensité.
float g_cracks(vec2 g, float n, float seed, float reach) {
	float d = length(g);
	if (d > reach) {
		return 0.0;
	}
	float sector = TAU / n;
	float a = atan(g.y, g.x) + seed;
	float m = mod(a + sector * 0.5, sector) - sector * 0.5;
	float jag = 0.04 * sin(d * 23.0 + seed * 5.0) + 0.025 * sin(d * 51.0);
	float dist = abs(d * sin(m) - jag * d);
	return smoothstep(0.028, 0.008, dist) * smoothstep(reach, reach * 0.7, d);
}
