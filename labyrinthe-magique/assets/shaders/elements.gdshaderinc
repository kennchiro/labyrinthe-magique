// LA MATIÈRE DES QUATRE ÉLÉMENTS, partagée par tous les sorts du Suprême.
//
// `paint_element` reçoit un repère où la matière FILE le long de +x, et une densité
// `h` : positive dedans, nulle au bord. Chaque élément en fait autre chose : le feu la
// brûle, l'eau la strie, la terre la casse en plaques, l'air n'en garde que des filets.

uniform sampler2D noise : repeat_enable, filter_linear;

float fbm(vec2 p) {
	return texture(noise, p).r * 0.62 + texture(noise, p * 2.03 + 0.37).r * 0.38;
}

// ⚠️ Le bruit ne peut pas créer de matière hors de la forme : sans cette borne, il
// rallumait des pixels loin de `h` et le dessin se découpait en carré sur son quad.
float inside(float h) {
	return smoothstep(-0.42, -0.14, h);
}

vec3 fire_ramp(float heat) {
	vec3 color = mix(vec3(0.42, 0.03, 0.02), vec3(0.93, 0.17, 0.03), smoothstep(0.0, 0.2, heat));
	color = mix(color, vec3(1.0, 0.5, 0.05), smoothstep(0.18, 0.4, heat));
	color = mix(color, vec3(1.0, 0.82, 0.2), smoothstep(0.38, 0.62, heat));
	return mix(color, vec3(1.0, 0.98, 0.8), smoothstep(0.62, 0.86, heat));
}

// Une flamme : le bruit monte, se tord sur lui-même, et ronge la densité par le haut.
vec4 paint_fire(vec2 q, float t, float h) {
	// Très étiré dans le sens du feu : ce sont les langues qui font la flamme, un bruit
	// aussi fin dans les deux sens ne fait que grésiller.
	float warp = texture(noise, q * 0.09 + vec2(t * 0.16, 0.0)).r - 0.5;
	float f = fbm(vec2(q.x * 0.1 - t * 0.42, q.y * 0.3 + warp * 0.34));
	float heat = h + (f - 0.5) * 1.5;
	return vec4(fire_ramp(heat), smoothstep(0.0, 0.05, heat) * inside(h));
}

vec4 paint_water(vec2 q, float t, float h) {
	float f = fbm(vec2(q.x * 0.08 - t * 0.3, q.y * 0.3));
	float heat = h + (f - 0.5) * 0.7;
	float lines = sin(q.y * 21.0 + f * 16.0 - t * 2.0);
	vec3 color = mix(vec3(0.02, 0.2, 0.62), vec3(0.08, 0.5, 0.96), smoothstep(0.04, 0.42, heat));
	color = mix(color, vec3(0.5, 0.88, 1.0), smoothstep(0.35, 0.92, lines) * smoothstep(0.05, 0.3, heat));
	color = mix(color, vec3(1.0), smoothstep(0.86, 0.98, lines) * smoothstep(0.1, 0.5, heat));
	return vec4(color, smoothstep(0.0, 0.05, heat) * inside(h));
}

vec4 paint_earth(vec2 q, float t, float h) {
	float n = texture(noise, q * 0.2).r;
	float crack = abs(n - 0.5);
	float shard = texture(noise, q * 0.34 + 0.5).r;
	float heat = h + (n - 0.5) * 0.9;
	vec3 color = mix(vec3(0.17, 0.1, 0.05), vec3(0.47, 0.3, 0.13), smoothstep(0.3, 0.7, shard));
	color = mix(vec3(0.06, 0.035, 0.02), color, smoothstep(0.012, 0.04, crack));
	color = mix(color, vec3(0.42, 0.78, 0.16), smoothstep(0.7, 0.76, shard));
	color = mix(color, vec3(0.86, 1.0, 0.42), smoothstep(0.82, 0.86, shard));
	return vec4(color, smoothstep(0.0, 0.03, heat) * inside(h));
}

vec4 paint_air(vec2 q, float t, float h) {
	float f = fbm(vec2(q.x * 0.08 - t * 0.36, q.y * 0.28));
	float lines = sin(q.y * 15.0 + f * 13.0);
	float heat = h + (f - 0.5) * 0.8;
	vec3 color = mix(vec3(0.42, 0.56, 0.62), vec3(0.74, 0.9, 0.94), smoothstep(-0.5, 0.5, lines));
	color = mix(color, vec3(1.0), smoothstep(0.62, 0.92, lines));
	float body = smoothstep(0.0, 0.08, heat);
	return vec4(color, body * inside(h) * (0.46 + 0.54 * smoothstep(-0.2, 0.7, lines)));
}

vec4 paint_element(int kind, vec2 q, float t, float h) {
	if (kind == 0) { return paint_fire(q, t, h); }
	if (kind == 1) { return paint_water(q, t, h); }
	if (kind == 2) { return paint_earth(q, t, h); }
	return paint_air(q, t, h);
}

// Quatre bras en spirale qui se retrouvent au centre. `reach` : leur longueur.
vec4 pinwheel(vec2 p, float t, float reach, float turn, float twist) {
	float d = length(p);
	float a = atan(p.y, p.x) + turn - d * twist;
	float slice = TAU / 4.0;
	float index = floor(a / slice);
	float across = (fract(a / slice) - 0.5) * slice;
	int kind = int(mod(index, 4.0));
	float taper = max(0.02, 1.0 - d / reach);
	float h = (1.0 - abs(across) / (0.86 * sqrt(taper))) * 0.72 + taper * 0.4 - 0.22;
	vec4 matter = paint_element(kind, vec2(d * 1.2, across * max(d, 0.14) * 1.5 + index * 0.27), t, h);
	matter.a *= smoothstep(reach, reach * 0.9, d);
	return matter;
}
