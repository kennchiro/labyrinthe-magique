shader_type canvas_item;
render_mode blend_mix;

// LE PACTE DE SANG, en quatre temps : c'est un contrat, pas une explosion.
//   1. LE TRACÉ : l'anneau d'or se dessine d'un trait, avec ses graduations et ses quatre pointes.
//   2. LA GOUTTE tombe de haut, dans le losange du sceau.
//   3. LE SANG COURT : l'impact lance une onde, et quatre veines rouges remplissent le losange.
//   4. LE SCEAU SE REFERME sur lui-même, et des éclats d'or s'élèvent.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(1.0, 0.914, 0.659);
const vec3 GOLD = vec3(0.847, 0.663, 0.227);
const vec3 CRIMSON = vec3(0.784, 0.078, 0.235);
const vec3 DEEP = vec3(0.42, 0.039, 0.122);
const vec3 BLACK = vec3(0.078, 0.039, 0.055);
const float TICKS = 24.0;
const float SPARKS = 8.0;

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	p.y *= 1.35;
	float d = length(p);
	float a = atan(p.y, p.x);
	float draw = smoothstep(0.0, 0.32, progress);
	float close = smoothstep(0.76, 1.0, progress);
	float size = 1.0 - close * 0.72;
	float swept = step(fract((a + 1.571) / TAU), draw);
	// L'anneau, ses graduations qui tournent, le filet intérieur.
	float ring = 0.034 - abs(d - 0.68 * size);
	float turned = a + progress * 2.2;
	float ticks = min(0.03 - abs(d - 0.77 * size), abs(fract(turned * TICKS / TAU) - 0.5) * 0.2 - 0.022);
	float inner = 0.012 - abs(d - 0.56 * size);
	// Les quatre pointes de la broderie, sur les axes.
	vec2 c = abs(p);
	float spikes = 0.0 - 1.0;
	if (c.x > c.y) {
		spikes = 0.06 * size - (abs(c.x - 0.8 * size) * 0.38 + c.y);
	} else {
		spikes = 0.06 * size - (abs(c.y - 0.8 * size) * 0.38 + c.x);
	}
	float diamond_edge = abs(p.x) + abs(p.y) - 0.5 * size;
	float diamond = 0.026 - abs(diamond_edge);
	float line = max(max(max(ring, ticks), max(inner, spikes)), diamond);
	vec3 color = mix(BLACK, GOLD, smoothstep(0.0, 0.012, line));
	color = mix(color, PALE, smoothstep(0.02, 0.032, line) * (1.0 - close));
	float alpha = smoothstep(-0.008, 0.0, line) * swept;
	// Les veines et le losange qui se remplit, à partir de l'impact de la goutte.
	float fill = smoothstep(0.5, 0.72, progress);
	if (fill > 0.0 && diamond_edge < -0.02) {
		float from_centre = (abs(p.x) + abs(p.y)) / max(0.5 * size, 0.01);
		if (from_centre < fill) {
			float vein = abs(sin(a * 2.0 + from_centre * 3.0));
			color = mix(CRIMSON, DEEP, smoothstep(0.25, 0.6, vein));
			color = mix(color, PALE, smoothstep(0.1, 0.0, from_centre) * 0.9);
			alpha = 1.0;
		}
	}
	// L'onde de l'impact.
	float wave_t = clamp((progress - 0.48) / 0.3, 0.0, 1.0);
	float wave = (0.03 * (1.0 - wave_t)) - abs(d - wave_t * 0.95);
	if (wave_t > 0.0 && wave_t < 1.0 && wave > 0.0 && alpha < 0.5) {
		color = CRIMSON;
		alpha = 1.0;
	}
	// La goutte : pointue en l'air, elle s'écrase sur le sceau.
	float fall = clamp((progress - 0.22) / 0.27, 0.0, 1.0);
	if (fall > 0.0 && fall < 1.0) {
		vec2 q = p - vec2(0.0, mix(-1.3, 0.0, fall * fall));
		float tail = max(-q.y, 0.0);
		float drop = 0.09 - tail * 0.3 - length(vec2(q.x, max(q.y, 0.0))) - abs(q.x) * tail * 2.0;
		if (drop > 0.0 && q.y > -0.34) {
			color = mix(CRIMSON, PALE, smoothstep(0.045, 0.07, drop));
			alpha = 1.0;
		}
	}
	// Les éclats montent quand il se referme.
	for (int i = 0; i < int(SPARKS); i++) {
		float f = float(i);
		float life = clamp((progress - 0.68 - hash(f) * 0.12) / 0.28, 0.0, 1.0);
		vec2 at = vec2((hash(f + 2.0) - 0.5) * 1.1, 0.3 - life * (0.7 + hash(f + 3.0) * 0.6));
		vec2 q = abs(p - at);
		float spark = 0.055 * (1.0 - life) - (q.x + q.y * 0.55);
		if (spark > 0.0 && life > 0.0 && life < 1.0) {
			color = PALE;
			alpha = 1.0;
		}
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
