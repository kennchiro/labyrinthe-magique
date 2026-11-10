// L'ARCHIMAGE PRIMORDIAL (l'Éveil du Sorcier Suprême) : sa palette, et L'ANNEAU D'OR AUX QUATRE RUNES, le motif
// commun de tous ses sorts. La matière des quatre éléments vient de `elements.gdshaderinc` (0 feu, 1 eau, 2 terre,
// 3 air), qui déclare aussi le bruit : les shaders qui incluent ce fichier ne le redéclarent pas.

#include "res://assets/shaders/elements.gdshaderinc"

const vec3 P_GOLD = vec3(0.91, 0.72, 0.29);
const vec3 P_GOLD_LIGHT = vec3(1.0, 0.945, 0.72);
const vec3 P_GOLD_DARK = vec3(0.5, 0.32, 0.08);
const vec3 P_NIGHT = vec3(0.078, 0.102, 0.18);
const vec3 P_INK = vec3(0.04, 0.03, 0.07);
const vec3 P_WHITE = vec3(1.0, 0.99, 0.94);

float p_hash(float a, float b) {
	return fract(sin(a * 127.1 + b * 311.7) * 43758.5453);
}

// La couleur franche d'un élément, pour ce qui n'est pas de la matière (runes, lueurs, filets).
vec3 p_element(int k) {
	if (k == 0) { return vec3(1.0, 0.36, 0.14); }
	if (k == 1) { return vec3(0.24, 0.68, 1.0); }
	if (k == 2) { return vec3(0.8, 0.56, 0.2); }
	return vec3(0.93, 0.97, 1.0);
}

// Pose `top` par-dessus `under`.
vec4 p_over(vec4 top, vec4 under) {
	float a = top.a + under.a * (1.0 - top.a);
	vec3 c = a > 0.0 ? (top.rgb * top.a + under.rgb * under.a * (1.0 - top.a)) / a : vec3(0.0);
	return vec4(c, a);
}

// L'ANNEAU D'OR : bande de `width` autour de `radius`, gravée de traits, et quatre runes aux points cardinaux
// (tournés de `turn`). `lit` dit combien chaque rune brûle de son élément (feu, eau, terre, air).
vec4 p_ring(vec2 p, float radius, float width, float turn, vec4 lit) {
	vec4 out_c = vec4(0.0);
	float d = length(p);
	float band = width - abs(d - radius);
	if (band > 0.0) {
		float a = atan(p.y, p.x) - turn;
		float ticks = step(0.86, fract(a * 24.0 / TAU));
		vec3 c = mix(P_GOLD_DARK, P_GOLD, smoothstep(0.0, width * 0.35, band));
		c = mix(c, P_GOLD_LIGHT, smoothstep(width * 0.6, width, band) * step(d, radius));
		c = mix(c, P_GOLD_DARK, ticks * step(width * 0.3, band));
		out_c = vec4(c, 1.0);
	}
	for (int k = 0; k < 4; k++) {
		float ang = turn + float(k) * TAU / 4.0 - TAU / 4.0;
		vec2 q = p - vec2(cos(ang), sin(ang)) * radius;
		float r = width * 2.3;
		float dq = length(q);
		if (dq < r) {
			float glow = k == 0 ? lit.x : (k == 1 ? lit.y : (k == 2 ? lit.z : lit.w));
			vec3 c = dq > r * 0.8 ? P_GOLD_DARK : (dq > r * 0.66 ? P_GOLD : mix(P_INK, p_element(k) * 0.35, 0.5));
			// Le glyphe : un losange creux, de la couleur de son élément quand la rune brûle.
			float diamond = abs(q.x) + abs(q.y);
			float glyph = r * 0.12 - abs(diamond - r * 0.38);
			if (glyph > 0.0 || length(q) < r * 0.1) {
				c = mix(P_GOLD_LIGHT, p_element(k), 0.35 + 0.65 * glow);
				c = mix(c, P_WHITE, glow * 0.45);
			} else if (dq < r * 0.66) {
				c = mix(c, p_element(k), glow * 0.55);
			}
			out_c = vec4(c, 1.0);
		}
	}
	return out_c;
}

// Une lueur douce, sans bord : pour les éclats et le cœur des coups.
float p_glow(float d, float r) {
	return clamp(1.0 - d / max(0.001, r), 0.0, 1.0);
}
